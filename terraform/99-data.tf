data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server*"]
  }
}

data "aws_ami" "eks" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amazon-eks-node-1.25-v20230322"]
  }
}