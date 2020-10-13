//provider

provider "aws"{
region="ap-south-1"
profile="tera-user"
}

//variables

variable "github_repo_url"{

default="https://github.com/sahanabalappa/latestrepo.git"
}

variable "key" {

default="test_key"

}

variable "ami"{

 default="ami-0447a12f28fddb066"
}

variable "instance_type"{

default="t2.micro"

}

//generate_key

resource "tls_private_key" "my_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

output "myout" {
value=tls_private_key.my_key.private_key_pem
}


//aws_key_pair

resource "aws_key_pair" "generated_key" {

  key_name   = var.key
  public_key = tls_private_key.my_key.public_key_openssh
}
output  "my-key1" {
   value=aws_key_pair.generated_key
}



//aws_default_vpc


resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}
output "myvpc" {
   value=aws_default_vpc.default
}


//aws_security_group

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    description = "http from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0"]
  }
  ingress {
    description = "ssh from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_http"
  }
}

output "my-secure" {
  value=aws_security_group.allow_http
}



//aws_instance


resource "aws_instance" "my_instance" {
   depends_on=[aws_security_group.allow_http]
   ami = var.ami
   instance_type=var.instance_type
   key_name=var.key
   security_groups=["allow_http"]

   tags ={
        Name = "Myinstance"}
   }

//aws_ebs

resource "aws_ebs_volume" "my_vol" {
depends_on=[aws_instance.my_instance]
  availability_zone = aws_instance.my_instance.availability_zone
  size              = 2

  tags = {
    Name = "My_volume"
  }
}



//installing_and-conf_httpd

resource "null_resource" "my_httpd_conf"{
depends_on=[aws_instance.my_instance]
connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key=tls_private_key.my_key.private_key_pem
    host     = aws_instance.my_instance.public_ip
  }

provisioner "remote-exec" {
inline=[ 
                    
                      "sudo yum install httpd -y",
                       "sudo systemctl start httpd",
                        "sudo systemctl enable httpd"
              ]
 }
 } 


// public_ip_locally

resource "null_resource" "my_pk"{
depends_on=[aws_key_pair.generated_key]
provisioner "local-exec" {
    
         command= "echo  ${aws_instance.my_instance.public_ip}  > 1.txt"
}
}


//aws_ebs_attachment

resource "aws_volume_attachment" "ebs_att" {
depends_on=[aws_instance.my_instance]
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.my_vol.id
  instance_id =aws_instance.my_instance.id
  force_detach=true
}


//mounting


resource "null_resource" "mount_copy"{
depends_on=[aws_volume_attachment.ebs_att]
connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key=tls_private_key.my_key.private_key_pem
    host     = aws_instance.my_instance.public_ip
  }
provisioner "remote-exec" {
inline=[ 
                    
                      "sudo yum install git -y",
                       "sudo mkfs.ext4   /dev/xvdh",
                        "sudo mount /dev/xvdh   /var/www/html/",
                         "sudo chmod 777 /var/www/html/"


                         
              ]
 }
 } 


