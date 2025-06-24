metadata description = 'Creates a Log Analytics workspace with a custom table.'
param name string
param location string = resourceGroup().location
param tags object = {}
param customTableName string
param customTableSchema array = [
  {
    name: 'TimeGenerated'
    type: 'datetime'
    description: 'The time at which the event occurred.'
  }
  {
    name: 'HostName'
    type: 'string'
    description: 'The name of the host generated the event.'
  }
  {
    name: 'EventMessage'
    type: 'dynamic'
    description: 'The data associated with the event.'
  }
]

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: name
  location: location
  tags: tags
  properties: any({
    retentionInDays: 30
    features: {
      searchVersion: 1
    }
    sku: {
      name: 'PerGB2018'
    }
  })
}

resource customTable 'Microsoft.OperationalInsights/workspaces/tables@2022-10-01' = {
  parent: logAnalytics
  name: customTableName
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: customTableName
      columns: customTableSchema
    }
  }
}

output id string = logAnalytics.id
output name string = logAnalytics.name
output customTableName string = customTable.name
