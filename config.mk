SUBSCRIPTION_ID = "Microsoft Azure Sponsorship 1"
RG_NAME = "webapp-rg"
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
AKV_NAME = "webapp03spakv"
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
