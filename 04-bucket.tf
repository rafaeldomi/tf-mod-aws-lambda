resource "aws_s3_bucket" "bucket" {
  count = var.s3_create_upload == false ? 0 : 1

  bucket = format("bkt-%s-%s", lower(var.function_name), lower(random_id.unique.hex))

  tags = {
    iac = "terraform"
  }
}

resource "aws_s3_object" "object" {
  count = var.s3_create_upload == false ? 0 : 1

  bucket = aws_s3_bucket.bucket[0].id
  key    = var.function_name
  source = data.archive_file.source[0].output_path
}
