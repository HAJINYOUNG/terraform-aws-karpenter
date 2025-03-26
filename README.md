# AWS EKS Karpenter 모듈

이 모듈은 AWS EKS 클러스터에 Karpenter 오토스케일러를 배포하는 Terraform 모듈입니다.

## 특징

- EKS 클러스터에 Karpenter 배포
- IAM 역할 및 정책 생성
- EC2NodeClass 및 NodePool 리소스 구성
- Karpenter 웹훅 설정 관리

## 사용 방법

```hcl
module "karpenter" {
  source = "your-registry/aws-eks-karpenter/aws"

  # 필수 변수
  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  oidc_provider_arn = module.eks.oidc_provider_arn
  
  # 선택적 변수
  namespace           = "karpenter"
  service_account_name = "karpenter"
  discovery_tag_value = module.eks.cluster_name
  
  # 인스턴스 유형 선택
  instance_categories = ["c", "m", "r", "t"]
  instance_arches     = ["amd64", "arm64"]
  instance_cpus       = ["4", "8", "16"]
  
  # 태그
  tags = {
    Environment = "production"
    Terraform   = "true"
  }
}
```

## 입력 변수

### 필수 변수

| 이름 | 설명 |
|------|-------------|
| cluster_name | EKS 클러스터 이름 |
| cluster_endpoint | EKS 클러스터 엔드포인트 URL |
| oidc_provider_arn | EKS 클러스터의 OIDC 공급자 ARN |

### 선택적 변수

| 이름 | 설명 | 기본값 |
|------|-------------|---------|
| namespace | Karpenter 네임스페이스 | `"karpenter"` |
| service_account_name | Karpenter 서비스 계정 이름 | `"karpenter"` |
| create_iam_policies | IAM 정책 생성 여부 | `true` |
| install_karpenter_helm | Karpenter Helm 차트 설치 여부 | `true` |
| patch_crd_webhooks | CRD 웹훅 설정 패치 여부 | `true` |
| create_node_class | EC2NodeClass 생성 여부 | `true` |
| create_node_pool | NodePool 생성 여부 | `true` |
| node_class_name | EC2NodeClass 이름 | `"default"` |
| node_pool_name | NodePool 이름 | `"default"` |
| ami_family | EC2NodeClass의 AMI 패밀리 | `"AL2023"` |
| discovery_tag_key | 노드 디스커버리용 태그 키 | `"karpenter.sh/discovery"` |
| discovery_tag_value | 노드 디스커버리용 태그 값 | `""` (일반적으로 클러스터 이름) |
| consolidation_policy | 노드 통합 정책 | `"WhenUnderutilized"` |
| expire_after | 노드 만료 시간 | `"720h"` |
| node_pool_cpu_limit | NodePool의 CPU 제한 | `1000` |
| helm_chart_version | Karpenter Helm 차트 버전 | `"0.37.7"` |

## 출력 변수

| 이름 | 설명 |
|------|-------------|
| karpenter_iam_role_arn | Karpenter 컨트롤러 IAM 역할 ARN |
| karpenter_node_role_name | Karpenter 노드 IAM 역할 이름 |
| karpenter_node_role_arn | Karpenter 노드 IAM 역할 ARN |
| karpenter_queue_name | Karpenter SQS 큐 이름 |
| karpenter_sqs_arn | Karpenter SQS 큐 ARN |
| karpenter_sqs_url | Karpenter SQS 큐 URL |
| karpenter_service_account | Karpenter 서비스 계정 이름 |
| controller_iam_policy_arn | Karpenter 컨트롤러 IAM 정책 ARN |
| sts_iam_policy_arn | Karpenter STS IAM 정책 ARN |

## 요구사항

| 이름 | 버전 |
|------|---------|
| terraform | >= 1.0.0 |
| aws | >= 4.0.0 |
| kubectl | >= 1.14.0 |
| helm | >= 2.6.0 |

## 참고사항

- 이 모듈을 사용하기 전에 Fargate 프로필을 사용하는 EKS 클러스터가 필요합니다.
- EKS 클러스터 보안 그룹에 `karpenter.sh/discovery` 태그가 있어야 합니다.
- Karpenter가 제대로 작동하려면 적절한 VPC 및 서브넷 태그가 필요합니다.

## 라이센스

MIT

## 참고 자료

- [Karpenter 공식 문서](https://karpenter.sh/)
- [AWS EKS Blueprints](https://github.com/aws-ia/terraform-aws-eks-blueprints) 