################################################################################
# 모듈 변수 정의
################################################################################

variable "cluster_name" {
  description = "EKS 클러스터 이름"
  type        = string
}

variable "cluster_endpoint" {
  description = "EKS 클러스터 엔드포인트"
  type        = string
}

variable "oidc_provider_arn" {
  description = "EKS 클러스터의 OIDC 공급자 ARN"
  type        = string
}

variable "namespace" {
  description = "Karpenter 설치 네임스페이스"
  type        = string
  default     = "karpenter"
}

variable "service_account_name" {
  description = "Karpenter 서비스 계정 이름"
  type        = string
  default     = "karpenter"
}

variable "create_iam_policies" {
  description = "Karpenter IAM 정책 생성 여부"
  type        = bool
  default     = true
}

variable "install_karpenter_helm" {
  description = "Karpenter Helm 차트 설치 여부"
  type        = bool
  default     = true
}

variable "patch_crd_webhooks" {
  description = "CRD 웹훅 설정 패치 여부"
  type        = bool
  default     = true
}

variable "create_node_class" {
  description = "EC2NodeClass 생성 여부"
  type        = bool
  default     = true
}

variable "create_node_pool" {
  description = "NodePool 생성 여부"
  type        = bool
  default     = true
}

variable "node_class_name" {
  description = "EC2NodeClass 이름"
  type        = string
  default     = "default"
}

variable "node_pool_name" {
  description = "NodePool 이름"
  type        = string
  default     = "default"
}

variable "ami_family" {
  description = "EC2NodeClass의 AMI 패밀리"
  type        = string
  default     = "AL2023"
}

variable "discovery_tag_key" {
  description = "노드 디스커버리용 태그 키"
  type        = string
  default     = "karpenter.sh/discovery"
}

variable "discovery_tag_value" {
  description = "노드 디스커버리용 태그 값 (일반적으로 클러스터 이름과 동일)"
  type        = string
  default     = ""
}

variable "consolidation_policy" {
  description = "노드 통합 정책"
  type        = string
  default     = "WhenUnderutilized"
}

variable "expire_after" {
  description = "노드 만료 시간 (예: 720h)"
  type        = string
  default     = "720h"
}

variable "node_pool_cpu_limit" {
  description = "NodePool의 CPU 제한"
  type        = number
  default     = 1000
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

variable "helm_repository" {
  description = "Karpenter Helm 저장소 URL"
  type        = string
  default     = "oci://public.ecr.aws/karpenter"
}

variable "helm_chart_name" {
  description = "Karpenter Helm 차트 이름"
  type        = string
  default     = "karpenter"
}

variable "helm_chart_version" {
  description = "Karpenter Helm 차트 버전"
  type        = string
  default     = "0.37.7"
}

variable "helm_timeout" {
  description = "Helm 설치 타임아웃 (초)"
  type        = number
  default     = 1800
}

variable "postrender_binary_path" {
  description = "Helm postrender 스크립트 경로"
  type        = string
  default     = "/bin/bash"
}

variable "controller_cpu_request" {
  description = "컨트롤러의 CPU 요청량"
  type        = string
  default     = "250m"
}

variable "controller_memory_request" {
  description = "컨트롤러의 메모리 요청량"
  type        = string
  default     = "512Mi"
}

variable "webhook_cpu_request" {
  description = "웹훅의 CPU 요청량"
  type        = string
  default     = "100m"
}

variable "webhook_memory_request" {
  description = "웹훅의 메모리 요청량"
  type        = string
  default     = "256Mi"
}

variable "tags" {
  description = "모든 리소스에 추가할 태그"
  type        = map(string)
  default     = {}
} 