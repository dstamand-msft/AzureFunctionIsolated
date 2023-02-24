@description('The location of the resources that will be deployed.')
param resourcesLocation string = resourceGroup().location

@description('The suffix that will be appended to the resources.')
param resourcesSuffix string

var storageAccountName = 'strazfuncisodemo${toLower(resourcesSuffix)}'
var functionAppName = 'func-azfuncisodemo-${resourcesSuffix}'
var netFrameworkVersion = 'v7.0'

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: 'la-azfuncisodemo-${resourcesSuffix}'
  location: resourcesLocation
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    features: {
      enableDataExport: true
    }
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'ai-azfuncisodemo-${resourcesSuffix}'
  location: resourcesLocation
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: resourceId('Microsoft.OperationalInsights/workspaces', logAnalytics.name)
  }
  kind: 'web'
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: length(storageAccountName) > 24 ? substring(storageAccountName, 0, 24) : storageAccountName
  location: resourcesLocation
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'Storage'
}

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: 'plan-azfuncisodemo-${resourcesSuffix}'
  location: resourcesLocation
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
}

resource functionApp 'Microsoft.Web/sites@2021-03-01' = {
  name: functionAppName
  location: resourcesLocation
  kind: 'functionapp'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsights.properties.ConnectionString
        }        
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet-isolated'
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '0'
        }        
      ]
      netFrameworkVersion: netFrameworkVersion
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
    }
    httpsOnly: true
  }
}
