terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.66.0"
    }
  }
}

# terraform {
#   backend "remote" {
#     organization = "the_hub"
#     workspaces {
#       name = "terraform_workspace"
#     }
#   }
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 5.35.0"
#     }
#     # skip_credentials_validation = true
#   }
# }

