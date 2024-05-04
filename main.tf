# We need to create 7 resources to host a static website on s3 bucket.

resource "random_id" "bucket_suffix" {
  byte_length = 4
}
# Resource1: AWS S3 Bucket
resource "aws_s3_bucket" "static_website_bucket" {
  bucket        = "bucket-${formatdate("YYYY-MM-DD", timestamp())}-${random_id.bucket_suffix.hex}"
  tags          = var.tags
  depends_on    = [random_id.bucket_suffix]
  force_destroy = true # All objects(including locked objects) should be deleted when the bucket is destroyed without throwing any error

}

# Resource2: aws_s3_bucket_website_configuration
# ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration

resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.static_website_bucket.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }

}

# Resource3: aws_s3_bucket_versioning
# ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.static_website_bucket.id
  versioning_configuration {
    status = "Enabled"
  }

}

# Rsource4: aws_s3_ownership_controlls
# ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls

resource "aws_s3_bucket_ownership_controls" "bucket_ownership_config" {
  bucket = aws_s3_bucket.static_website_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }

}

# Resource5: aws_s3_public_access_block
# ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block

resource "aws_s3_bucket_public_access_block" "public_access_config" {
  bucket                  = aws_s3_bucket.static_website_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

}

# Resource6: aws_s3_bucket_acl
# ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block

resource "aws_s3_bucket_acl" "bucket_acl_config" {
  bucket = aws_s3_bucket.static_website_bucket.id
  acl    = "public-read"
  depends_on = [
    aws_s3_bucket_ownership_controls.bucket_ownership_config,
    aws_s3_bucket_public_access_block.public_access_config
  ]

}

# Resource7: aws_s3_bucket_policy
# ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.static_website_bucket.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Sid": "PublicReadGetObject",
          "Effect": "Allow",
          "Principal": "*",
          "Action": [
              "s3:GetObject"
          ],
          "Resource": [
              "arn:aws:s3:::${aws_s3_bucket.static_website_bucket.bucket}/*"
          ]
      }
  ]
}  
EOF
}

# Resource8: Upload objects to the bucket
    # refs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object
    
resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.static_website_bucket.bucket
  key    = var.index_file
  source = var.index_file
  content_type = "text/html"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = filemd5("index.html")
}