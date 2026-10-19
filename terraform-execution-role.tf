data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

# 1. IAM Role assumed by the AWS Provider
resource "aws_iam_role" "terraform_execution" {
  name        = "${var.environment}-terraform-execution-role"
  description = "Role assumed by Terraform AWS Provider to manage VPC, EKS, and IAM resources"

  # Trust Policy: Controls WHO can assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowExplicitEntitiesToAssume"
        Effect = "Allow"
        Principal = {
          # Option A: Allow specific IAM users, roles, or CI/CD runners
          # AWS = var.trusted_principals

          # Option B: Allow identities within the same account (or a specified management account)
          AWS = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = "sts:AssumeRole"
        Condition = {
          # Enforces multi-factor authentication if assumed by human users (optional)
          # "BoolIfExists" : { "aws:MultiFactorAuthPresent" : "true" }
        }
      }
    ]
  })

  tags = {
    Name = "${var.environment}-terraform-execution-role"
  }
}

# 2. Permissions Policy defining what Terraform can do once it assumes the role
resource "aws_iam_policy" "terraform_execution_policy" {
  name        = "${var.environment}-terraform-execution-policy"
  description = "Scoped permissions allowing Terraform to manage VPC, EKS, KMS, and IAM components"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowVPCAndNetworkingOperations"
        Effect = "Allow"
        Action = [
          "ec2:CreateVpc",
          "ec2:DeleteVpc",
          "ec2:DescribeVpcs",
          "ec2:ModifyVpcAttribute",
          "ec2:CreateSubnet",
          "ec2:DeleteSubnet",
          "ec2:DescribeSubnets",
          "ec2:ModifySubnetAttribute",
          "ec2:CreateInternetGateway",
          "ec2:DeleteInternetGateway",
          "ec2:AttachInternetGateway",
          "ec2:DetachInternetGateway",
          "ec2:DescribeInternetGateways",
          "ec2:CreateNatGateway",
          "ec2:DeleteNatGateway",
          "ec2:DescribeNatGateways",
          "ec2:AllocateAddress",
          "ec2:ReleaseAddress",
          "ec2:DescribeAddresses",
          "ec2:CreateRouteTable",
          "ec2:DeleteRouteTable",
          "ec2:DescribeRouteTables",
          "ec2:CreateRoute",
          "ec2:DeleteRoute",
          "ec2:AssociateRouteTable",
          "ec2:DisassociateRouteTable",
          "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSecurityGroupRules",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:DescribeAvailabilityZones",
          "ec2:CreateTags",
          "ec2:DeleteTags",
          "ec2:DescribeTags",
          "ec2:DescribeNetworkInterfaces",
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeKeyPairs",
          "ec2:RunInstances",
          "ec2:DescribeInstances",
          "ec2:TerminateInstances",
          "ec2:CreateLaunchTemplate",
          "ec2:DeleteLaunchTemplate",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeLaunchTemplateVersions"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowEKSOperations"
        Effect = "Allow"
        Action = [
          "eks:CreateCluster",
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:UpdateClusterConfig",
          "eks:UpdateClusterVersion",
          "eks:DeleteCluster",
          "eks:CreateNodegroup",
          "eks:DescribeNodegroup",
          "eks:ListNodegroups",
          "eks:UpdateNodegroupConfig",
          "eks:UpdateNodegroupVersion",
          "eks:DeleteNodegroup",
          "eks:CreateAddon",
          "eks:DescribeAddon",
          "eks:ListAddons",
          "eks:UpdateAddon",
          "eks:DeleteAddon",
          "eks:DescribeUpdate",
          "eks:CreateAccessEntry",
          "eks:DescribeAccessEntry",
          "eks:ListAccessEntries",
          "eks:UpdateAccessEntry",
          "eks:DeleteAccessEntry",
          "eks:AssociateAccessPolicy",
          "eks:DisassociateAccessPolicy",
          "eks:ListAssociatedAccessPolicies",
          "eks:TagResource",
          "eks:UntagResource",
          "eks:ListTagsForResource"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowKMSForEKSSecrets"
        Effect = "Allow"
        Action = [
          "kms:CreateKey",
          "kms:DescribeKey",
          "kms:GetKeyPolicy",
          "kms:PutKeyPolicy",
          "kms:CreateAlias",
          "kms:DeleteAlias",
          "kms:ListAliases",
          "kms:TagResource",
          "kms:UntagResource",
          "kms:EnableKeyRotation",
          "kms:ScheduleKeyDeletion"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowIAMManagement"
        Effect = "Allow"
        Action = [
          "iam:CreateUser",
          "iam:GetUser",
          "iam:ListUsers",
          "iam:UpdateUser",
          "iam:DeleteUser",
          "iam:CreateAccessKey",
          "iam:DeleteAccessKey",
          "iam:ListAccessKeys",
          "iam:CreateRole",
          "iam:GetRole",
          "iam:ListRoles",
          "iam:UpdateRole",
          "iam:DeleteRole",
          "iam:CreatePolicy",
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:ListPolicies",
          "iam:ListPolicyVersions",
          "iam:CreatePolicyVersion",
          "iam:DeletePolicyVersion",
          "iam:DeletePolicy",
          "iam:AttachUserPolicy",
          "iam:DetachUserPolicy",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:PutUserPolicy",
          "iam:GetUserPolicy",
          "iam:DeleteUserPolicy",
          "iam:ListUserPolicies",
          "iam:PutRolePolicy",
          "iam:GetRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:ListRolePolicies",
          "iam:CreateInstanceProfile",
          "iam:DeleteInstanceProfile",
          "iam:GetInstanceProfile",
          "iam:AddRoleToInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:TagUser",
          "iam:TagRole",
          "iam:TagPolicy"
        ]
        Resource = "*"
      },
      {
        Sid      = "AllowPassRoleToServices"
        Effect   = "Allow"
        Action   = "iam:PassRole"
        Resource = "*"
        Condition = {
          StringEquals = {
            "iam:PassedToService" = [
              "eks.amazonaws.com",
              "ec2.amazonaws.com"
            ]
          }
        }
      },
      {
        "Sid" : "AllowMissingKMSReadActions",
        "Effect" : "Allow",
        "Action" : [
          "kms:GetKeyRotationStatus",
          "kms:DescribeKey",
          "kms:GetKeyPolicy",
          "kms:ListResourceTags"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "AllowMissingIAMReadActions",
        "Effect" : "Allow",
        "Action" : [
          "iam:ListAttachedRolePolicies",
          "iam:GetRole",
          "iam:GetRolePolicy",
          "iam:ListRolePolicies",
          "iam:ListInstanceProfilesForRole"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "AllowCloudWatchLogsReadActions",
        "Effect" : "Allow",
        "Action" : [
          "logs:DescribeLogGroups",
          "logs:ListTagsLogGroup",
          "logs:ListTagsForResource"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "AllowEC2NetworkACLReadActions",
        "Effect" : "Allow",
        "Action" : [
          "ec2:DescribeNetworkAcls"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "AllowOIDCProviderManagement",
        "Effect" : "Allow",
        "Action" : [
          "iam:GetOpenIDConnectProvider",
          "iam:CreateOpenIDConnectProvider",
          "iam:DeleteOpenIDConnectProvider",
          "iam:TagOpenIDConnectProvider",
          "iam:UntagOpenIDConnectProvider",
          "iam:ListOpenIDConnectProviders"
        ],
        "Resource" : "arn:aws:iam::899042279834:oidc-provider/*"
      },
      {
        "Sid" : "AllowSSMReadForEKSAMIs",
        "Effect" : "Allow",
        "Action" : [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ],
        "Resource" : "arn:aws:ssm:us-east-1::parameter/aws/service/eks/optimized-ami/*"
      },
      {
        "Sid" : "AllowEC2VpcAttributeInspection",
        "Effect" : "Allow",
        "Action" : [
          "ec2:DescribeVpcAttribute",
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeNetworkAcls",
          "ec2:DescribeRouteTables",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeNatGateways"
        ],
        "Resource" : "*"
        }, {
        "Sid" : "AllowEKSAddonVersionQueries",
        "Effect" : "Allow",
        "Action" : [
          "eks:DescribeAddonVersions",
          "eks:DescribeAddonConfiguration"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "AllowEC2EIPAttributeQueries",
        "Effect" : "Allow",
        "Action" : [
          "ec2:DescribeAddressesAttribute"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "AllowIAMUserGroupInspection",
        "Effect" : "Allow",
        "Action" : [
          "iam:ListGroupsForUser",
          "iam:RemoveUserFromGroup"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "AllowCloudWatchLogsDeletion",
        "Effect" : "Allow",
        "Action" : [
          "logs:DeleteLogGroup"
        ],
        "Resource" : "arn:aws:logs:us-east-1:899042279834:log-group:/aws/eks/*"
      },
      {
        "Sid" : "AllowCloudWatchLogsCreationAndManagement",
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:PutRetentionPolicy",
          "logs:TagResource",
          "logs:UntagResource"
        ],
        "Resource" : "arn:aws:logs:us-east-1:899042279834:log-group:/aws/eks/*"
      },
      {
        "Sid" : "AllowEC2NetworkACLEntryManagement",
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateNetworkAclEntry",
          "ec2:DeleteNetworkAclEntry",
          "ec2:ReplaceNetworkAclEntry",
          "ec2:ReplaceNetworkAclAssociation"
        ],
        "Resource" : "*"
      }
    ]
  })
}

# 3. Attach Policy to Role
resource "aws_iam_role_policy_attachment" "terraform_execution_attach" {
  role       = aws_iam_role.terraform_execution.name
  policy_arn = aws_iam_policy.terraform_execution_policy.arn
}