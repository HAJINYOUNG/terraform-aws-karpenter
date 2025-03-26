################################################################################
# Karpenter 컨트롤러 & 노드 IAM 역할, SQS 큐, EventBridge 규칙
################################################################################

# STS 정책 생성
resource "aws_iam_policy" "karpenter_sts_policy" {
  count       = var.create_iam_policies ? 1 : 0
  name        = "KarpenterSTSPolicy-${var.cluster_name}"
  description = "Allow Karpenter to assume role with web identity"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sts:AssumeRoleWithWebIdentity",
          "sts:GetCallerIdentity"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

# Karpenter 컨트롤러 확장 권한 정책 생성
resource "aws_iam_policy" "karpenter_controller_policy" {
  count       = var.create_iam_policies ? 1 : 0
  name        = "KarpenterControllerPolicy-${var.cluster_name}"
  description = "Allows Karpenter to manage EC2 instances and IAM roles"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeImages",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeAvailabilityZones",
          "ec2:RunInstances",
          "ec2:TerminateInstances",
          "ec2:CreateTags",
          "ec2:CreateLaunchTemplate",
          "ec2:CreateFleet",
          "ec2:DeleteLaunchTemplate",
          "iam:CreateServiceLinkedRole",
          "iam:CreateInstanceProfile",
          "iam:AddRoleToInstanceProfile",
          "ssm:GetParameter"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["iam:PassRole"]
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

# Karpenter 모듈 설정
module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "~> 20.0"

  cluster_name           = var.cluster_name
  irsa_oidc_provider_arn = var.oidc_provider_arn

  # IRSA 설정
  enable_irsa     = true
  namespace       = var.namespace
  service_account = var.service_account_name

  # 노드 IAM 역할 설정
  node_iam_role_additional_policies = merge(
    {
      AmazonEKSClusterPolicy             = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
      AmazonEKSWorkerNodePolicy          = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
      AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      AmazonSSMManagedInstanceCore       = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    },
    var.create_iam_policies ? {
      KarpenterSTS        = aws_iam_policy.karpenter_sts_policy[0].arn
      KarpenterController = aws_iam_policy.karpenter_controller_policy[0].arn
    } : {}
  )

  tags = var.tags
}

# 컨트롤러 설치 (Helm)
resource "helm_release" "karpenter" {
  count            = var.install_karpenter_helm ? 1 : 0
  namespace        = var.namespace
  create_namespace = true

  name       = "karpenter"
  repository = var.helm_repository
  chart      = var.helm_chart_name
  version    = var.helm_chart_version

  values = [
    templatefile("${path.module}/templates/values.yaml", {
      cluster_name      = var.cluster_name
      cluster_endpoint  = var.cluster_endpoint
      iam_role_arn      = module.karpenter.iam_role_arn
      namespace         = var.namespace
      service_account   = var.service_account_name
      controller_cpu    = var.controller_cpu_request
      controller_memory = var.controller_memory_request
      webhook_cpu       = var.webhook_cpu_request
      webhook_memory    = var.webhook_memory_request
    })
  ]

  timeout = var.helm_timeout

  # 웹훅 설정 패치를 위한 post-rendering
  postrender {
    binary_path = var.postrender_binary_path
    args = [
      "-c",
      <<-EOT
      kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=karpenter -n ${var.namespace} --timeout=300s || true
      kubectl patch crd nodepools.karpenter.sh --type=json -p '[{"op":"replace","path":"/spec/conversion/webhook/clientConfig/service/namespace","value":"${var.namespace}"}]' || true
      kubectl patch crd ec2nodeclasses.karpenter.k8s.aws --type=json -p '[{"op":"replace","path":"/spec/conversion/webhook/clientConfig/service/namespace","value":"${var.namespace}"}]' || true
      kubectl patch crd nodeclaims.karpenter.sh --type=json -p '[{"op":"replace","path":"/spec/conversion/webhook/clientConfig/service/namespace","value":"${var.namespace}"}]' || true
      EOT
    ]
  }

  depends_on = [
    module.karpenter
  ]
}

# EC2NodeClass 설정
resource "kubectl_manifest" "karpenter_node_class" {
  count = var.create_node_class ? 1 : 0
  yaml_body = templatefile("${path.module}/templates/ec2nodeclass.yaml", {
    node_class_name     = var.node_class_name
    namespace           = var.namespace
    node_role_name      = module.karpenter.node_iam_role_name
    ami_family          = var.ami_family
    discovery_tag_key   = var.discovery_tag_key
    discovery_tag_value = var.discovery_tag_value
  })

  depends_on = [
    helm_release.karpenter
  ]

  server_side_apply = true

  timeouts {
    create = "20m"
  }
}

# 웹훅 설정 패치를 위한 리소스
resource "null_resource" "setup_karpenter_webhooks" {
  count = var.install_karpenter_helm && var.patch_crd_webhooks ? 1 : 0

  provisioner "local-exec" {
    command = <<-EOT
      # Karpenter 파드가 준비될 때까지 대기
      echo "Waiting for Karpenter pods to be ready..."
      kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=karpenter -n ${var.namespace} --timeout=300s || true
      
      # CRD의 웹훅 네임스페이스 수정
      echo "Patching CRD webhook settings..."
      kubectl patch crd nodepools.karpenter.sh --type=json -p '[{"op":"replace","path":"/spec/conversion/webhook/clientConfig/service/namespace","value":"${var.namespace}"}]' || true
      kubectl patch crd ec2nodeclasses.karpenter.k8s.aws --type=json -p '[{"op":"replace","path":"/spec/conversion/webhook/clientConfig/service/namespace","value":"${var.namespace}"}]' || true
      kubectl patch crd nodeclaims.karpenter.sh --type=json -p '[{"op":"replace","path":"/spec/conversion/webhook/clientConfig/service/namespace","value":"${var.namespace}"}]' || true
    EOT
  }

  depends_on = [
    helm_release.karpenter
  ]
}

# NodePool 설정
resource "kubectl_manifest" "karpenter_node_pool" {
  count = var.create_node_pool ? 1 : 0
  yaml_body = templatefile("${path.module}/templates/nodepool.yaml", {
    node_pool_name      = var.node_pool_name
    namespace           = var.namespace
    node_class_name     = var.node_class_name
    consolidation_policy = var.consolidation_policy
    expire_after        = var.expire_after
    cpu_limit           = var.node_pool_cpu_limit
    instance_categories = var.instance_categories
    instance_arches     = var.instance_arches
    instance_cpus       = var.instance_cpus
  })

  server_side_apply = true
  validate_schema   = false
  
  timeouts {
    create = "10m"
  }
  
  depends_on = [
    kubectl_manifest.karpenter_node_class,
    null_resource.setup_karpenter_webhooks
  ]
} 