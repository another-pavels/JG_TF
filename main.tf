terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-1"
}

resource "aws_vpc" "pavelsm_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "PavelsM"
    Owner = "Pavels M"
  }
}

resource "aws_subnet" "pavelsm_web_subnet" {
  vpc_id     = aws_vpc.pavelsm_vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "Pavels M"
    Owner = "Pavels M"
  }
}

resource "aws_subnet" "pavelsm_db_subnet" {
  vpc_id     = aws_vpc.pavelsm_vpc.id
  cidr_block = "10.0.2.0/24"
  
  tags = {
    Name = "Pavels M"
    Owner = "Pavels M"
  }
}

resource "aws_internet_gateway" "pavelsm_igw" {
  vpc_id = aws_vpc.pavelsm_vpc.id

  tags = {
    Name = "PavelsM"
    Owner = "Pavels M"
  }
}

resource "aws_default_route_table" "pavelsm_route_table" {
  default_route_table_id = aws_vpc.pavelsm_vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.pavelsm_igw.id
  }

  tags = {
    Name = "PavelsM"
    Owner = "Pavels M"
  }
}

resource "aws_security_group" "pavelsm_secgroup_web" { 
  description = "Pavels M WEB Security Group" 
  vpc_id = aws_vpc.pavelsm_vpc.id 
  ingress { 
    from_port   = 22 
    to_port     = 22 
    protocol    = "tcp" 
    cidr_blocks = ["0.0.0.0/0"]
  } 
  ingress { 
    from_port   = 22 
    to_port     = 22 
    protocol    = "tcp" 
    cidr_blocks = ["2.2.2.2/32"]
  } 
  ingress { 
    from_port   = 80 
    to_port     = 80 
    protocol    = "tcp" 
    cidr_blocks = ["0.0.0.0/0"] 
  } 
  ingress { 
    from_port   = 443 
    to_port     = 443 
    protocol    = "tcp" 
    cidr_blocks = ["0.0.0.0/0"] 
  } 
  ingress { 
    from_port   = -1 
    to_port     = -1 
    protocol    = "icmp" 
    cidr_blocks = ["0.0.0.0/0"] 
  } 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "PavelsM"
    Owner = "Pavels M" } 
}

resource "aws_security_group" "pavelsm_secgroup_db" { 
  description = "Pavels M DB Security Group" 
  vpc_id = aws_vpc.pavelsm_vpc.id 
  ingress { 
    from_port   = 22 
    to_port     = 22 
    protocol    = "tcp" 
    cidr_blocks = ["10.0.0.0/16"]
  }
  ingress { 
    from_port   = 3306 
    to_port     = 3306 
    protocol    = "tcp" 
    cidr_blocks = ["10.0.0.0/16"] 
  } 
  ingress { 
    from_port   = -1 
    to_port     = -1 
    protocol    = "icmp" 
    cidr_blocks = ["0.0.0.0/0"] 
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  } 

  tags = { 
    Name = "PavelsM"
    Owner = "Pavels M"  
  }
} 

resource "aws_instance" "PavelsM_WEB" {
  ami           = "ami-007855ac798b5175e"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.pavelsm_web_subnet.id
  associate_public_ip_address = true
  key_name  = "pavelsJG-amazon-key"
  private_ip = "10.0.1.100"
  user_data = "${file("init.web.sh")}"

  vpc_security_group_ids = [ 
  aws_security_group.pavelsm_secgroup_web.id, 
  ] 

  tags = {
    Name = "PavelsM_WEB"
    Owner = "Pavels M"
  }
}

resource "aws_instance" "PavelsM_DB" {
  ami           = "ami-007855ac798b5175e"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.pavelsm_db_subnet.id
  associate_public_ip_address = true
  key_name  = "pavelsJG-amazon-key"
  private_ip = "10.0.2.200"
  user_data = "${file("init.db.sh")}"

  vpc_security_group_ids = [ 
  aws_security_group.pavelsm_secgroup_db.id, 
  ] 
  
  tags = {
    Name = "PavelsM_DB"
    Owner = "Pavels M"
  }
}


output "WEB_instance_public_ip" {
  description = "Public IP of PavelsM_WEB EC2 instance"
  value       = aws_instance.PavelsM_WEB.public_ip
}

output "DB_instance_public_ip" {
  description = "Public IP of PavelsM_DB EC2 instance"
  value       = aws_instance.PavelsM_DB.public_ip
}