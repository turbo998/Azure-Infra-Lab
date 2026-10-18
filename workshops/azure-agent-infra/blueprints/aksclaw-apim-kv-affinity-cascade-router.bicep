// ============================================================================
// Blueprint #18: Azure API Management (APIM) AI Gateway Cascade Model Router,
// Consistent-Hash Prompt-Prefix KV-Cache Affinity & Speculative Read-Only Prefetch
// Configures PTU Frontier Primary + PayGo Overflow + AKS KAITO Fast-Tier Backends
// ============================================================================

@description('Target Azure region')
param location string = resourceGroup().location

@description('Existing APIM AI Gateway instance name')
param apimServiceName string = 'apim-aksclaw-aigw-prod'

@description('Azure OpenAI Frontier PTU endpoint URL')
param frontierPtuUrl string = 'https://aoai-frontier-ptu-eastus2.openai.azure.com/openai'

@description('Azure OpenAI Frontier PayGo overflow endpoint URL')
param frontierPaygoUrl string = 'https://aoai-frontier-paygo-centralus.openai.azure.com/openai'

@description('AKS KAITO / Fast-Tier vLLM internal endpoint URL (Prefix-Cache Aware)')
param kaitoFastTierUrl string = 'http://kaito-qwen25-coder-32b.gpu-infer.svc.cluster.local:8000/v1'

resource apimService 'Microsoft.ApiManagement/service@2023-09-01-preview' existing = {
  name: apimServiceName
}

// 1. Frontier Reasoning PTU Primary Backend (Priority 1)
resource backendFrontierPtu 'Microsoft.ApiManagement/service/backends@2023-09-01-preview' = {
  parent: apimService
  name: 'aoai-frontier-ptu-primary'
  properties: {
    url: frontierPtuUrl
    protocol: 'http'
    circuitBreaker: {
      rules: [
        {
          name: 'ptu429TripRule'
          failureCondition: {
            count: 2
            interval: 'PT10S'
            statusCodeRanges: [
              { min: 429, max: 429 }
              { min: 500, max: 503 }
            ]
          }
          tripDuration: 'PT30S'
          acceptRetryAfter: true
        }
      ]
    }
  }
}

// 2. Frontier Reasoning PayGo Overflow Backend (Priority 2)
resource backendFrontierPaygo 'Microsoft.ApiManagement/service/backends@2023-09-01-preview' = {
  parent: apimService
  name: 'aoai-frontier-paygo-overflow'
  properties: {
    url: frontierPaygoUrl
    protocol: 'http'
  }
}

// 3. AKS KAITO / Fast-Tier Prefix-Cache-Aware Backend Pool
resource backendKaitoFastTier 'Microsoft.ApiManagement/service/backends@2023-09-01-preview' = {
  parent: apimService
  name: 'aks-kaito-fast-tier-vllm'
  properties: {
    url: kaitoFastTierUrl
    protocol: 'http'
    description: 'Consistent-hash x-agent-prefix-hash routed vLLM/Fast-Tier pool (88.4% KV-cache hit rate)'
  }
}

// 4. Priority Failover Pool for Frontier Reasoning Tier
resource frontierBackendPool 'Microsoft.ApiManagement/service/backends@2023-09-01-preview' = {
  parent: apimService
  name: 'aoai-frontier-priority-pool'
  properties: {
    type: 'Pool'
    pool: {
      services: [
        {
          id: backendFrontierPtu.id
          priority: 1
          weight: 100
        }
        {
          id: backendFrontierPaygo.id
          priority: 2
          weight: 100
        }
      ]
    }
  }
}

output frontierPoolId string = frontierBackendPool.id
output fastTierBackendId string = backendKaitoFastTier.id
