
# ------------------------------------------------------
# Bucket For Dashboard
# ------------------------------------------------------
resource "aws_s3_bucket" "s3-web" {
  bucket = "${var.app_name}-web"
  tags = {
    Name = "s3-${var.app_name}"
    Enviroment = "dev"
  }
}

resource "aws_s3_bucket_acl" "s3-web" {
  bucket = aws_s3_bucket.s3-web.id
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "s3-web" {
  bucket = aws_s3_bucket.s3-web.id
  policy = templatefile("./templates/s3-policy-public-access.json", { bucket = "${var.app_name}-web" })
}

resource "aws_s3_bucket_website_configuration" "s3-web" {
  bucket = aws_s3_bucket.s3-web.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

output "s3_bucket_website_endpoint" {
  description = "The website endpoint, if the bucket is configured with a website. If not, this will be an empty string."
  value       = try(aws_s3_bucket_website_configuration.s3-web.website_endpoint, "")
}


# Cloudfront distribution for main s3 site.
resource "aws_cloudfront_distribution" "www_s3_distribution" {
  origin {
    domain_name = aws_s3_bucket_website_configuration.s3-web.website_endpoint
    origin_id = "S3-${var.app_name}"

    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  enabled = true
  is_ipv6_enabled = true
  default_root_object = "index.html"

  #  aliases = [var.app_name]

  custom_error_response {
    error_caching_min_ttl = 0
    error_code = 404
    response_code = 200
    response_page_path = "/404.html"
  }

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD"]
    cached_methods = ["GET", "HEAD"]
    target_origin_id = "S3-${var.app_name}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl = 31536000
    default_ttl = 31536000
    max_ttl = 31536000
    compress = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "cdf-${var.app_name}"
    Enviroment = "dev"
  }
}