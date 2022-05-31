resource "aws_iam_role" "iam-image-delivery-service-role" {
  name = "iam-image-delivery-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
            Service = "ec2.amazonaws.com"
        },
      },
    ]
  })

  tags = {
    tag-key = "iam-image-delivery-service-role"
  }
}

resource "aws_iam_instance_profile" "iam-image-delivery-service-instance-role" {
  name = "iam_image_delivery_service_instance_role"
  role = aws_iam_role.iam-image-delivery-service-role.name
}

resource "aws_iam_role_policy" "policy-image-delivery-service" {
  name = "policy-image-delivery-service"
  role = aws_iam_role.iam-image-delivery-service-role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}