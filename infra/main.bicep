targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

// Tags that should be applied to all resources.
// 
// Note that 'azd-service-name' tags should be applied separately to service host resources.
// Example usage:
//   tags: union(tags, { 'azd-service-name': <service name in azure.yaml> })
var tags = {
  'azd-env-name': environmentName
}
// var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))

// This deploys the Resource Group
resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${environmentName}'
  location: location
  tags: tags
}

// Add resources to be provisioned below.
module logAnalytics './monitor/loganalytics.bicep' = {
  name: 'resources'
  scope: rg
  params: {
    name: 'law-tdd-monitor'
    customTableName: 'CustomEvents_CL'
    location: location
    tags: tags
  }
}

module applicationInsights './monitor/applicationinsights.bicep' = {
  name: 'applicationInsights'
  scope: rg
  params: {
    name: 'appinsights-tdd-monitor'
    location: location
    tags: tags
    logAnalyticsWorkspaceId: logAnalytics.outputs.id
  }
}

module dataCollectionEndpoint './monitor/datacollectionendpoint.bicep' = {
  name: 'dataCollectionEndpoint'
  scope: rg
  params: {
    location: location
    dataCollectionEndpointName: 'dce-tdd-logs-ingestion'
  }
}

module dataCollectionRule './monitor/datacollectionrule.bicep' = {
  name: 'dataCollectionRule'
  scope: rg
  params: {
    location: location
    dataCollectionRuleName: 'dcr-tdd-monitor'
    dataCollectionEndpointID: dataCollectionEndpoint.outputs.dataCollectionEndpointId
    workspaceName: logAnalytics.outputs.name
    workspaceResourceID: logAnalytics.outputs.id
    customTableName: logAnalytics.outputs.customTableName
  }
}

// Add outputs from the deployment here, if needed.
//
// This allows the outputs to be referenced by other bicep deployments in the deployment pipeline,
// or by the local machine as a way to reference created resources in Azure for local development.
// Secrets should not be added here.
//
// Outputs are automatically saved in the local azd environment .env file.
// To see these outputs, run `azd env get-values`,  or `azd env get-values --output json` for json output.
output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId
output DCR_IMMUTABLE_ID string = dataCollectionRule.outputs.dataCollectionImmutableId
