output "bucket_name" {
  description = "bucket name of static website"
  value       = aws_s3_bucket.static_website_bucket.id

}

output "arn" {
  description = "ARN of bucket"
  value       = aws_s3_bucket.static_website_bucket.arn

}

output "bucket_domain_name" {
  description = "domain name"
  value       = aws_s3_bucket.static_website_bucket.bucket_domain_name

}

output "bucket_regional_domain_name" {
  value       = aws_s3_bucket.static_website_bucket.bucket_regional_domain_name
  description = "regional domain"

}
output "static_website_url" {
    description = "website url"
    value = "http://${aws_s3_bucket.static_website_bucket.bucket}.s3-website-${aws_s3_bucket.static_website_bucket.region}.amazonaws.com"
    
  
}