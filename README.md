# Terraform home lab
## Solution architecture
![Diagram drawio (1)](https://user-images.githubusercontent.com/6784580/230848998-9eb50855-5d49-44f5-b82b-6d3123f2248c.png)

## Terraform (whole [main.tf here](https://raw.githubusercontent.com/pavljiks/JG_TF/main/main.tf))

### VPC 
```
resource "aws_vpc" "pavelsm_vpc" {
  cidr_block = "10.0.0.0/16" }
```

### Web subnet
```
resource "aws_subnet" "pavelsm_web_subnet" {
  vpc_id     = aws_vpc.pavelsm_vpc.id
  cidr_block = "10.0.1.0/24" }
```

### DB subnet
```
resource "aws_subnet" "pavelsm_db_subnet" {
  vpc_id     = aws_vpc.pavelsm_vpc.id
  cidr_block = "10.0.2.0/24" }
```

### Internet gateway with default route
```
resource "aws_internet_gateway" "pavelsm_igw" {
  vpc_id = aws_vpc.pavelsm_vpc.id
}

resource "aws_default_route_table" "pavelsm_route_table" {
  default_route_table_id = aws_vpc.pavelsm_vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.pavelsm_igw.id
  }
}
```

### Web and DB security group
```
resource "aws_security_group" "pavelsm_secgroup_web" { 
  vpc_id = aws_vpc.pavelsm_vpc.id 
  ingress { 
    from_port   = 22 
    to_port     = 22 
    protocol    = "tcp" 
    cidr_blocks = ["0.0.0.0/0"]
  } 
  ingress { 
    from_port   = 80 
    to_port     = 80 
    protocol    = "tcp" 
    cidr_blocks = ["0.0.0.0/0"]
  }
...
resource "aws_security_group" "pavelsm_secgroup_db" { 
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
    cidr_blocks = ["10.0.1.100/32"] 
  }
  ...
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  } 
```
### Webserver instance with keyfile and user_data script
```
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
}
```
### DB instance with keyfile and user_data script
```
resource "aws_instance" "PavelsM_DB" {
  ami           = "ami-007855ac798b5175e"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.pavelsm_db_subnet.id
  key_name  = "pavelsJG-amazon-key"
  private_ip = "10.0.2.200"
  user_data = "${file("init.db.sh")}"

  vpc_security_group_ids = [ 
  aws_security_group.pavelsm_secgroup_db.id, 
  ] 
}
```
## Post `terraform apply` print out public ip of EC2
```
output "WEB_instance_public_ip" {
  description = "Public IP of PavelsM_WEB EC2 instance"
  value       = aws_instance.PavelsM_WEB.public_ip
}
```
---

## using terraform user_data init script (short vers.) 
1. Installs docker + docker-compose. 
2. Downloads and runs corresponding docker-compose [db](https://raw.githubusercontent.com/pavljiks/JG_TF/main/init.db.sh) or [web](https://raw.githubusercontent.com/pavljiks/JG_TF/main/init.web.sh)

```
#!/bin/bash
set -e 
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
apt-cache policy docker-ce
sudo apt install docker-ce docker-compose mysql-client-core-8.0 net-tools -y
curl -s -o /opt/webserver-compose https://raw.githubusercontent.com/pavljiks/JG_TF/main/webserver-compose
docker-compose -f /opt/webserver-compose up -d

echo "all done" >> /tmp/init.web.log 
```
---

## After wordpress initial config and sample page edit
![image](https://user-images.githubusercontent.com/6784580/230853946-8914d4a4-7d89-470d-9bbf-03b2efb4065a.png)


