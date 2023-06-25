
resource "aws_iam_role" "lambdaRole" {
  name = "lambdaRole"

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

resource "aws_iam_role_policy_attachment" "policy-attachment" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AWSLambdaExecute",
    "arn:aws:iam::aws:policy/service-role/AmazonS3ObjectLambdaExecutionRolePolicy",
    "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonRekognitionReadOnlyAccess"
  ])

  role       = aws_iam_role.lambdaRole.name
  policy_arn = each.value
}
