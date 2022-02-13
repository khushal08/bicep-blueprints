@description('The Azure region where resources in the template should be deployed.')
param location string = resourceGroup().location

@description('Name of the user-assigned managed identity used by Azure Image Builder template, and for triggering the Azure Image Builder build at the end of the deployment')
param templateIdentityName string = substring('ImageGallery_${guid(resourceGroup().id)}', 0, 21)

@description('Permissions to allow for the user-assigned managed identity.')
param templateIdentityRoleDefinitionName string = guid(resourceGroup().id)

@description('Name of the new Azure Image Gallery resource.')
param imageGalleryName string = substring('ImageGallery_${guid(resourceGroup().id)}', 0, 21)

@description('Detailed image information to set for the custom image produced by the Azure Image Builder build.')
param imageDefinitionProperties object = {
  name: 'UbuntuServer18LTS'
  publisher: 'Canonical'
  offer: 'UbuntuServer'
  sku: '18.04-LTS'
}

@description('Name of the template to create in Azure Image Builder.')
param imageTemplateName string = 'UbuntuServer_18.04LTS_Baseline_Template'

@description('Name of the custom iamge to create and distribute using Azure Image Builder.')
param runOutputName string = 'UbuntuServer_18.04LTS_Baseline_CustomImage'

@description('List the regions in Azure where you would like to replicate the custom image after it is created.')
param replicationRegions array = [
  'australiaeast'
]

var templateIdentityRoleAssignmentName = guid(templateIdentity.id, resourceGroup().id, templateIdentityRoleDefinition.id)

resource templateIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: templateIdentityName
  location: location
}

resource templateIdentityRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' = {
  name: templateIdentityRoleDefinitionName
  properties: {
    roleName: templateIdentityRoleDefinitionName
    description: 'Used for AIB template and ARM deployment script that runs AIB build'
    type: 'customRole'
    permissions: [
      {
        actions: [
          'Microsoft.Compute/galleries/read'
          'Microsoft.Compute/galleries/images/read'
          'Microsoft.Compute/galleries/images/versions/read'
          'Microsoft.Compute/galleries/images/versions/write'
          'Microsoft.Compute/images/read'
          'Microsoft.Compute/images/write'
          'Microsoft.Compute/images/delete'
          'Microsoft.Storage/storageAccounts/blobServices/containers/read'
          'Microsoft.Storage/storageAccounts/blobServices/containers/write'
          'Microsoft.ContainerInstance/containerGroups/read'
          'Microsoft.ContainerInstance/containerGroups/write'
          'Microsoft.ContainerInstance/containerGroups/start/action'
          'Microsoft.Resources/deployments/read'
          'Microsoft.Resources/deploymentScripts/read'
          'Microsoft.Resources/deploymentScripts/write'
          'Microsoft.VirtualMachineImages/imageTemplates/run/action'
        ]
      }
    ]
    assignableScopes: [
      resourceGroup().id
    ]
  }
}

// 2019-04-01-preview,2020-03-01-preview,2020-04-01-preview,2020-08-01-preview,2021-04-01-preview
resource templateRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: templateIdentityRoleAssignmentName
  properties: {
    roleDefinitionId: templateIdentityRoleDefinition.id
    principalId: templateIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource imageGallery 'Microsoft.Compute/galleries@2020-09-30' = {
  name: imageGalleryName
  location: location
  properties: {}
}

resource imageDefinition 'Microsoft.Compute/galleries/images@2020-09-30' = {
  parent: imageGallery
  name: imageDefinitionProperties.name
  location: location
  properties: {
    osType: 'Linux'
    osState: 'Generalized'
    identifier: {
      publisher: imageDefinitionProperties.publisher
      offer: imageDefinitionProperties.offer
      sku: imageDefinitionProperties.sku
    }
    recommended: {
      vCPUs: {
        min: 2
        max: 8
      }
      memory: {
        min: 16
        max: 48
      }
    }
    hyperVGeneration: 'V1'
  }
}

resource imageTemplate 'Microsoft.VirtualMachineImages/imageTemplates@2020-02-14' = {
  name: imageTemplateName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${templateIdentity.id}': {}
    }
  }
  properties: {
    buildTimeoutInMinutes: 60
    vmProfile: {
      vmSize: 'Standard_D1_v2'
      osDiskSizeGB: 30
    }
    source: {
      type: 'PlatformImage'
      publisher: 'Canonical'
      offer: 'UbuntuServer'
      sku: '18.04-LTS'
      version: 'latest'
    }
    customize: [
      {
        type: 'Shell'
        name: 'RunScriptFromSource'
        scriptUri: 'https://raw.githubusercontent.com/danielsollondon/azvmimagebuilder/master/quickquickstarts/customizeScript.sh'
      }
      {
        type: 'Shell'
        name: 'CheckSumCompareShellScript'
        scriptUri: 'https://raw.githubusercontent.com/danielsollondon/azvmimagebuilder/master/quickquickstarts/customizeScript2.sh'
        sha256Checksum: 'ade4c5214c3c675e92c66e2d067a870c5b81b9844b3de3cc72c49ff36425fc93'
      }
      {
        type: 'File'
        name: 'downloadBuildArtifacts'
        sourceUri: 'https://raw.githubusercontent.com/danielsollondon/azvmimagebuilder/master/quickquickstarts/exampleArtifacts/buildArtifacts/index.html'
        destination:'/tmp/index.html'
      }
      {
        type: 'Shell'
        name: 'setupBuildPath'
        inline: [
            'sudo mkdir /buildArtifacts'
            'sudo cp /tmp/index.html /buildArtifacts/index.html'
        ]
      }
      {
        type: 'Shell'
        name: 'InstallUpgrades'
        inline: [
            'sudo apt install unattended-upgrades'
        ]
      }
    ]
    distribute: [
      {
        type: 'SharedImage'
        galleryImageId: imageDefinition.id
        runOutputName: runOutputName
        replicationRegions: replicationRegions
      }
    ]
  }
}
