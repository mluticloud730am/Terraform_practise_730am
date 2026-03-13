resource "aws_instance" "dev" {

  ami                    = var.ami_id
  instance_type          = var.instance_type
  provider               = aws.dev_env
  subnet_id              = "subnet-0029e20d42dec5bc2"
  vpc_security_group_ids = ["sg-084dc7cce1ca7d62e"]
  tags = {
    Name = "dev-instance"
  }
}

resource "aws_instance" "test" {
  ami                    = var.test_ami_id
  instance_type          = var.test_instance_type
  provider               = aws.test_env
  subnet_id              = "subnet-0029e20d42dec5bc2"
  vpc_security_group_ids = ["sg-084dc7cce1ca7d62e"]
  tags = {

    name = "test-instance"
  }
}