# main.tf for github.com/rhernand1/my-ngfw-caller (This is the intermediate module)

# --- Provider Configuration ---
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.30.0"
    }
  }
}

# This provider block will be configured by the parent module (your local root)
# and its configuration will be passed down to nested modules via the 'providers' meta-argument.
provider "azurerm" {
  features {}
}

# --- Input Variables for THIS Module (my-ngfw-caller) ---
variable "subscription_id" { # This variable still accepts input from the local root caller
  description = "The Azure Subscription ID to deploy resources into."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the Azure Resource Group for the Cloud NGFW."
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be deployed."
  type        = string
}

variable "firewall_name" {
  description = "The name of the Palo Alto Networks Cloud NGFW instance."
  type        = string
}

variable "vnet_name" {
  description = "The name of the Virtual Network (VNet) for the NGFW interfaces."
  type        = string
}

variable "vnet_address_space" {
  description = "The address space (CIDR) for the VNet."
  type        = list(string)
}

variable "untrusted_subnet_name" {
  description = "The name of the untrusted subnet for the NGFW interface."
  type        = string
}

variable "untrusted_subnet_prefix" {
  description = "The address prefix (CIDR) for the untrusted subnet."
  type        = string
}

variable "trusted_subnet_name" {
  description = "The name of the trusted subnet for the NGFW interface."
  type        = string
}

variable "trusted_subnet_prefix" {
  description = "The address prefix (CIDR) for the trusted subnet."
  type        = string
}

variable "management_subnet_name" {
  description = "The name of the management subnet for the NGFW interface (optional)."
  type        = string
}

variable "management_subnet_prefix" {
  description = "The address prefix (CIDR) for the management subnet (optional)."
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to all deployed resources."
  type        = map(string)
}


# --- Module Call (to AzureCloudNGFW) ---
module "cloud_ngfw_deployment" {
  source = "github.com/rhernand1/AzureCloudNGFW?ref=main"

  # Pass provider configuration to the nested module.
  # This maps the 'azurerm' provider within this module to the 'azurerm'
  # provider of the 'AzureCloudNGFW' module, effectively passing the subscription_id.
  providers = {
    azurerm = azurerm # This links the provider from the calling module (my-ngfw-caller)
                      # to the called module (AzureCloudNGFW).
  }

  resource_group_name    = var.resource_group_name
  location               = var.location
  firewall_name          = var.firewall_name
  vnet_name              = var.vnet_name
  vnet_address_space     = var.vnet_address_space
  untrusted_subnet_name  = var.untrusted_subnet_name
  untrusted_subnet_prefix = var.untrusted_subnet_prefix
  trusted_subnet_name    = var.trusted_subnet_name
  trusted_subnet_prefix  = var.trusted_subnet_prefix
  management_subnet_name = var.management_subnet_name
  management_subnet_prefix = var.management_subnet_prefix
  tags                   = var.tags
}

# --- Outputs from THIS Module (my-ngfw-caller) ---
output "cloud_ngfw_name" {
  description = "The name of the Cloud NGFW deployed by this module."
  value       = module.cloud_ngfw_deployment.cloud_ngfw_name
}

output "cloud_ngfw_ingress_ip" {
  description = "The ingress public IP of the Cloud NGFW deployed by this module."
  value       = module.cloud_ngfw_deployment.cloud_ngfw_public_ip_ingress
}

output "cloud_ngfw_egress_ip" {
  description = "The egress public IP of the Cloud NGFW deployed by this module."
  value       = module.cloud_ngfw_deployment.cloud_ngfw_public_ip_egress
}
