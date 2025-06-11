# main.tf for github.com/rhernand1/my-ngfw-caller (this is the module)

# --- Provider Configuration ---
# Specifies the required AzureRM provider for this module.
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0" # Ensure this matches or is compatible with the module's requirement
    }
  }
}

# Configures the AzureRM provider for this module.
provider "azurerm" {
  features {}
}

# --- Input Variables for THIS Module ---
# These variables define the inputs that this 'my-ngfw-caller' module accepts
# from its parent configuration (your local 'my-ngfw-project-caller/main.tf').

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
# This module calls the actual Cloud NGFW definition from your AzureCloudNGFW repository.
# It passes down the variables that THIS module received as inputs.
module "cloud_ngfw_deployment" { # Renamed to avoid confusion with the caller's instance name
  source = "github.com/rhernand1/AzureCloudNGFW?ref=main" # This remains the same

  # --- Pass Variables DOWN to the AzureCloudNGFW Module ---
  # These are the variables that the AzureCloudNGFW module (the actual NGFW script) expects.
  # We are now passing the values received by *this* module (my-ngfw-caller) down to it.
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

# --- Outputs from THIS Module ---
# These outputs expose values from the 'cloud_ngfw_deployment' module (AzureCloudNGFW)
# so that the parent configuration (your local 'main.tf') can access them.
output "cloud_ngfw_name" {
  description = "The name of the Cloud NGFW deployed by this module."
  value       = module.cloud_ngfw_deployment.cloud_ngfw_name # Accessing output from the nested module
}

output "cloud_ngfw_ingress_ip" {
  description = "The ingress public IP of the Cloud NGFW deployed by this module."
  value       = module.cloud_ngfw_deployment.cloud_ngfw_public_ip_ingress # Accessing output
}

output "cloud_ngfw_egress_ip" {
  description = "The egress public IP of the Cloud NGFW deployed by this module."
  value       = module.cloud_ngfw_deployment.cloud_ngfw_public_ip_egress # Accessing output
}
