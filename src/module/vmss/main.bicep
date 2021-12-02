@description('SSH Key or password for the Virtual Machine. SSH key is recommended.')
@secure()
param adminPasswordOrKey string

@description('Admin username on all VMs.')
param adminUsername string

@description('Type of authentication to use on the Virtual Machine. SSH key is recommended.')
@allowed([
  'sshPublicKey'
  'password'
])
param authenticationType string = 'password'

@description('Number of VM instances (16 or less).')
@minValue(1)
@maxValue(16)
param instanceCount int = 1

@description('Location for resources. Default is the current resource group location.')
param location string = resourceGroup().location

@description('Length of public IP prefix.')
@allowed([
  28
  29
  30
  31
])
param publicIPPrefixLength int = 28

@description('Size of VMs in the VM Scale Set.')
param vmSku string = 'Standard_D2_v3'

@description('String used as a base for naming resources (9 characters or less). A hash is prepended to this string for some resources, and resource-specific information is appended.')
@maxLength(9)
param vmssName string

@description('String used as a base for naming resources (9 characters or less). A hash is prepended to this string for some resources, and resource-specific information is appended.')
@maxLength(15)
param vmssScalingName string

@description('Max VMs')
@allowed([
  '1'
  '2'
  '3'
  '4'
])
param scalingCapMax string = '3'

@description('Min VMs')
@allowed([
  '1'
])
param scalingCapMin string = '1'

@description('String used to connect to your VMSS VM using dnsName.location.cloudapp.azure.com (must be globally unique)')
@minLength(3)
@maxLength(61)
param dnsName string

var linuxConfiguration = {
  disablePasswordAuthentication: true
  ssh: {
    publicKeys: [
      {
        path: '/home/${adminUsername}/.ssh/authorized_keys'
        keyData: adminPasswordOrKey
      }
    ]
  }
}
var osType = {
  publisher: 'Canonical'
  offer: 'UbuntuServer'
  sku: '18.04-LTS'
  version: 'latest'
}
var imageReference = osType
var publicIPAddressName = '${vmssName}pip'
var publicIPPrefixName = '${vmssName}pubipprefix'
var virtualNetworkName = '${vmssName}vnet'
var subnetName = '${vmssName}subnet'
var addressPrefix = '10.0.0.0/16'
var subnetPrefix = '10.0.0.0/24'
var loadBalancerName = '${vmssName}lb'
var natPoolName = '${vmssName}natpool'
var natStartPort = 50000
var natEndPort = 50120
var natBackendPort = 22
var bePoolName = '${vmssName}bepool'
var nicName = '${vmssName}nic'
var ipConfigName = '${vmssName}ipconfig'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
        }
      }
    ]
  }
}

resource publicIPPrefix 'Microsoft.Network/publicIPPrefixes@2021-02-01' = {
  name: publicIPPrefixName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    prefixLength: publicIPPrefixLength
    publicIPAddressVersion: 'IPv4'
  }
}

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: publicIPAddressName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: dnsName
    }
  }
}

resource loadBalancer 'Microsoft.Network/loadBalancers@2020-05-01' = {
  name: loadBalancerName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: 'LoadBalancerFrontEnd'
        properties: {
          publicIPAddress: {
            id: publicIPAddress.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: bePoolName
      }
    ]
    inboundNatPools: [
      {
        name: natPoolName
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', loadBalancerName, 'loadBalancerFrontEnd')
          }
          protocol: 'Tcp'
          frontendPortRangeStart: natStartPort
          frontendPortRangeEnd: natEndPort
          backendPort: natBackendPort
        }
      }
    ]
  }
}

