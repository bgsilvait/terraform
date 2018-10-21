output "Cloudfront_address" {
  value = "${aws_cloudfront_distribution.bgs_cldfront.domain_name}"
}

output "S3_Static_site" {
  value = "${aws_s3_bucket.site.id}.s3-website.${var.aws_region}.amazonaws.com"
}