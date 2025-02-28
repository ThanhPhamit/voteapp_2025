provider "aws" {
  region                   = var.region
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = var.profile
}

provider "aws" {
  alias                    = "virginia"
  region                   = "us-east-1"
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = var.profile
}


#==========Keypair===================
resource "aws_key_pair" "voteapp_2025_keypair" {
  key_name   = "voteapp_2025_keypair"
  public_key = file(var.keypair_path)
  tags       = local.tags
}
#====================================


module "acm" {
  source = "../modules/acm"

  domain       = var.domain
  app_dns_zone = var.app_dns_zone

  providers = {
    aws          = aws
    aws.virginia = aws.virginia
  }
  tags = local.tags
}

module "network" {
  source = "../modules/network"

  availability_zones = var.availability_zones
  cidr_block         = var.cidr_block
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets

  tags = local.tags
}

#====================================

module "security" {
  source = "../modules/security"

  vpc_id         = module.network.vpc_id
  workstation_ip = var.workstation_ip

  tags = local.tags
  depends_on = [
    module.network
  ]
}

#====================================

module "bastion" {
  source = "../modules/bastion"

  instance_type = var.bastion_instance_type
  key_name      = aws_key_pair.voteapp_2025_keypair.key_name
  subnet_id     = module.network.public_subnets[0]
  sg_id         = module.security.bastion_sg_id
  ami           = var.bastion_ami
  tags          = local.tags
  depends_on = [
    module.network,
    module.security
  ]
}

#====================================

module "storage" {
  source = "../modules/storage"

  instance_type = var.db_instance_type
  key_name      = aws_key_pair.voteapp_2025_keypair.key_name
  subnet_id     = module.network.private_subnets[0]
  sg_id         = module.security.mongodb_sg_id
  ami           = var.db_ami
  tags          = local.tags
  depends_on = [
    module.network,
    module.security
  ]
}

#====================================

module "application" {
  source = "../modules/application"

  instance_type   = var.app_instance_type
  key_name        = aws_key_pair.voteapp_2025_keypair.key_name
  vpc_id          = module.network.vpc_id
  public_subnets  = module.network.public_subnets
  private_subnets = module.network.private_subnets
  webserver_sg_id = module.security.application_sg_id
  alb_sg_id       = module.security.alb_sg_id
  mongodb_ip      = module.storage.private_ip
  ami             = var.app_ami
  domain          = var.domain
  tags            = local.tags
  depends_on = [
    module.acm,
    module.network,
    module.security,
    module.storage,

  ]
}

module "cdn" {
  source = "../modules/cdn"

  domain_name              = var.domain
  alb_dns_name             = module.application.dns_name
  virginia_certificate_arn = module.acm.virginia_certificate_arn
  tags                     = local.tags
  hosted_zone_id           = module.acm.hosted_zone_id
  alb_sg_id                = module.security.alb_security_group_id

  depends_on = [
    module.application,
    module.security,
    module.acm
  ]
}
