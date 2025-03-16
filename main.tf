# Create an IAM role for SageMaker execution
resource "aws_iam_role" "sagemaker_execution_role" {
  name = "sagemaker-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "sagemaker.amazonaws.com"
        }
      }
    ]
  })
}

# Attach AmazonSageMakerFullAccess policy to the role
resource "aws_iam_role_policy_attachment" "sagemaker_full_access" {
  role       = aws_iam_role.sagemaker_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}
# Create an S3 bucket for SageMaker artifacts
resource "aws_s3_bucket" "sagemaker_bucket" {
  bucket        = "sagemaker-test-sandbox-${random_id.suffix.hex}"
  force_destroy = true # Allows terraform destroy to remove the bucket even if it contains objects
}

resource "random_id" "suffix" {
  byte_length = 4
}

# Enable bucket versioning
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.sagemaker_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Create a SageMaker domain
resource "aws_sagemaker_domain" "test_domain" {
  domain_name = "sagemaker-test-domain"
  auth_mode   = "IAM"
  vpc_id      = aws_vpc.sagemaker_vpc.id
  subnet_ids  = [aws_subnet.sagemaker_subnet.id]

  default_user_settings {
    execution_role = aws_iam_role.sagemaker_execution_role.arn
  }

  # Add lifecycle configuration to ensure proper cleanup
  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_route_table_association.rta,
    aws_security_group.sagemaker_sg
  ]
}

# Create a user profile
resource "aws_sagemaker_user_profile" "test_user" {
  domain_id         = aws_sagemaker_domain.test_domain.id
  user_profile_name = "test-user"

  user_settings {
    execution_role = aws_iam_role.sagemaker_execution_role.arn
  }
}

# Create a basic VPC for SageMaker
resource "aws_vpc" "sagemaker_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "sagemaker-vpc"
  }
}

# Create a subnet in the VPC
resource "aws_subnet" "sagemaker_subnet" {
  vpc_id            = aws_vpc.sagemaker_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "sagemaker-subnet"
  }

  # Allow Terraform to cleanly destroy this resource
  lifecycle {
    create_before_destroy = true
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.sagemaker_vpc.id

  tags = {
    Name = "sagemaker-igw"
  }
}

# Associate route table with subnet
resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.sagemaker_subnet.id
  route_table_id = aws_route_table.rt.id
}

# Create a security group for SageMaker
resource "aws_security_group" "sagemaker_sg" {
  name        = "sagemaker-sg"
  description = "Security group for SageMaker"
  vpc_id      = aws_vpc.sagemaker_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sagemaker-sg"
  }
}

# Create a route table for internet access
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.sagemaker_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "sagemaker-rt"
  }
}
