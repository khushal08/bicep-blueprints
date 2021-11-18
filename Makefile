
SUBSCRIPTION_ID = "XXXXXXXXXX"
RG_NAME = "webapp03"
DEPLOYMENT_NAME = "webapp03deploy01"
REDIS_BICEP = "src/module/redis/main.bicep"

PHONY: build-web-app
build-web-app:
	@bicep build src/module/web-app/main.bicep --outdir build/module/web-app/

PHONY: build-redis
build-redis:
	@bicep build src/module/redis/main.bicep --outdir build/module/redis/

PHONY: clean
clean:
	@find build -name "*.json" -delete

PHONY: build
build: prep build-web-app build-redis

PHONY: prep
prep:
	@mkdir -p build/module/web-app/
	@mkdir -p build/module/virtual-network/
	@mkdir -p build/module/asev2/
	@mkdir -p build/module/asev3/
	@mkdir -p build/module/app-service-plan/
	@mkdir -p build/module/redis/

PHONY: login
login:
	@az login

PHONY: setsubscription
setsubscription: login
	@az account set --subscription $(SUBSCRIPTION_ID)
	@az account list --query "[?isDefault]"

PHONY: deploy-redis
deploy-redis: setsubscription
	@az deployment group create \
  --name $(DEPLOYMENT_NAME) \
  --resource-group $(RG_NAME) \
  --template-file $(REDIS_BICEP)