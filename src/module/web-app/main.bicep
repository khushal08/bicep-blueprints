param envCode string

var baseConfig = json(loadTextContent('../../../config/base-config.json'))
var devConfig = envCode == 'dev' ? json(loadTextContent('../../../config/dev-config.json')): json('{}')
var prodConfig = envCode == 'prod' ? json(loadTextContent('../../../config/prod-config.json')): json('{}')
var uatConfig = envCode == 'non-prod' ? json(loadTextContent('../../../config/non-prod-config.json')): json('{}')
var envConfig = ((envCode == 'dev') ? devConfig: (envCode == 'prod' ? prodConfig: uatConfig))
var config = union(baseConfig, envConfig)

resource webappWebsite 'Microsoft.Web/sites@2020-06-01' = {
  name: config.webapp.name
  location: resourceGroup().location
  tags: config.webapp.tags
  properties: config.webapp.properties
}

output webappWebsiteName string = webappWebsite.name
output webappWebsiteId string = webappWebsite.id
output webappWebsiteHostname array = webappWebsite.properties.hostNames
output webappWebsiteState string = webappWebsite.properties.state
output webappWebsiteResourceGroup string = resourceGroup().name
output webappWebsitePlanName string = webappWebsite.properties.serverFarmId
output webappWebsitePlanId string = webappWebsite.properties.serverFarmId
