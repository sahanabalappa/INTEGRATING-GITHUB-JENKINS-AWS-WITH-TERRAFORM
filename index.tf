
// this file will be created form the python script(main_file.py) which we have executed in s3_cloudfront.tf file 


resource "null_resource" "site"{

connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key=tls_private_key.my_key.private_key_pem
    host     = aws_instance.my_instance.public_ip
  }

provisioner "file"{

source="path/to/the/website/page"   // this will be updated when the main_file.py will execute
destination="/var/www/html/index.html" 
}
}
