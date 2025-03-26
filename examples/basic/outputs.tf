output "karpenter_iam_role_arn" {
  description = "Karpenter 컨트롤러 IAM 역할 ARN"
  value       = module.karpenter.karpenter_iam_role_arn
}

output "karpenter_node_role_name" {
  description = "Karpenter 노드 IAM 역할 이름"
  value       = module.karpenter.karpenter_node_role_name
}

output "karpenter_node_role_arn" {
  description = "Karpenter 노드 IAM 역할 ARN"
  value       = module.karpenter.karpenter_node_role_arn
}

output "karpenter_queue_name" {
  description = "Karpenter SQS 큐 이름"
  value       = module.karpenter.karpenter_queue_name
}

output "karpenter_service_account" {
  description = "Karpenter 서비스 계정 이름"
  value       = module.karpenter.karpenter_service_account
} 