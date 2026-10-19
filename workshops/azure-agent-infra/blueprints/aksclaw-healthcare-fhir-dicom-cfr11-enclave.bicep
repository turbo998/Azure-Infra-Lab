// ============================================================================
// Blueprint #35: Regulated Healthcare & Clinical Trial Agent Infrastructure
// Provisions:
//   1. Azure Health Data Services Workspace + FHIR R4 Service + DICOM Medical Imaging Service
//   2. Confidential GPU Agent Nodepool (`Standard_NCC40ads_H100_v5`) with Presidio FPE PHI Vault Labels
//   3. FDA 21 CFR Part 11 Non-Repudiable Dual-Signature Audit Policy Tags
// ============================================================================

@description('Deployment region')
param location string = resourceGroup().location

@description('Environment prefix')
param envPrefix string = 'aksclaw-med'

@description('Existing AKS cluster name')
param aksClusterName string = 'aks-aksclaw-prod'

@description('Entra Tenant ID for SMART-on-FHIR RBAC')
param tenantId string = subscription().tenantId

// 1. Azure Health Data Services Workspace
resource healthWorkspace 'Microsoft.HealthcareApis/workspaces@2023-12-01' = {
  name: replace('${envPrefix}ahdsws', '-', '')
  location: location
  properties: {
    publicNetworkAccess: 'Disabled'
  }
}

// 2. FHIR R4 Service with SMART-on-FHIR Authority
resource fhirService 'Microsoft.HealthcareApis/workspaces/fhirservices@2023-12-01' = {
  parent: healthWorkspace
  name: 'fhir-r4'
  location: location
  kind: 'fhir-R4'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    authenticationConfiguration: {
      authority: '${environment().authentication.loginEndpoint}${tenantId}'
      audience: 'https://${healthWorkspace.name}-fhir-r4.fhir.azurehealthcareapis.com'
      smartProxyEnabled: true
    }
  }
}

// 3. DICOMweb Medical Imaging Service
resource dicomService 'Microsoft.HealthcareApis/workspaces/dicomservices@2023-12-01' = {
  parent: healthWorkspace
  name: 'dicomweb'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
}

// 4. Confidential H100 GPU Agent Pool for MONAI / Clinical Trial Agents + 21 CFR Part 11 Enclave Signing
resource existingAks 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

resource clinicalGpuPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: existingAks
  name: 'medgpupool'
  properties: {
    count: 4
    vmSize: 'Standard_NCC40ads_H100_v5'
    osType: 'Linux'
    osSKU: 'Ubuntu'
    mode: 'User'
    workloadRuntime: 'KataMshvVmIsolation'
    nodeLabels: {
      'aksclaw.io/clinical-fhir-cast': 'dicomweb-nifti-zerocopy'
      'aksclaw.io/phi-deid-gateway': 'presidio-biobert-fpe-safe-harbor'
      'aksclaw.io/fda-compliance': '21-cfr-part-11-dual-hsm-signature'
    }
  }
}

output healthWorkspaceId string = healthWorkspace.id
output fhirServiceId string = fhirService.id
output dicomServiceId string = dicomService.id
