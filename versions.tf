terraform {
  required_version = ">= 1.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.53"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = ">= 17"
    }
  }
}
