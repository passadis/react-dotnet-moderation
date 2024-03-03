# Create Randomness
resource "random_string" "str-name" {
  length  = 5
  upper   = false
  numeric = false
  lower   = true
  special = false
}

# Create a resource group
resource "azurerm_resource_group" "rgdemo" {
  name     = "rg-webmodapp"
  location = "eastus"
}

# Create Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "logs" {
  name                = "Log${random_string.str-name.result}"
  location            = azurerm_resource_group.rgdemo.location
  resource_group_name = azurerm_resource_group.rgdemo.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Create Application Insights
resource "azurerm_application_insights" "appinsights" {
  name                = "appin${random_string.str-name.result}"
  location            = azurerm_resource_group.rgdemo.location
  resource_group_name = azurerm_resource_group.rgdemo.name
  workspace_id        = azurerm_log_analytics_workspace.logs.id
  application_type    = "web"
}

output "instrumentation_key" {
  value     = azurerm_application_insights.appinsights.instrumentation_key
  sensitive = true
}

output "app_id" {
  value     = azurerm_application_insights.appinsights.app_id
  sensitive = true
}

# Create Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                = "acr${random_string.str-name.result}"
  resource_group_name = azurerm_resource_group.rgdemo.name
  location            = azurerm_resource_group.rgdemo.location
  sku                 = "Standard"
  admin_enabled       = true
}
output "acrname" {
  value = azurerm_container_registry.acr.name
}


# Create a Storage Account 
resource "azurerm_storage_account" "storage" {
  name                     = "s${random_string.str-name.result}01"
  resource_group_name      = azurerm_resource_group.rgdemo.name
  location                 = azurerm_resource_group.rgdemo.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  blob_properties {
    cors_rule {
      allowed_headers    = ["*"]
      allowed_methods    = ["GET", "POST", "PUT"]
      allowed_origins    = ["*"]
      exposed_headers    = ["*"]
      max_age_in_seconds = 3600
    }
  }

}

output "storagename" {
  value = azurerm_storage_account.storage.name
}

# Create a Container
resource "azurerm_storage_container" "blob" {
  name                  = "uploads"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "container"
}

# Create a Container 2
resource "azurerm_storage_container" "blob2" {
  name                  = "content"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "container"
}

# Create Content Safety Resource
resource "azurerm_cognitive_account" "consafety" {
  name                = "safe${random_string.str-name.result}"
  location            = azurerm_resource_group.rgdemo.location
  resource_group_name = azurerm_resource_group.rgdemo.name
  kind                = "ContentSafety"

  sku_name = "S0"

}

# Create an App Service Plan
resource "azurerm_service_plan" "asp" {
  name                = "asp-${random_string.str-name.result}"
  resource_group_name = azurerm_resource_group.rgdemo.name
  location            = azurerm_resource_group.rgdemo.location
  os_type             = "Windows"
  sku_name            = "B2"
}

# Create Storage Account for Function App
resource "azurerm_storage_account" "funcstr" {
  name                     = "func${random_string.str-name.result}"
  resource_group_name      = azurerm_resource_group.rgdemo.name
  location                 = azurerm_resource_group.rgdemo.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create a Function App
resource "azurerm_windows_function_app" "funcapp" {
  name                       = "fapp${random_string.str-name.result}"
  location                   = azurerm_resource_group.rgdemo.location
  resource_group_name        = azurerm_resource_group.rgdemo.name
  service_plan_id            = azurerm_service_plan.asp.id
  storage_account_name       = azurerm_storage_account.funcstr.name
  storage_account_access_key = azurerm_storage_account.funcstr.primary_access_key


  identity {
    type = "SystemAssigned"
  }
  site_config {
    application_stack {
      dotnet_version = "v6.0"
    }
  }
  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"                                    = "dotnet"
    "application_insights_connection_string"                      = azurerm_application_insights.appinsights.connection_string
    "application_insights_key"                                    = azurerm_application_insights.appinsights.instrumentation_key
    "CONTENT_SAFETY_ENDPOINT"                                     = azurerm_cognitive_account.consafety.endpoint
    "CONTENT_SAFETY_KEY"                                          = azurerm_cognitive_account.consafety.primary_access_key
    "AzureWebJobsStorage_${azurerm_storage_account.storage.name}" = azurerm_storage_account.storage.primary_connection_string
  }
}



/*
# Create Azure Container App Environment
resource "azurerm_container_app_environment" "acaenv" {
  name                       = "mgmt-env-apps"
  location                   = azurerm_resource_group.rgdemo.location
  resource_group_name        = azurerm_resource_group.rgdemo.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logs.id
}

 Create Azure Container App
resource "azurerm_container_app" "acapp" {
  name                         = "react"
  container_app_environment_id = azurerm_container_app_environment.acaenv.id
  resource_group_name          = azurerm_resource_group.rgdemo.name
  revision_mode                = "Single"

  template {
    container {
      name   = "react"
      image  = "azcont1.azurecr.io/frontend:v10"
      cpu    = 1
      memory = "2Gi"
    }
  }
}*/
