application_name    = "sonarqube"
line_of_business    = "corp"
business_unit       = "enterprise-application-platforms"
parent_ci_id        = "P058694663"
resource_group_name = "Corp-SonarQubeEnterprise-AppResources-DevTest"
environment         = "devtest"
region              = "eastus2"
tags = {
  BusinessOwner  = "ps327250"
  TechnicalOwner = "txz1542"
}

#azure postgresql db & server
postgres_server_sku_name = "GP_Gen5_2"
db_storage               = "51200"
backup_retention_days    = "10"
