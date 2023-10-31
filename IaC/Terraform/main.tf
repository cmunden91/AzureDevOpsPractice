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
}

resource "azuredevops_project_features" "androidProjectFeatures" {
  project_id = azuredevops_project.androidProject.id
  features = {
    "repositories" = "enabled"
    "artifacts" = "enabled"
    "pipelines" = "enabled"
  }
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
  ref_branch    = "refs/heads/main"
}

resource "azuredevops_build_definition" "prod_build" {
  project_id = azuredevops_project.androidProject.id
  name       = "Production Build Pipeline"

  ci_trigger {
    use_yaml = false
  }

  schedules {
    branch_filter {
      include = ["main"]
      exclude = ["sit_branch", "dut_branch"]
    }
    days_to_build              = ["Wed", "Sun"]
    schedule_only_with_changes = true
    start_hours                = 10
    start_minutes              = 59
    time_zone                  = "(UTC) Coordinated Universal Time"
  }

  repository {
    repo_type   = "TfsGit"
    repo_id     = azuredevops_git_repository.androidRepo.id
    branch_name = azuredevops_git_repository.androidRepo.default_branch
    yml_path    = "azure-pipelines.yml"
  }
}