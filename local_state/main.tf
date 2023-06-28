terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  required_version = ">=1.5.1"
}

#configure the AWS required_provider not mandatory and the default region would be used
provider "aws" {
  region = "eu-west-2"
}

// creating ami dynamically from the latest ami available in a region



#create an instance
resource "aws_instance" "app_server" {
  ami           = "ami-0ccdcf8ea5cace030"
  instance_type = "t2.micro"

  tags = {
    Name = "FirstEC2WithTerra"
  }
}




