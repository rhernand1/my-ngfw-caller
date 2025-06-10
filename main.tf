# This OpenTofu configuration calls the Cloud NGFW deployment script
# as a module directly from a GitHub repository.

# --- Provider Configuration ---
# Specifies the required AzureRM provider, as it's used by the called module.
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0" # Ensure this matches or is compatible with the module's requirement
    }
  }
}

# Configures the AzureRM provider for the root module.
provider "azurerm" {
  features {}
}

# --- Module Call ---
# This block references the Cloud NGFW configuration located in your GitHub repository.
# Replace 'your-username/your-ngfw-repo' with your actual GitHub username and repository name.
# The 'ref' argument specifies the branch, tag, or commit hash to use.
module "cloud_ngfw_instance" {
  source = "github.com/your-username/your-ngfw-repo?ref=main" # <--- IMPORTANT: Replace with your actual repo and branch/tag

  # --- Pass Variables to the Module ---
  # All variables defined in the original `ngfw-standalone-deployment` script
  # (which is now acting as your module) must be passed as arguments here.
  # These values will override the defaults set in the module's variables.

  resource_group_name    = "RHTESTING-GitHub" # <--- CHANGE: Example: changed RG name to differentiate
  location               = "East US 2"
  firewall_name          = "cngfwrh-github" # <--- CHANGE: Example: changed firewall name
  vnet_name              = "ngfw-vnet-github"
  vnet_address_space     = ["10.20.0.0/16"] # <--- CHANGE: Example: changed VNet address space
  untrusted_subnet_name  = "github-untrusted"
  untrusted_subnet_prefix = "10.20.0.0/28"
  trusted_subnet_name    = "github-trusted"
  trusted_subnet_prefix  = "10.20.0.16/28"
  management_subnet_name = "github-mgmt"
  management_subnet_prefix = "10.20.0.32/28"
  tags = {
    Environment = "GitHub_Deployed"
    Project     = "CloudNGFWGitHubDemo"
    DeployedBy  = "OpenTofu"
  }
}

# --- Outputs (Optional) ---
# You can define outputs here to expose values from the called module.
output "deployed_ngfw_name" {
  description = "The name of the Cloud NGFW deployed via the GitHub module."
  value       = module.cloud_ngfw_instance.cloud_ngfw_name
}

output "deployed_ngfw_ingress_ip" {
  description = "The ingress public IP of the Cloud NGFW deployed via the GitHub module."
  value       = module.cloud_ngfw_instance.cloud_ngfw_public_ip_ingress
}
