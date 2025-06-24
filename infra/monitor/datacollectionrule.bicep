param location string = resourceGroup().location
param dataCollectionRuleName string
param dataCollectionEndpointID string
param workspaceName string
param workspaceResourceID string
param customTableName string

resource dataCollectionRule 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  name: dataCollectionRuleName
  location: location
  properties: {
    dataCollectionEndpointId: dataCollectionEndpointID
    streamDeclarations: {
      'Custom-TDDTable': {
        columns: [
          {
            name: 'TimeStamp'
            type: 'datetime'
          }
          {
            name: 'HostName'
            type: 'string'
          }
          {
            name: 'EventMessage'
            type: 'dynamic'
          }
        ]
      }
    }
    dataSources: {}
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: workspaceResourceID
          name: workspaceName
        }
      ]
    }
    dataFlows: [
      {
        streams: [
          'Custom-TDDTable'
        ]
        destinations: [
          workspaceName
        ]
        transformKql: 'source\n| extend TimeGenerated = TimeStamp\n| project-away TimeStamp\n'
        outputStream: 'Custom-${customTableName}'
      }
      {
        streams: [
          'Custom-TDDTable'
        ]
        destinations: [
          workspaceName
        ]
        transformKql: 'source\n| extend TimeGenerated = TimeStamp, Computer = HostName, SyslogMessage = tostring(EventMessage)\n| project-away TimeStamp, EventMessage\n'
        outputStream: 'Microsoft-Syslog'
      }
    ]
  }
}

output dataCollectionRuleID string = dataCollectionRule.id
output dataCollectionImmutableId string = dataCollectionRule.properties.immutableId
