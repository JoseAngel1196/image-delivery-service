resource "aws_s3_bucket" "s3-web-application-bucket-image-delivery-service" {
  bucket        = "web-application-image-delivery-service"
  force_destroy = true

  tags = {
    Name = "s3-web-application-bucket-image-delivery-service"
  }
}

resource "aws_s3_bucket" "s3-server-application-bucket-image-delivery-service" {
  bucket        = "server-application-image-delivery-service"
  force_destroy = true

  tags = {
    Name = "s3-server-application-bucket-image-delivery-service"
  }
}

resource "aws_s3_bucket" "s3-nginx-conf-bucket-image-delivery-service" {
  bucket        = "nginx-conf-image-delivery-service"
  force_destroy = true

  tags = {
    Name = "s3-nginx-conf-bucket-image-delivery-service"
  }
}