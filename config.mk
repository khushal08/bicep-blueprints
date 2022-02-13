SUBSCRIPTION_ID = "Microsoft Azure Sponsorship 1"
RG_NAME = "akv-rg"
LOCATION = "australiaeast"
DEPLOYMENT_NAME = "webapp03deploy01"
REDIS_BICEP = "src/module/redis/main.bicep"
ACR_BICEP = "src/module/acr/main.bicep"
ACR_LOGIN_SERVER = "acrsqe7vbnbojqzy.azurecr.io"
ACR_NAME = "acrsqe7vbnbojqzy"
USER = "khushal08@khushal08.onmicrosoft.com"
SQL_DB_BICEP = "src/module/sql-database/main.bicep"
SQL_DB_OUT = "build/module/sql-database/"
CERT_NAME = "webapp03spcert"
APP_NAME = "webapp03sp"
# AKV
AKV_NAME = "oneclouddemoakv01"
AKV_BICEP = "src/module/akv/main.bicep"
AKV_OUT = "build/module/akv/"
# Web App
WEB_APP_OUT = "build/module/web-app/"
WEB_APP_BICEP = "src/module/web-app/main.bicep"
# Web App Multi-tenant
WEB_APP_MULTI_OUT = "build/module/web-app-multitenant/"
WEB_APP_MULTI_BICEP = "src/module/web-app-multitenant/main.bicep"
# VMSS
VMSS_NAME = "testvmss01"
VMSS_BICEP = "src/module/vmss/main.bicep"
VMSS_OUT = "build/module/vmss/"

# AIB
AIB_OUT = "build/module/aib/"
AIB_BICEP = "src/module/aib/main.bicep"

# AFD
AFD_BICEP = "src/module/afd/main.bicep"
AFD_OUT = "build/module/afd/"

# Prep
LIST = 	$(WEB_APP_OUT) \
build/module/virtual-network/ \
build/module/asev2/ build/module/asev3/ \
build/module/app-service-plan/ \
build/module/redis/ \
build/module/acr/ \
$(SQL_DB_OUT) \
$(AKV_OUT) \
$(VMSS_OUT) \
$(WEB_APP_MULTI_OUT) \
$(AFD_OUT) \
$(AIB_OUT)