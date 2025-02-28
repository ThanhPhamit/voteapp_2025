terraform {
  backend "s3" {
    bucket  = "terraform-studying-tf123"
    region  = "ap-southeast-7"
    key     = "voteapp_2025/prod/terraform.tfstate"
    dynamodb_table = "voteapp_2025_prod_terraform_locking"
    profile = "dev01-mfa"
  }
}
