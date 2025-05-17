resource "aws_s3_bucket" "tf_s3_bucket" {
  bucket = "nodejs-bucket-01-practice"

  tags = {
    Name        = "Nodejs Terraform bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_object" "tf_s3_object" {
  bucket = aws_s3_bucket.tf_s3_bucket.bucket
  for_each = fileset("C:\\Users\\SANJANITH\\Desktop\\nodejs-mysql\\public\\images", "**")
  key    = "images\\${each.key}"
  source = "C:\\Users\\SANJANITH\\Desktop\\nodejs-mysql\\public\\images"

}