param location string = resourceGroup().location
param dataCollectionEndpointName string

resource dataCollectionEndpoint 'Microsoft.Insights/dataCollectionEndpoints@2022-06-01' = {
  name: dataCollectionEndpointName
  location: location
  properties: {
    networkAcls: {
      publicNetworkAccess: 'Enabled'
    }
  }
}
output dataCollectionEndpointId string = dataCollectionEndpoint.id
