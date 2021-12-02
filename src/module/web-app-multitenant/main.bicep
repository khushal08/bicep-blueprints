@description('Relative DNS name for the traffic manager profile, resulting FQDN will be <uniqueDnsName> dot trafficmanager dot net, must be globally unique.')
param uniqueDnsName string = 'testdnskhush01'

@description('Relative DNS name for the WebApps, must be globally unique.  An index will be appended for each Web App.')
param uniqueDnsNameForWebApp string = 'testwebappdnskhush01'

@description('Name of the App Service Plan that is being created')
param appServicePlanName string = 'testwebappaspkhush01'
param location string = resourceGroup().location

@description('Name of the trafficManager being created')
param trafficManagerName string = 'testtrafficmanagerkhush01'

resource appServicePlan 'Microsoft.Web/serverFarms@2020-12-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'S1'
    tier: 'Standard'
  }
}

resource webSite 'Microsoft.Web/sites@2020-12-01' = {
  name: uniqueDnsNameForWebApp
  location: location
  properties: {
    serverFarmId: appServicePlan.id
  }
}

resource trafficManagerProfile 'Microsoft.Network/trafficManagerProfiles@2018-08-01' = {
  name: trafficManagerName
  location: 'global'
  properties: {
    profileStatus: 'Enabled'
    trafficRoutingMethod: 'Priority'
    dnsConfig: {
      relativeName: uniqueDnsName
      ttl: 30
    }
    monitorConfig: {
      protocol: 'HTTPS'
      port: 443
      path: '/'
    }
    endpoints: [
      {
        name: uniqueDnsNameForWebApp
        type: 'Microsoft.Network/trafficManagerProfiles/azureEndpoints'
        properties: {
          targetResourceId: webSite.id
          endpointStatus: 'Enabled'
        }
      }
    ]
  }
}
