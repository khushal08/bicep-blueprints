param envCode string

var baseConfig = json(loadTextContent('../config/base-config.json'))
var devConfig = envCode == 'dev' ? json(loadTextContent('../config/dev-config.json')): json('{}')
var prodConfig = envCode == 'prod' ? json(loadTextContent('../config/prod-config.json')): json('{}')
var uatConfig = envCode == 'non-prod' ? json(loadTextContent('../config/non-prod-config.json')): json('{}')
var envConfig = ((envCode == 'dev') ? devConfig: (envCode == 'prod' ? prodConfig: uatConfig))
var config = union(baseConfig, envConfig)

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: config.vnet.name
  location: resourceGroup().location
  properties:  
  config.vnet.properties
}

