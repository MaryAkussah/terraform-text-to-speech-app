terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.5.0"
}

provider "aws" {
  region  = var.region
  profile = "default"
}

# -----------------------------
# S3 Bucket for Frontend
# -----------------------------
resource "aws_s3_bucket" "tts_site" {
  bucket        = var.s3_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "tts_site_website" {
  bucket = aws_s3_bucket.tts_site.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "tts_bucket_block" {
  bucket                  = aws_s3_bucket.tts_site.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "tts_site_policy" {
  bucket = aws_s3_bucket.tts_site.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.tts_site.arn}/*"
    }]
  })
}

# -----------------------------
# Lambda IAM Role & Policies
# -----------------------------
resource "aws_iam_role" "lambda_role" {
  name = "LambdaPollyRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_polly" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonPollyFullAccess"
}

# S3 Bucket for Audio Files
resource "aws_s3_bucket" "tts_audio" {
  bucket        = "my-tts-website-terraform-audio"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "tts_audio_bucket_block" {
  bucket                  = aws_s3_bucket.tts_audio.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_cors_configuration" "tts_audio_cors" {
  bucket = aws_s3_bucket.tts_audio.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "tts_audio_lifecycle" {
  bucket = aws_s3_bucket.tts_audio.id

  rule {
    id     = "delete_audio_files"
    status = "Enabled"

    filter {
      prefix = "audio/"
    }

    expiration {
      days = 7
    }
  }
}

resource "aws_iam_role_policy" "lambda_s3_policy" {
  name = "LambdaS3Policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["s3:PutObject", "s3:GetObject"]
      Resource = "${aws_s3_bucket.tts_audio.arn}/*"
    }]
  })
}

# DynamoDB Table for Metadata
resource "aws_dynamodb_table" "tts_metadata" {
  name           = "tts-metadata"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "user_id"
  range_key      = "audio_id"

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "audio_id"
    type = "S"
  }
}

resource "aws_iam_role_policy" "lambda_dynamodb_policy" {
  name = "LambdaDynamoDBPolicy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["dynamodb:PutItem", "dynamodb:GetItem", "dynamodb:Query"]
      Resource = aws_dynamodb_table.tts_metadata.arn
    }]
  })
}



# Lambda function moved to monitoring.tf with X-Ray tracing

# -----------------------------
# API Gateway HTTP API
# -----------------------------
resource "aws_apigatewayv2_api" "tts_api" {
  name          = "PollyTTSAPI"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins     = ["*"]
    allow_methods     = ["GET", "HEAD", "OPTIONS", "POST", "PUT"]
    allow_headers     = ["*"]
    expose_headers    = ["*"]
    max_age           = 86400
    allow_credentials = false
  }
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.tts_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.tts_lambda.arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "tts_route" {
  api_id    = aws_apigatewayv2_api.tts_api.id
  route_key = "POST /polly"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
  authorization_type = "JWT"
  authorizer_id = aws_apigatewayv2_authorizer.cognito_authorizer.id
}

# Stage moved to monitoring.tf with logging enabled

# -----------------------------
# Cognito User Pool
# -----------------------------
resource "aws_cognito_user_pool" "tts_user_pool" {
  name = "tts-user-pool"

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = false
    require_uppercase = true
  }

  auto_verified_attributes = ["email"]
}

resource "aws_cognito_user_pool_client" "tts_user_pool_client" {
  name         = "tts-user-pool-client"
  user_pool_id = aws_cognito_user_pool.tts_user_pool.id

  generate_secret                      = false
  prevent_user_existence_errors        = "ENABLED"
  explicit_auth_flows                  = ["ADMIN_NO_SRP_AUTH", "USER_PASSWORD_AUTH"]
  supported_identity_providers         = ["COGNITO"]
}

# -----------------------------
# API Gateway Authorizer
# -----------------------------
resource "aws_apigatewayv2_authorizer" "cognito_authorizer" {
  api_id           = aws_apigatewayv2_api.tts_api.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "cognito-authorizer"

  jwt_configuration {
    audience = [aws_cognito_user_pool_client.tts_user_pool_client.id]
    issuer   = "https://cognito-idp.${var.region}.amazonaws.com/${aws_cognito_user_pool.tts_user_pool.id}"
  }
}

# -----------------------------
# Permissions for Lambda to be called by API Gateway
# -----------------------------
resource "aws_lambda_permission" "api_gw_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.tts_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.tts_api.execution_arn}/*/*"
}

