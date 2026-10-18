// =============================================================================
// Blueprint #13: Computer-Use Agent (CUA) Browser/Desktop Sandbox Pool —
// Azure Web PubSub Premium (Low-Latency CDP Screencast & Human-in-the-Loop
// Takeover Relay) + Azure Blob Storage CUA Session Replay Lifecycle Tiering
// =============================================================================
targetScope = 'resourceGroup'

@description('Deployment location')
param location string = resourceGroup().location

@description('Environment prefix')
param prefix string = 'aksclaw-cua'

@description('Web PubSub Premium unit count for concurrent CDP/WebSocket streams')
param webPubSubUnits int = 2

// 1. Azure Web PubSub Premium (Human-in-the-Loop CDP Screencast & Takeover Relay)
resource cuaWebPubSub 'Microsoft.SignalRService/webPubSub@2024-03-01' = {
  name: '${prefix}-wps-relay'
  location: location
  sku: {
    name: 'Premium_P1'
    tier: 'Premium'
    capacity: webPubSubUnits
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: 'Disabled'
    disableLocalAuth: true
    tls: {
      clientCertEnabled: false
    }
  }
}

resource cuaHub 'Microsoft.SignalRService/webPubSub/hubs@2024-03-01' = {
  parent: cuaWebPubSub
  name: 'cua_cdp_screencast'
  properties: {
    anonymousConnectPolicy: 'deny'
  }
}

// 2. Azure Storage Account for CUA Session Replays (HAR + AXTree JSON + Dirty-Rect WebM)
resource replayStorage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: replace('${prefix}replayst', '-', '')
  location: location
  sku: {
    name: 'Standard_ZRS'
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    publicNetworkAccess: 'Disabled'
  }
}

// 3. Automated Hot -> Cool -> Archive Lifecycle Policy for CUA Audit Recordings
resource replayLifecycle 'Microsoft.Storage/storageAccounts/managementPolicies@2023-05-01' = {
  parent: replayStorage
  name: 'default'
  properties: {
    policy: {
      rules: [
        {
          name: 'cua-session-replay-tiering'
          enabled: true
          type: 'Lifecycle'
          definition: {
            filters: {
              blobTypes: [
                'blockBlob'
              ]
              prefixMatch: [
                'cua-replays/'
              ]
            }
            actions: {
              baseBlob: {
                tierToCool: {
                  daysAfterModificationGreaterThan: 7
                }
                tierToArchive: {
                  daysAfterModificationGreaterThan: 30
                }
                delete: {
                  daysAfterModificationGreaterThan: 180
                }
              }
            }
          }
        }
      ]
    }
  }
}

output webPubSubHostName string = cuaWebPubSub.properties.hostName
output replayStorageAccountName string = replayStorage.name
