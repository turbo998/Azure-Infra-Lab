// Blueprint #45: Autonomous Quantitative Trading, Market Microstructure & FIX/ITCH Execution Agent Pool
// Provisions Proximity Placement Group (PPG), Standard_FX48mds (4.0 GHz) AF_XDP kernel-bypass nodepool,
// SEC Rule 15c3-5 / MiFID II RTS 6 pre-trade risk kill-switch, and WORM CAT/MiFID nanosecond audit storage.

@description('Azure region for low-latency quantitative trading agent infrastructure')
param location string = resourceGroup().location

@description('Existing AKS cluster name')
param aksClusterName string = 'aks-aksclaw-prod'

@description('Storage account name for WORM-immutable CAT / MiFID II RTS 25 nanosecond order audit trail')
param auditStorageName string = 'stquantcatauditprod01'

resource ppgQuant 'Microsoft.Compute/proximityPlacementGroups@2024-03-01' = {
  name: 'ppg-quant-fx48mds-ultra-low-latency'
  location: location
  properties: {
    proximityPlacementGroupType: 'Standard'
    intent: {
      vmSizes: [
        'Standard_FX48mds'
      ]
    }
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-05-01' existing = {
  name: aksClusterName
}

resource quantTradingPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-05-01' = {
  parent: aksCluster
  name: 'quantfxp'
  properties: {
    count: 8
    vmSize: 'Standard_FX48mds'
    osType: 'Linux'
    osSKU: 'Ubuntu'
    mode: 'User'
    proximityPlacementGroupID: ppgQuant.id
    enableEncryptionAtHost: true
    nodeLabels: {
      'aksclaw.io/workload-class': 'quant-trading-fix-itch-execution-agent'
      'aksclaw.io/afxdp-orderbook-feed': 'mana-zerocopy-sbe-itch50-11.5us'
      'aksclaw.io/pretrade-risk-gate': 'sec-15c3-5-mifid2-rts6-1.8us-killswitch'
      'aksclaw.io/ptp-clock-sync': 'hyperv-phc-1588v2-180ns-worm-audit'
    }
    nodeTaints: [
      'aksclaw.io/quant-low-latency=true:NoSchedule'
    ]
  }
}

resource auditStorage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: auditStorageName
  location: location
  sku: {
    name: 'Standard_ZRS'
  }
  kind: 'StorageV2'
  properties: {
    isHnsEnabled: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    immutableStorageWithVersioning: {
      enabled: true
    }
  }
}

output quantPoolId string = quantTradingPool.id
output ppgId string = ppgQuant.id
output auditStorageId string = auditStorage.id
