// ============================================================================
// Blueprint #20: Multimodal Realtime Voice/Video WebRTC Agent Sandbox Pool
// Azure Communication Services (ACS) Anycast TURN Relay + Public IP Prefix
// UDP RTP Port Range (49152-65535) + AKS eBPF XDP/sockmap Media Nodepool
// ============================================================================

@description('Target Azure region')
param location string = resourceGroup().location

@description('Existing AKS cluster name')
param aksClusterName string = 'aks-aksclaw-prod'

@description('Azure Communication Services resource name for global Anycast TURN relay')
param acsName string = 'acs-aksclaw-webrtc-turn'

@description('Public IP Prefix name for deterministic WebRTC UDP RTP ingress/egress')
param rtpIpPrefixName string = 'ippre-aksclaw-webrtc-rtp'

// 1. Azure Communication Services (Global Anycast TURN / ICE Relay)
resource acsService 'Microsoft.Communication/communicationServices@2023-04-01' = {
  name: acsName
  location: 'global'
  properties: {
    dataLocation: 'UnitedStates'
  }
}

// 2. Public IP Prefix (/28 = 16 Dedicated IPs) for Direct UDP RTP Media Streams
resource rtpIpPrefix 'Microsoft.Network/publicIPPrefixes@2023-09-01' = {
  name: rtpIpPrefixName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    prefixLength: 28
    publicIPAddressVersion: 'IPv4'
  }
}

// 3. NSG Rule Allowing Direct UDP RTP Media Ports (49152-65535) to eBPF XDP Nodepool
resource rtpMediaNsg 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: 'nsg-aksclaw-webrtc-rtp'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowWebRtcUdpRtpRange'
        properties: {
          priority: 110
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Udp'
          sourcePortRange: '*'
          destinationPortRange: '49152-65535'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

// 4. AKS Realtime WebRTC Media Nodepool (50 Gbps MANA + Cilium eBPF XDP/sockmap)
resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

resource webrtcMediaPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'webrtcmedia'
  properties: {
    count: 20
    vmSize: 'Standard_D32s_v6'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    enableAutoScaling: true
    minCount: 6
    maxCount: 80
    availabilityZones: [ '1', '2', '3' ]
    nodeLabels: {
      'aksclaw.io/workload-class': 'webrtc-realtime-media'
      'aksclaw.io/ebpf-xdp-sockmap': 'enabled'
      'aksclaw.io/srtp-aes-gcm-offload': 'true'
    }
  }
}

output acsEndpointId string = acsService.id
output rtpPublicIpPrefixId string = rtpIpPrefix.id
output webrtcMediaNodepoolId string = webrtcMediaPool.id
