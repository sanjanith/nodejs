resource "aws_instance" "tf_ec2_instance" {
  ami                         = "ami-084568db4383264d4"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.tf_ec2_sg.id]
  key_name                    = "terraform-ec2"
  depends_on                  = [aws_s3_object.tf_s3_object] # attach s3 bucket
  #user_data = file("ec2.sh")
  user_data                   = <<-EOT
                              #!/bin/bash

                              # Git clone 
                              git clone https://github.com/verma-kunal/nodejs-mysql.git /home/ubuntu/nodejs-mysql
                              cd /home/ubuntu/nodejs-mysql

                              # install nodejs
                              sudo apt update -y
                              sudo apt install -y nodejs npm

                              # edit env vars
                              echo "DB_HOST=${local.rds_endpoint}" | sudo tee -a .env
                              echo "DB_USER=${aws_db_instance.tf_rds_instance.username}" | sudo tee -a .env
                              sudo echo "DB_PASS=Sanju$0538" | sudo tee -a .env
                              echo "DB_NAME=${aws_db_instance.tf_rds_instance.db_name}" | sudo tee -a .env
                              echo "TABLE_NAME=users" | sudo tee -a .env
                              echo "PORT=3000" | sudo tee -a .env

                              # start server
                              npm install
                              EOT
  user_data_replace_on_change = true
  tags = {
    Name = "nodejs-ec2"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "terraform-ec2"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDuC/+IqC3bRLmWTIrSqgMor2rUTYmA43vFvxKkk0uiXskQ1DZfXm6Jd3LNwJywPIA6T/gDg3w9aGASEbiRB60K8LCiK1RrDfOqcid7kzjX54+NgbRMJCeadjLFxz8Zm7PazPHu1qFyNuZwGiHpLEy7cgcpWvVnvZ4l4MgHJ9Aduw9ekUeOehvond/H4Y3Wx3HcpZvhOPiYO5trHr6crbLN2RQBT2lXvJ6yYPAHwz3EoxjSsOyzSw6SlZ9wZys9VgEBN2DsmUo59igDVHV0vem1CDj/Y32o/p49Fe2QXVhO6wpER6CGTpfhkKEtewLYcvtLtoNBhwr9Uor2ux8usSkX terraform-ec2"
}


resource "aws_security_group" "tf_ec2_sg" {
  name        = "nodejs_securitygroup"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = "vpc-acf25bd7"

  tags = {
    Name = "allow_tls"
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # allow from all IPs
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TCP"
    from_port   = 3000 # for nodejs app
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#ingress{
# resource "aws_vpc_security_group_ingress_rule" "ingress1" {
#   security_group_id = aws_security_group.tf_ec2_sg.id
#   description       = "TLS from VPC"
#   from_port         = 443
#   to_port           = 443
#   ip_protocol       = "tcp"
#   cidr_ipv4         = "0.0.0.0/0"
# }

# resource "aws_vpc_security_group_ingress_rule" "ingress2" {
#   security_group_id = aws_security_group.tf_ec2_sg.id
#   description       = "SSH"
#   from_port         = 22
#   to_port           = 22
#   ip_protocol       = "tcp"
#   cidr_ipv4         = "0.0.0.0/0"
# }

# resource "aws_vpc_security_group_ingress_rule" "ingress3" {
#   description       = "TCP"
#   security_group_id = aws_security_group.tf_ec2_sg.id
#   from_port         = 3000
#   to_port           = 3000
#   ip_protocol       = "tcp"
#   cidr_ipv4         = "0.0.0.0/0"
# }

# #  egress{
# resource "aws_vpc_security_group_egress_rule" "egress1" {
#   security_group_id = aws_security_group.tf_ec2_sg.id
#   description       = "TCP"
#   from_port         = 0
#   to_port           = 0
#   ip_protocol       = "-1"
#   cidr_ipv4         = "0.0.0.0/0"
# }

output "ec2_ip" {
  value = aws_instance.tf_ec2_instance.public_ip
}