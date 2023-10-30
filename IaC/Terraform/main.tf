terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = ">= 0.1.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  skip_provider_registration = true # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  features {}
}

resource "azuredevops_project" "androidProject" {
  name        = "Azure Android Project"
  description = "This project will simulate an andriod DevOps enviorment."
  visibility         = "private"
  version_control    = "Git"
}

resource "azuredevops_git_repository" "androidRepo" {
  project_id     = azuredevops_project.androidProject.id
  name           = "Android App Repo"
  default_branch = "refs/heads/main"
  initialization {
    init_type = "Import"
    source_type = "Git"
    source_url = "https://github.com/cmunden91/AzureDevOpsPractice.git"
  }
}

resource "azuredevops_git_repository_branch" "sit_branch" {
  repository_id = azuredevops_git_repository.androidRepo.id
  name          = "sit_branch"
  ref_branch    = "refs/heads/main"
}

resource "azuredevops_git_repository_branch" "dut_branch" {
  repository_id = azuredevops_git_repository.androidRepo.id
  name          = "dut_branch"
  ref_branch    = "refs/heads/sit_branch"
}