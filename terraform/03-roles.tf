
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

