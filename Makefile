include config.mk

# Azure Front Door
build-afd:
	@bicep build $(AFD_BICEP) --outdir $(AFD_OUT)
	@az deployment group what-if \
	--resource-group $(RG_NAME) \
  	--template-file $(AFD_BICEP)

deploy-afd:
	@az deployment group create \
	--mode "Complete" \
	--name $(DEPLOYMENT_NAME) \
	--resource-group $(RG_NAME) \
	--template-file $(AFD_BICEP) 

# AIB
# Azure Front Door
build-aib:
	@bicep build $(AIB_BICEP) --outdir $(AIB_OUT)
	@az deployment group what-if \
	--resource-group $(RG_NAME) \
  	--template-file $(AIB_BICEP)

deploy-aib:
	@az deployment group create \
	--mode "Complete" \
	--name $(DEPLOYMENT_NAME) \
	--resource-group $(RG_NAME) \
	--template-file $(AIB_BICEP) 

# Web Application
build-web-app:
	@bicep build $(WEB_APP_BICEP) --outdir $(WEB_APP_OUT)

# Web Application Multi-tenant
build-web-app-multi:
	@bicep build $(WEB_APP_MULTI_BICEP) --outdir $(WEB_APP_MULTI_OUT)

deploy-web-app-multi:
	@az deployment group create \
	--mode "Complete" \
	--name $(DEPLOYMENT_NAME) \
	--resource-group $(RG_NAME) \
	--template-file $(WEB_APP_MULTI_BICEP) 
# VMSS
build-vmss:
	@bicep build $(VMSS_BICEP) --outdir $(VMSS_OUT)
	@az deployment group what-if \
	--resource-group $(RG_NAME) \
  	--template-file $(VMSS_BICEP)

deploy-vmss:
	@az deployment group create \
	--name $(DEPLOYMENT_NAME) \
	--resource-group $(RG_NAME) \
	--template-file $(VMSS_BICEP) 

deploy-vmss-complete:
	@az deployment group create \
	--mode "Complete" \
	--name $(DEPLOYMENT_NAME) \
	--resource-group $(RG_NAME) \
	--template-file $(VMSS_BICEP) 

# AKV
build-akv:
	@bicep build $(AKV_BICEP) --outdir $(AKV_OUT)
	@az deployment group what-if \
	--resource-group $(RG_NAME) \
  	--template-file $(AKV_BICEP)

deploy-akv:
	@az deployment group create \
	--name $(DEPLOYMENT_NAME) \
	--resource-group $(RG_NAME) \
	--template-file $(AKV_BICEP) 

# Redis
build-redis:
	@bicep build src/module/redis/main.bicep --outdir build/module/redis/

deploy-redis: connect
	@az deployment group create \
  --name $(DEPLOYMENT_NAME) \
  --resource-group $(RG_NAME) \
  --template-file $(REDIS_BICEP)



# SQL
build-sql: connect
	@bicep build $(SQL_DB_BICEP) --outdir $(SQL_DB_OUT)
	@az deployment group what-if \
	--resource-group $(RG_NAME) \
  	--template-file $(SQL_DB_BICEP)

deploy-sql: connect
	@az deployment group create \
  --name $(DEPLOYMENT_NAME) \
  --resource-group $(RG_NAME) \
  --template-file $(SQL_DB_BICEP)

# ACR
login-acr: connect
	@az acr login \
	--name $(ACR_NAME) \
	--expose-token

publish-acr: login-acr
	@az bicep publish \
	--file $(REDIS_BICEP) \
	--target br:$(ACR_LOGIN_SERVER)/bicep/modules/redis:v1

build-acr:
	@bicep build src/module/acr/main.bicep --outdir build/module/acr/
	@az deployment group what-if \
	--resource-group $(RG_NAME) \
  	--template-file $(ACR_BICEP)

deploy-acr: connect
	@az deployment group create \
  --name $(DEPLOYMENT_NAME) \
  --resource-group $(RG_NAME) \
  --template-file $(ACR_BICEP)

# Service Principle
create-sp:
	@az ad sp create-for-rbac \
	--name $(APP_NAME) \
	--keyvault $(AKV_NAME) \
	--cert $(CERT_NAME) \
	--create-cert

# Build all
build: prep build-web-app build-redis

# Connect to Azure
login:
	@az login

connect: login
	@az account set --subscription $(SUBSCRIPTION_ID)
	@az account list --query "[?isDefault]"

context: 
	@az account list --query "[?isDefault]"

# Prep
prep:
	for directory in $(LIST); do \
		mkdir -p $$directory; \
	done

# Cleanup
clean:
	@find build -name "*.json" -delete




# AZ CLI
upgrade-az-azcli:
	@apt-get install \
	--only-upgrade -y azure-cli

upgrade-az-bicep:
	@az bicep upgrade

create-rg:
	@az group create \
	--name $(RG_NAME) \
	--location $(LOCATION)

# Unit testing
# LIST= 1 2 3 \
# 4 5 6 7 8 \
# 9 10
target:
	for i in $(LIST) ; do \
		echo $$i ; \
	done