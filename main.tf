resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.bucket_name
  tags   = var.bucket_tags
  force_destroy = true #allows to destroy bucket even if it is not empty
}

data "aws_iam_policy_document" "s3_read_permissions-website" {
  statement {
    effect = "Allow"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = [
      "s3:GetObject",
    ]
    resources = ["arn:aws:s3:::${var.bucket_name}/*",
    ]
  }
}

resource "aws_s3_bucket_ownership_controls" "bucket_ownership_controls" {
  bucket = aws_s3_bucket.s3_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  depends_on = [ aws_s3_bucket_public_access_block.bucket_public_access_block ]
}

resource "aws_s3_bucket_public_access_block" "bucket_public_access_block" {
  bucket                  = aws_s3_bucket.s3_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.s3_bucket.id
  depends_on = [ aws_s3_bucket_ownership_controls.bucket_ownership_controls ]
  acl = "public-read"
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.s3_bucket.id
  policy = data.aws_iam_policy_document.s3_read_permissions-website.json
  depends_on = [ aws_s3_bucket_public_access_block.bucket_public_access_block ]
}

resource "aws_s3_bucket_website_configuration" "bucket_website_configuration" {
  bucket = aws_s3_bucket.s3_bucket.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}


