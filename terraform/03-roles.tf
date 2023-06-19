
resource "aws_iam_role" "lambdaRole" {
  name = "lambdaRole"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "created-by-terraform"
  }
}

resource "aws_iam_role_policy_attachment" "policy-attachment" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AWSLambdaExecute",
    "arn:aws:iam::aws:policy/service-role/AmazonS3ObjectLambdaExecutionRolePolicy",
    "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
  ])

  role       = aws_iam_role.lambdaRole.name
  policy_arn = each.value
}


resource "aws_iam_policy" "custom-policy" {
  name        = "lambda-custom-policy"
  path        = "/"
  description = "My lambda custom policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "lambda:InvokeFunction",
          "lambda:invokeFunctionUrl",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}


resource "aws_iam_role_policy_attachment" "custom-policy-attachment" {

  role       = aws_iam_role.lambdaRole.name
  policy_arn = aws_iam_policy.custom-policy.arn
}






# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "StatementId": "FunctionURLAllowPublicAccess",
#       "Effect": "Allow",
#       "Principal": "*",
#       "Action": "lambda:InvokeFunctionUrl",
#       "Resource": "arn:aws:lambda:us-east-1:466206880806:function:webhook-lambda",
#       "Condition": {
#         "StringEquals": {
#           "lambda:FunctionUrlAuthType": "NONE"
#         }
#       }
#     }
#   ]
# }

# resource "aws_iam_policy" "custom-policy" {
#   name        = "lambda-custom-policy"
#   path        = "/"
#   description = "My lambda custom policy"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = [
#           "secretsmanager:GetSecretValue",
#           "lambda:InvokeFunction",
#         ]
#         Effect   = "Allow"
#         Resource = "*"
#       },
#     ]
#   })
# }


# data "aws_iam_policy_document" "example_policy" {
#   version = "2012-10-17"

#   statement {
#     sid       = "FunctionURLAllowPublicAccess"
#     effect    = "Allow"
#     actions   = ["lambda:InvokeFunctionUrl"]
#     resources = ["*"]

#     condition {
#       test     = "StringEquals"
#       variable = "lambda:FunctionUrlAuthType"
#       values   = ["NONE"]
#     }
#   }
# }

# resource "aws_iam_policy" "example" {
#   name   = "example_policy"
#   policy = data.aws_iam_policy_document.example_policy.json
# }

# resource "aws_iam_role_policy_attachment" "custom-policy-attachment2" {

#   role       = aws_iam_role.lambdaRole.name
#   policy_arn = aws_iam_policy.example.arn
# }

