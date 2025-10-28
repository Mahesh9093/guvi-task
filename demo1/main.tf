provider "aws" {
  alias = "ap-south-1"
  region = "ap-south-1"
}

provider "aws" {
  alias = "ap-northeast-1"
  region = "ap-northeast-1"
}

resource "aws_instance" "example" {
  ami = "ami-02d26659fd82cf299"
  instance_type = "t2.micro"
  provider = "aws.ap-south-1"
}

resource "aws_instance" "example2" {
  ami = "ami-0a71a0b9c988d5e5e"
  instance_type = "t2.micro"
  provider = "aws.ap-northeast-1"
}