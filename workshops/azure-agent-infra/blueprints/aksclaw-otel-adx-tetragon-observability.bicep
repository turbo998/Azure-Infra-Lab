// =============================================================================
// Blueprint #11: End-to-End Agentic Observability — Azure Monitor Managed
// Prometheus, Managed Grafana & Azure Data Explorer (Kusto) for OpenTelemetry
// GenAI Traces (`gen_ai.*`) + Tetragon eBPF Syscall Audit Events
// =============================================================================
targetScope = 'resourceGroup'

@description('Deployment location')
param location string = resourceGroup().location

@description('Environment prefix for naming')
param prefix string = 'aksclaw-obs'

@description('ADX (Kusto) hot cache retention in days')
param adxHotCacheDays int = 14

@description('ADX (Kusto) total compressed retention in days (ZSTD 8.4x)')
param adxSoftDeleteDays int = 90

// 1. Azure Monitor Workspace (Managed Prometheus for 100K Sandbox Metrics)
resource monitorWorkspace 'Microsoft.Monitor/accounts@2023-04-03' = {
  name: '${prefix}-prom-ws'
  location: location
  tags: {
    Component: 'Managed-Prometheus'
    ScaleTarget: '100K-Sandboxes'
  }
}

// 2. Azure Managed Grafana (Unified GenAI + eBPF Security Dashboards)
resource managedGrafana 'Microsoft.Dashboard/grafana@2023-09-01' = {
  name: '${prefix}-grafana'
  location: location
  sku: {
    name: 'Standard'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: 'Disabled'
    zoneRedundancy: 'Enabled'
     grafanaIntegrations: {
      azureMonitorWorkspaceIntegrations: [
        {
          azureMonitorWorkspaceResourceId: monitorWorkspace.id
        }
      ]
    }
  }
}

// 3. Azure Data Explorer (Kusto) Cluster for OTel GenAI Traces & Tetragon eBPF Audit
resource kustoCluster 'Microsoft.Kusto/clusters@2023-08-15' = {
  name: replace('${prefix}adx', '-', '')
  location: location
  sku: {
    name: 'Standard_E8d_v5'
    tier: 'Standard'
    capacity: 2
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enableStreamingIngest: true
    enableAutoStop: false
    publicNetworkAccess: 'Disabled'
  }
}

// 4. Kusto Database + Schema Scripts (`AgentGenAiTraces` & `TetragonEbpfAuditEvents`)
resource kustoDb 'Microsoft.Kusto/clusters/databases@2023-08-15' = {
  parent: kustoCluster
  name: 'AgentObservabilityDB'
  location: location
  kind: 'ReadWrite'
  properties: {
    softDeletePeriod: 'P${adxSoftDeleteDays}D'
    hotCachePeriod: 'P${adxHotCacheDays}D'
  }
}

resource kustoSchemaScript 'Microsoft.Kusto/clusters/databases/scripts@2023-08-15' = {
  parent: kustoDb
  name: 'init-otel-genai-and-tetragon-tables'
  properties: {
    continueOnErrors: false
    scriptContent: '''
      .create-merge table AgentGenAiTraces (
        Timestamp: datetime,
        TraceId: string,
        SpanId: string,
        TenantId: string,
        EntraAgentId: string,
        UserOid: string,
        SandboxId: string,
        GenAiSystem: string,
        GenAiRequestModel: string,
        GenAiUsageInputTokens: long,
        GenAiUsageOutputTokens: long,
        McpToolName: string,
        LatencyMs: real,
        SamplingDecision: string,
        StatusCode: string
      )

      .alter table AgentGenAiTraces policy streamingingestion enable

      .create-merge table TetragonEbpfAuditEvents (
        Timestamp: datetime,
        NodeName: string,
        SandboxId: string,
        EntraAgentId: string,
        SyscallName: string,
        BinaryPath: string,
        CommandArgs: string,
        DestinationIp: string,
        DestinationPort: int,
        EnforcementAction: string,
        Severity: string
      )

      .alter table TetragonEbpfAuditEvents policy streamingingestion enable
    '''
  }
}

output prometheusQueryEndpoint string = monitorWorkspace.properties.metrics.prometheusQueryEndpoint
output kustoUri string = kustoCluster.properties.uri
output kustoDataIngestionUri string = kustoCluster.properties.dataIngestionUri
