# provider の設定 ( provider は aws 専用ではなくGCPとかも使える)
provider "aws" {
  region = "ap-northeast-1"
}

# ========================================================
# Network 作成
#
# VPC, subnet(pub, pri), IGW, RouteTable, Route, RouteTableAssociation
# ========================================================
module "network" {
  source = "../_module/network"
  app_name = var.APP_NAME
  azs = var.azs
}

# ========================================================
# EC2 (vpc_id, subnet_id が必要)
#
# ========================================================
module "ec2" {
  source = "../_module/ec2"
  app_name = var.APP_NAME
  vpc_id    = module.network.vpc_id
  subnet_id = module.network.ec2_subnet_id
}

# ========================================================
# ECS 作成
#
# ECS(service, cluster elb
# ========================================================
module "ecs" {
  source = "../_module/ecs/app"
  app_name = var.APP_NAME
  vpc_id   = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids

  cluster_name = module.ecs_cluster.cluster_name
  # elb の設定
  https_listener_arn  = module.elb.https_listener_arn
  # ECS のtask に関連付けるIAM の設定
  iam_role_task_execution_arn = module.iam.iam_role_task_execution_arn
  app_key = var.APP_KEY

  loki_user = var.LOKI_USER
  loki_pass = var.LOKI_PASS
}

# cluster 作成
module "ecs_cluster" {
  source   = "../_module/ecs/cluster"
  app_name = var.APP_NAME
}

# ACM 発行
module "acm" {
  source   = "../_module/acm"
  app_name = var.APP_NAME
  zone     = var.ZONE
  domain   = var.DOMAIN
}

# ELB の設定
module "elb" {
  source            = "../_module/elb"
  app_name          = var.APP_NAME
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids

  domain = var.DOMAIN
  zone   = var.ZONE
  acm_id = module.acm.acm_id
}

# IAM 設定
# ECS-Agentが使用するIAMロール や タスク(=コンテナ)に付与するIAMロール の定義
module "iam" {
  source = "../_module/iam"
  app_name = var.APP_NAME
}

# ========================================================
# RDS 作成
#
# [subnetGroup, securityGroup, RDS instance(postgreSQL)]
# ========================================================
# RDS (PostgreSQL)
module "rds" {
  source = "../_module/rds"

  app_name = var.APP_NAME
  vpc_id   = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids

  database_name   = var.DB_NAME
  master_username = var.DB_MASTER_NAME
  master_password = var.DB_MASTER_PASS
}

# ========================================================
# Elasticache (Redis)
#
# ========================================================
module "elasticache" {
  source = "../_module/elasticache"
  app_name = var.APP_NAME
  vpc_id = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids
}

# ========================================================
# SES : Simple Email Service
# メール送信に使用
# ========================================================
module "ses" {
  source = "../_module/ses"
  domain = var.DOMAIN
  zone   = var.ZONE
}