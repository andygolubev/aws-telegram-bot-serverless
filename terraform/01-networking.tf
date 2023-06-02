# resource "aws_vpc" "main-vpc" {
#   cidr_block = "10.0.0.0/16"

#   tags = {
#     Name = "Main VPC"
#     CreatedBy = "Terraform"
#   }
# }

# resource "aws_subnet" "public_subnet_1" {
#   vpc_id                  = aws_vpc.main-vpc.id
#   cidr_block              = "10.0.1.0/24"
#   availability_zone       = var.aws_public_az_1
#   map_public_ip_on_launch = true

#   tags = {
#     Name = "public-${var.aws_public_az_1}"
#     CreatedBy = "Terraform"
#   }
# }

# resource "aws_subnet" "public_subnet_2" {
#   vpc_id                  = aws_vpc.main-vpc.id
#   cidr_block              = "10.0.2.0/24"
#   availability_zone       = var.aws_public_az_2
#   map_public_ip_on_launch = true

#   tags = {
#     Name = "public-${var.aws_public_az_2}"
#     CreatedBy = "Terraform"
#   }
# }

# resource "aws_subnet" "public_subnet_3" {
#   vpc_id                  = aws_vpc.main-vpc.id
#   cidr_block              = "10.0.3.0/24"
#   availability_zone       = var.aws_public_az_3
#   map_public_ip_on_launch = true

#   tags = {
#     Name = "public-${var.aws_public_az_3}"
#     CreatedBy = "Terraform"
#   }
# }

# resource "aws_security_group" "sg-instance" {

#   name        = "SG instance WorkingNodes"
#   description = "Allow SSH and HTTP inbound traffic"
#   vpc_id      = aws_vpc.main-vpc.id

#   ingress {
#     description      = "SSH foe development from anywhere"
#     from_port        = 22
#     to_port          = 22
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"]
#   }

#   ingress {
#     description      = "HTTP from anywhere"
#     from_port        = 8080
#     to_port          = 8080
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"]
#   }

#   # This is a test
#   ingress {
#     description      = "ALL from anywhere for EKS"
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#   }


#   egress {
#     description      = "Allow all outbound traffic"
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "SG working nodes"
#     CreatedBy = "Terraform"
#   }

# }


# resource "aws_internet_gateway" "main-igw" {
#   vpc_id = aws_vpc.main-vpc.id

#   tags = {
#     Name = "Main IGW"
#     CreatedBy = "Terraform"
#   }
# }

# resource "aws_route_table" "public-route" {
#   vpc_id = aws_vpc.main-vpc.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.main-igw.id
#   }

#   tags = {
#     Name = "Public route"
#     CreatedBy = "Terraform"
#   }
# }

# resource "aws_route_table_association" "public_public_subnet_1_association" {
#   subnet_id      = aws_subnet.public_subnet_1.id
#   route_table_id = aws_route_table.public-route.id
# }

# resource "aws_route_table_association" "public_public_subnet_2_association" {
#   subnet_id      = aws_subnet.public_subnet_2.id
#   route_table_id = aws_route_table.public-route.id
# }

# resource "aws_route_table_association" "public_public_subnet_3_association" {
#   subnet_id      = aws_subnet.public_subnet_3.id
#   route_table_id = aws_route_table.public-route.id
# }