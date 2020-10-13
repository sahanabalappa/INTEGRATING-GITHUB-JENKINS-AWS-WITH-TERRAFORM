// variable

variable "bucket_name"{
default="sahanabalappa"
}

//s3 bucket


resource "aws_s3_bucket" "my_bucket" {
depends_on=[aws_instance.my_instance]
bucket = var.bucket_name
acl    = "private"

tags = {
Name        = "My bucket"
Environment = "Dev"
}
}

//aws_s3_bucket_object

resource "aws_s3_bucket_object" "object" {
depends_on=[aws_s3_bucket.my_bucket]
bucket = var.bucket_name
key    = "workflow.PNG"
source="path/to/file/to/upload"    // i am using a  python script !(change.py) for updating this
content_type ="image/png"

}

//blocking_public_access

resource "aws_s3_account_public_access_block" "access" {
depends_on=[aws_s3_bucket_object.object]
block_public_acls   = true
block_public_policy = true
}

//cloudfront_OAI

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
depends_on=[aws_s3_bucket_object.object]
comment = "comments"
}

// updating_the_policy

data "aws_iam_policy_document" "s3_policy" {
statement {
actions   = ["s3:GetObject"]
resources = ["${aws_s3_bucket.my_bucket.arn}/*"]
principals {
type        = "AWS"
identifiers = [  aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn ]
}
}
}

//adding_the_policy

resource "aws_s3_bucket_policy" "policy" {
depends_on=[aws_s3_bucket_object.object]
bucket = aws_s3_bucket.my_bucket.id
policy = data.aws_iam_policy_document.s3_policy.json
}

//cloudfront_distribution

locals {
s3_origin_id = "myS3Origin"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
depends_on=[aws_s3_bucket_object.object]
origin {
domain_name = aws_s3_bucket.my_bucket.bucket_regional_domain_name
origin_id   = local.s3_origin_id
s3_origin_config {
origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
}
}


enabled             = true
is_ipv6_enabled     = true
comment             = "Some comment"
default_cache_behavior {
allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
cached_methods   = ["GET", "HEAD"]
target_origin_id = local.s3_origin_id
forwarded_values {
query_string = false
cookies {
forward = "none"
}
}

viewer_protocol_policy = "redirect-to-https"
min_ttl                = 0
default_ttl            = 200
max_ttl                = 36000
}

price_class = "PriceClass_All"
restrictions {
geo_restriction {
restriction_type = "none"
}
}
tags = {
Environment = "production"
}
viewer_certificate {
cloudfront_default_certificate = true
}
}


output "cloud_domain"{
value=aws_cloudfront_distribution.s3_distribution.domain_name
}



//altering_the_url_for_image_and_then_uploading_to_instance

resource "null_resource" "give_url"{
depends_on=[aws_cloudfront_distribution.s3_distribution,null_resource.mount_copy]
provisioner "local-exec" {
command= "python   main_file.py  https://${aws_cloudfront_distribution.s3_distribution.domain_name}/${aws_s3_bucket_object.object.key}"
}
}

//creating snapshot

resource "aws_ebs_snapshot" "my_vol_snap" {
depends_on=[aws_volume_attachment.ebs_att,null_resource.give_url]
  volume_id = aws_ebs_volume.my_vol.id

  tags = {
    Name = "MY_volume_snap"
  }
}



