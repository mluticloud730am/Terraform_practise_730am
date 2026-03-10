resource "aws_instance" "dev" {

    ami=var.ami_id
    instance_type = var.instance_type
    provider = aws.dev_env
      subnet_id              = "subnet-0fd2fc2b84b24cff8"
  vpc_security_group_ids = ["sg-044910c7a8c19aa3d"]
    tags ={
        name= "dev-instance"
    }
}

resource "aws_instance" "test" {
    ami = var.test_ami_id
    instance_type = var.test_instance_type
    provider = aws.test_env
      subnet_id              = "subnet-0fd2fc2b84b24cff8"
  vpc_security_group_ids = ["sg-044910c7a8c19aa3d"]
    tags ={
        name= "test-instance"
    }
}