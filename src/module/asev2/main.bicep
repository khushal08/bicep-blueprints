param envCode string

var baseConfig = json(loadTextContent('../../../config/base-config.json'))
var devConfig = envCode == 'dev' ? json(loadTextContent('../../../config/dev-config.json')): json('{}')
var prodConfig = envCode == 'prod' ? json(loadTextContent('../../../config/prod-config.json')): json('{}')
var uatConfig = envCode == 'non-prod' ? json(loadTextContent('../../../config/non-prod-config.json')): json('{}')
var envConfig = ((envCode == 'dev') ? devConfig: (envCode == 'prod' ? prodConfig: uatConfig))
var config = union(baseConfig, envConfig)

resource asev2HostingEnvironment 'Microsoft.Web/hostingEnvironments@2021-02-01' = {
  name: config.asev2.name
  location: resourceGroup().location
  kind: config.asev2.kind
  tags: config.asev2.tags
  properties: config.asev2.properties
}

