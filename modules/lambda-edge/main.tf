locals {
  source_file = "${path.root}/${var.lambda_file}"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${local.source_file}.zip"
  source_file = local.source_file
}

resource "aws_iam_role" "lambda_edge_role" {
  name = var.lambda_edge_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "edgelambda.amazonaws.com",
          "lambda.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = var.tags
}

resource "aws_lambda_function" "edge_security_headers_lambda" {
  function_name    = var.lambda_function_name
  filename         = data.archive_file.lambda_zip.output_path
  handler          = "${var.lambda_function_name}.handler"
  runtime          = "nodejs16.x"
  publish          = "true"                                           // In order to make Terraform create a new version of your function
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256 // Should only update when Lambda code changes
  role             = aws_iam_role.lambda_edge_role.arn
  tags             = var.tags
}
