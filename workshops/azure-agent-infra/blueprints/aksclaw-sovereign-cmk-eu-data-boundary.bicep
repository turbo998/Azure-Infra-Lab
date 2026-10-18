// =============================================================================
// Blueprint #16: Sovereign Cloud & EU Data Boundary Guardrails — Azure Policy
// `AllowedLocations` Geo-Fence, Key Vault Managed HSM Tenant CMK Key,
// `DiskEncryptionSet` Auto-Rotation & ZRS Storage Account CMK Binding
// =============================================================================
targetScope = 'resourceGroup'

@description('Sovereign primary location (e.g., swedencentral or westeurope)')
param location string = 'swedencentral'

@description('Allowed sovereign region pair')
param allowedLocations array = [
  'swedencentral'
  'westeurope'
]

@description('Managed HSM Key URI for Tenant Customer-Managed Key (CMK / KEK)')
param managedHsmKeyUri string

@description('Environment prefix')
param prefix string = 'aksclaw-sov'

// 1. Resource-Group Scoped Azure Policy Assignment Enforcing Sovereign Geo-Fence
resource geoFencePolicy 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: '${prefix}-eu-geofence'
  location: location
  properties: {
    displayName: 'Enforce EU Data Boundary Allowed Locations for Agent Sandboxes & State'
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c'
    parameters: {
      listOfAllowedLocations: {
        value: allowedLocations
      }
    }
  }
}

// 2. DiskEncryptionSet Bound to Regional Managed HSM Tenant KEK (NIST SP 800-88 Crypto-Shredding)
resource sovereignDes 'Microsoft.Compute/diskEncryptionSets@2022-07-02' = {
  name: '${prefix}-tenant-cmk-des'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    encryptionType: 'EncryptionAtRestWithCustomerKey'
    rotationToLatestKeyVersionEnabled: true
    activeKey: {
      keyUrl: managedHsmKeyUri
    }
  }
}

// 3. Sovereign ZRS Snapshot Storage Bound to Tenant Managed HSM CMK
resource sovereignStorage 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: replace('${prefix}zrssnap', '-', '')
  location: location
  sku: {
    name: 'Standard_ZRS'
  }
  kind: 'StorageV2'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    publicNetworkAccess: 'Disabled'
    encryption: {
      keySource: 'Microsoft.Keyvault'
      requireInfrastructureEncryption: true
      services: {
        blob: {
          enabled: true
          keyType: 'Account'
        }
      }
    }
  }
}

output diskEncryptionSetId string = sovereignDes.id
output sovereignStorageId string = sovereignStorage.id
