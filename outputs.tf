################################################################################
# 모듈 출력 변수
################################################################################

output "karpenter_iam_role_arn" {
  description = "Karpenter 컨트롤러 IAM 역할 ARN"
  value       = module.karpenter.iam_role_arn
}

output "karpenter_node_role_name" {
  description = "Karpenter 노드 IAM 역할 이름"
  value       = module.karpenter.node_iam_role_name
}

output "karpenter_node_role_arn" {
  description = "Karpenter 노드 IAM 역할 ARN"
  value       = module.karpenter.node_iam_role_arn
}

output "karpenter_queue_name" {
  description = "Karpenter SQS 큐 이름"
  value       = module.karpenter.queue_name
}

output "karpenter_sqs_arn" {
  description = "Karpenter SQS 큐 ARN"
  value       = module.karpenter.sqs_arn
}

output "karpenter_sqs_url" {
  description = "Karpenter SQS 큐 URL"
  value       = module.karpenter.sqs_url
}

output "karpenter_service_account" {
  description = "Karpenter 서비스 계정 이름"
  value       = var.service_account_name
}

output "controller_iam_policy_arn" {
  description = "Karpenter 컨트롤러 IAM 정책 ARN"
  value       = var.create_iam_policies ? aws_iam_policy.karpenter_controller_policy[0].arn : null
}

output "sts_iam_policy_arn" {
  description = "Karpenter STS IAM 정책 ARN"
  value       = var.create_iam_policies ? aws_iam_policy.karpenter_sts_policy[0].arn : null
} 