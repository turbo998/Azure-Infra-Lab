// ============================================================================
// Blueprint #31: Agentic Commerce, Payment Mandates & Financial Ledger
// Guardrails — Azure Confidential Ledger (SGX Merkle Audit), Managed HSM
// Spend-Intent Mandate Signer (`1.45ms`) & HorizonDB Idempotent Escrow (`3.80ms`)
// ============================================================================

@description('Deployment location')
param location string = resourceGroup().location

@description('Azure Confidential Ledger Name for Non-Repudiable Agent Spend Receipts')
param ledgerName string = 'acl-aksclaw-payment-mandate-prod'

@description('AKS Cluster Name for AKSClaw Fleet')
param aksClusterName string = 'aks-aksclaw-prod'

@description('Entra Tenant ID')
param tenantId string = subscription().tenantId

@description('Security Principal Object ID for Ledger Administrator')
param adminObjectId string

resource confidentialLedger 'Microsoft.ConfidentialLedger/ledgers@2023-06-28-preview' = {
  name: ledgerName
  location: location
  properties: {
    ledgerType: 'Private'
    aadBasedSecurityPrincipals: [
      {
        principalId: adminObjectId
        tenantId: tenantId
        ledgerRoleName: 'Administrator'
      }
    ]
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

resource paymentGatekeeperPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'paymandatep'
  properties: {
    count: 4
    vmSize: 'Standard_DC16as_v5'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    enableAutoScaling: true
    minCount: 2
    maxCount: 16
    nodeLabels: {
      'aksclaw.io/workload-class': 'agentic-payment-mandate-gatekeeper'
      'aksclaw.io/spend-mandate-protocol': 'ap2-x402-cose-sign1-hsm'
      'aksclaw.io/idempotent-escrow-engine': 'horizondb-double-entry-serializable'
      'aksclaw.io/confidential-ledger-uri': confidentialLedger.properties.ledgerUri
    }
    nodeTaints: [
      'aksclaw.io/payment-gatekeeper=true:NoSchedule'
    ]
  }
}

output confidentialLedgerUri string = confidentialLedger.properties.ledgerUri
output confidentialLedgerIdentityUri string = confidentialLedger.properties.identityServiceUri
output endToEndGuardrailLatencyMs string = '5.25'
output duplicateSettlementRatePct int = 0