resource autoScaleSettings 'microsoft.insights/autoscalesettings@2015-04-01' = {
  name: vmssScalingName
  location: location
  properties: {
    targetResourceUri: vmss.id
    enabled: false
    profiles: [
      {
        name: 'Week Day'
        capacity: {
          minimum: scalingCapMax
          maximum: scalingCapMax
          default: scalingCapMax
        }
        rules: []
        recurrence: {
          frequency: 'Week'
          schedule: {
            timeZone: 'AUS Eastern Standard Time'
            days: [
              'Monday'
              'Tuesday'
              'Wednesday'
              'Thursday'
              'Friday'
            ]
            hours: [
              7
            ]
            minutes: [
              0
            ]
          }
        }
      }
      {
        name: 'Week Night'
        capacity: {
          minimum: scalingCapMin
          maximum: scalingCapMin
          default: scalingCapMin
        }
        rules: []
        recurrence: {
          frequency: 'Week'
          schedule: {
            timeZone: 'AUS Eastern Standard Time'
            days: [
              'Monday'
              'Tuesday'
              'Wednesday'
              'Thursday'
              'Friday'
            ]
            hours: [
              1
            ]
            minutes: [
              0
            ]
          }
        }
      }
      {
        name: 'Weekend'
        capacity: {
          minimum: scalingCapMin
          maximum: scalingCapMin
          default: scalingCapMin
        }
        rules: []
        recurrence: {
          frequency: 'Week'
          schedule: {
            timeZone: 'AUS Eastern Standard Time'
            days: [
              'Saturday'
              'Sunday'
            ]
            hours: [
              1
            ]
            minutes: [
              0
            ]
          }
        }
      }
      {
        name: 'CPU Metric'
        capacity: {
          minimum: scalingCapMin
          maximum: scalingCapMax
          default: scalingCapMin
        }
        rules: [
          {
            scaleAction: {
              direction: 'Increase'
              type: 'ChangeCount'
              value: '2'
              cooldown: 'PT5M'
            }
            metricTrigger: {
              metricName: 'Percentage CPU'
              metricNamespace: 'microsoft.compute/virtualmachinescalesets'
              metricResourceUri: vmss.id
              operator: 'GreaterThan'
              statistic: 'Average'
              threshold: 70
              timeAggregation: 'Average'
              timeGrain: 'PT1M'
              timeWindow: 'PT10M'
              dimensions: []
              dividePerInstance: false
            }
          }
          {
            scaleAction: {
              direction: 'Decrease'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT5M'
            }
            metricTrigger: {
              metricName: 'Percentage CPU'
              metricNamespace: 'microsoft.compute/virtualmachinescalesets'
              metricResourceUri: vmss.id
              operator: 'LessThan'
              statistic: 'Average'
              threshold: 40
              timeAggregation: 'Average'
              timeGrain: 'PT1M'
              timeWindow: 'PT10M'
              dimensions: []
              dividePerInstance: false
            }
          }
        ]
        recurrence: {
          frequency: 'Week'
          schedule: {
            timeZone: 'AUS Eastern Standard Time'
            days: [
              'Monday'
              'Tuesday'
              'Wednesday'
              'Thursday'
              'Friday'
            ]
            hours: [
              7
            ]
            minutes: [
              0
            ]
          }
        }
      }
    ]
  }
}

resource vmss 'Microsoft.Compute/virtualMachineScaleSets@2020-06-01' = {
  name: vmssName
  location: location
  sku: {
    name: vmSku
    tier: 'Standard'
    capacity: instanceCount
  }
  properties: {
    overprovision: false
    upgradePolicy: {
      mode: 'Manual'
    }
    virtualMachineProfile: {
      storageProfile: {
        osDisk: {
          caching: 'ReadOnly'
          createOption: 'FromImage'
        }
        imageReference: imageReference
      }
      osProfile: {
        computerNamePrefix: vmssName
        adminUsername: adminUsername
        adminPassword: adminPasswordOrKey
        linuxConfiguration: ((authenticationType == 'password') ? json('null') : linuxConfiguration)
      }
      networkProfile: {
        networkInterfaceConfigurations: [
          {
            name: nicName
            properties: {
              primary: true
              ipConfigurations: [
                {
                  name: ipConfigName
                  properties: {
                    subnet: {
                      id: '${virtualNetwork.id}/subnets/${subnetName}'
                    }
                    publicIPAddressConfiguration: {
                      name: 'pub1'
                      properties: {
                        idleTimeoutInMinutes: 15
                        publicIPPrefix: {
                          id: publicIPPrefix.id
                        }
                      }
                    }
                    loadBalancerBackendAddressPools: [
                      {
                        id: '${loadBalancer.id}/backendAddressPools/${bePoolName}'
                      }
                    ]
                    loadBalancerInboundNatPools: [
                      {
                        id: '${loadBalancer.id}/inboundNatPools/${natPoolName}'
                      }
                    ]
                  }
                }
              ]
            }
          }
        ]
      }
    }
  }
}
