provider "aws" {
  region = "ap-northeast-2"
}

# 기존 EKS 클러스터 데이터 소스
data "aws_eks_cluster" "this" {
  name = var.eks_cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = var.eks_cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

provider "kubectl" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
  load_config_file       = false
}

# EKS OIDC 공급자 데이터 소스
data "aws_iam_openid_connect_provider" "eks" {
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

# Karpenter 모듈 사용
module "karpenter" {
  source = "../../"

  # 필수 변수
  cluster_name      = data.aws_eks_cluster.this.name
  cluster_endpoint  = data.aws_eks_cluster.this.endpoint
  oidc_provider_arn = data.aws_iam_openid_connect_provider.eks.arn
  
  # 선택적 변수
  namespace           = var.namespace
  service_account_name = var.service_account_name
  discovery_tag_value = data.aws_eks_cluster.this.name
  
  # 인스턴스 유형 선택
  instance_categories = var.instance_categories
  instance_arches     = var.instance_arches
  instance_cpus       = var.instance_cpus
  
  # 태그
  tags = var.tags
} 