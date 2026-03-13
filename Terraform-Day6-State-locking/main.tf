resource "aws_vpc" "name" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Rakesh_Dev_VPC"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}