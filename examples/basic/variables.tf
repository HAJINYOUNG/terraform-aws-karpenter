variable "eks_cluster_name" {
  description = "EKS 클러스터 이름"
  type        = string
}

variable "namespace" {
  description = "Karpenter 네임스페이스"
  type        = string
  default     = "karpenter"
}

variable "service_account_name" {
  description = "Karpenter 서비스 계정 이름"
  type        = string
  default     = "karpenter"
}

variable "instance_categories" {
  description = "사용할 인스턴스 카테고리 목록"
  type        = list(string)
  default     = ["c", "m", "r", "t"]
}

variable "instance_arches" {
  description = "사용할 인스턴스 아키텍처 목록"
  type        = list(string)
  default     = ["amd64", "arm64"]
}

variable "instance_cpus" {
  description = "사용할 인스턴스 CPU 코어 수 목록"
  type        = list(string)
  default     = ["4", "8", "16"]
}

variable "tags" {
  description = "모든 리소스에 추가할 태그"
  type        = map(string)
  default     = {
    Environment = "test"
    Terraform   = "true"
  }
} 