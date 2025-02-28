terraform {
  backend "s3" {
    bucket  = "terraform-studying-tf123"
    region  = "ap-southeast-5"
    key     = "voteapp_2025/dev/terraform.tfstate"
    dynamodb_table = "voteapp_2025_dev_terraform_locking"
    profile = "dev01-mfa"
  }
}
