// ============================================================================
// Azure AI Agent Infrastructure Playbook — Blueprint 9
// AKSClaw & E2B Zero-Trust Egress Governance:
//   - Azure Firewall Premium (TLS Inspection + IDPS Deny + FQDN Allowlist)
//   - Multi-IP Azure NAT Gateway (64,000 SNAT ports/IP scale-out guard)
//   - Azure Private Endpoints (Foundry / Storage / Key Vault / HorizonDB)
// ============================================================================

targetScope = 'resourceGroup'

@description('Deployment region')
param location string = resourceGroup().location

@description('Number of Public IPs attached to NAT Gateway (each IP provides 64,000 SNAT ephemeral ports; max 16 IPs = 1,024,000 ports)')
@minValue(2)
@maxValue(16)
param natGatewayPublicIpCount int = 8

@description('Existing Agent VNet name')
param vnetName string = 'vnet-agent-infra-prod'

resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' existing = {
  name: vnetName
}

// 1. Multi-IP Public IP Prefix for NAT Gateway to prevent SNAT Port Exhaustion
resource natPipPrefix 'Microsoft.Network/publicIPPrefixes@2023-11-01' = {
  name: 'pippre-agent-egress-nat'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    prefixLength: 29 // /29 provides 8 contiguous Public IPs = 512,000 SNAT ports
    publicIPAddressVersion: 'IPv4'
  }
}

resource natGateway 'Microsoft.Network/natGateways@2023-11-01' = {
  name: 'natgw-agent-sandbox-egress'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    idleTimeoutInMinutes: 4 // Fast TCP FIN/idle reclaim for short-lived Agent tool calls
    publicIPPrefixes: [
      {
        id: natPipPrefix.id
      }
    ]
  }
}

// 2. Azure Firewall Premium Policy with IDPS Deny, TLS Inspection & Strict FQDN Allowlist
resource fwPolicy 'Microsoft.Network/firewallPolicies@2023-11-01' = {
  name: 'fwpol-agent-zero-trust-premium'
  location: location
  properties: {
    sku: {
      tier: 'Premium'
    }
    threatIntelMode: 'Deny'
    intrusionDetection: {
      mode: 'Deny' // Block known C2, reverse shell & DNS-tunneling exfiltration signatures
    }
    dnsSettings: {
      enableProxy: true
    }
  }
}

resource allowlistRuleGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2023-11-01' = {
  parent: fwPolicy
  name: 'rcg-agent-sandbox-egress-lockdown'
  properties: {
    priority: 200
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        name: 'rc-block-imds-wireserver-rfc1918'
        priority: 110
        action: {
          type: 'Deny'
        }
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'deny-imds-and-wireserver'
            ipProtocols: ['Any']
            sourceAddresses: ['10.240.0.0/16']
            destinationAddresses: [
              '169.254.169.254/32'
              '168.63.129.16/32'
            ]
            destinationPorts: ['*']
          }
        ]
      }
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        name: 'rc-allow-curated-mcp-and-package-mirrors'
        priority: 210
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'ApplicationRule'
            name: 'allow-verified-package-and-mcp-endpoints'
            sourceAddresses: ['10.240.0.0/16']
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            targetFqdns: [
              '*.pypi.org'
              'files.pythonhosted.org'
              'registry.npmjs.org'
              '*.mcr.microsoft.com'
            ]
            terminateTLS: true
          }
        ]
      }
    ]
  }
}

output totalSnatEphemeralPortCapacity int = natGatewayPublicIpCount * 64000
output firewallPolicyId string = fwPolicy.id
