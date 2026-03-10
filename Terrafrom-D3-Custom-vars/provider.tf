provider "aws" {
region = "us-east-1"
profile = "default" 
}

provider "aws" {
region = "us-west-2"
alias="test_env"
profile = "test_env" 
}

provider "aws" {
region = "us-west-2"
alias="dev_env"
profile = "dev_env" 
}
