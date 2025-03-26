eks_cluster_name = "deleo-test-eks"

namespace = "karpenter"
service_account_name = "karpenter"

# 인스턴스 선택 옵션
instance_categories = ["c", "m", "r"]
instance_arches = ["amd64", "arm64"]
instance_cpus = ["4", "8"]

# 태그
tags = {
  Environment = "test"
  Terraform   = "true"
  Project     = "deleo"
} 