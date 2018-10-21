provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}"
  version = "1.13.0"
}

# ------ S3

resource "random_id" "bgs_bucket" {
  byte_length = 5
}

resource "aws_s3_bucket" "site" {
  bucket = "${var.dom_name}.${random_id.bgs_bucket.dec}"
  acl    = "public-read"

  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"AddPerm",
      "Effect":"Allow",
      "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::${var.dom_name}.${random_id.bgs_bucket.dec}/*"]
    }
  ]
}
POLICY

  website {
    index_document = "index.html"
    error_document = "404.html"
  }
}

resource "aws_s3_bucket_object" "index" {
  bucket  = "${aws_s3_bucket.site.id}"
  key     = "index.html"
  content = "<h1>S3 is not Site Static Service</h1>"

  content_type = "text/html"
}

resource "aws_s3_bucket_object" "404" {
  bucket  = "${aws_s3_bucket.site.id}"
  key     = "404.html"
  content = "<h1>OPSSS !!</h1>"

  content_type = "text/html"
}