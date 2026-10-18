// =============================================================================
// Blueprint #14: Ephemeral Dependency Acceleration — Azure Container Registry
// (ACR) Premium with Artifact Cache Rules, Connected Cache & Host Local NVMe
// `virtiofs` DAX Read-Only Content-Addressable Store (`uv` Reflink / Nix)
// =============================================================================
targetScope = 'resourceGroup'

@description('Deployment location')
param location string = resourceGroup().location

@description('Environment prefix')
param prefix string = 'aksclaw-dep'

// 1. Azure Container Registry Premium (Zone Redundant + Private Link + Artifact Cache)
resource acrRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: replace('${prefix}acrprem', '-', '')
  location: location
  sku: {
    name: 'Premium'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    adminUserEnabled: false
    publicNetworkAccess: 'Disabled'
    zoneRedundancy: 'Enabled'
    policies: {
      trustPolicy: {
        type: 'Notary'
        status: 'enabled'
      }
      retentionPolicy: {
        days: 30
        status: 'enabled'
      }
    }
  }
}

// 2. Upstream Artifact Cache Rule for MCR / Base Runtime Layers (OverlayBD / eStargz Ready)
resource mcrCacheRule 'Microsoft.ContainerRegistry/registries/cacheRules@2023-07-01' = {
  parent: acrRegistry
  name: 'mcr-agent-runtime-base'
  properties: {
    sourceRepository: 'mcr.microsoft.com/devcontainers/*'
    targetRepository: 'cached-devcontainers/*'
  }
}

// 3. Upstream Artifact Cache Rule for Verified MCP Server OCI Images
resource ghcrCacheRule 'Microsoft.ContainerRegistry/registries/cacheRules@2023-07-01' = {
  parent: acrRegistry
  name: 'ghcr-verified-mcp-tools'
  properties: {
    sourceRepository: 'ghcr.io/modelcontextprotocol/*'
    targetRepository: 'cached-mcp/*'
  }
}

output acrLoginServer string = acrRegistry.properties.loginServer
output acrResourceId string = acrRegistry.id
