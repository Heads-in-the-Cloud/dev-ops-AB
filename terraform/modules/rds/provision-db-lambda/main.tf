locals {
  payload = "provision-db-lambda/payload.zip"
}

# ------------------------------------------------------------------------------
# CREATE CLOUDWATCH RULES FOR EACH LOGICAL ROUTE TO MATCH EVENTS OF INTEREST
# ------------------------------------------------------------------------------

resource "aws_cloudwatch_event_rule" "captures" {
  for_each = var.event_routes

  name        = replace(replace(each.key, "[^\\.\\-_A-Za-z0-9]+", "-"), "_", "-")
  description = each.value.description

  event_pattern = jsonencode({
    "detail-type" = each.value.event_names
  })
}

# ------------------------------------------------------------------------------
# CONFIGURE EACH RULE TO FORWARD MATCHING EVENTS TO THE CORRESPONDING TARGET ARN
# ------------------------------------------------------------------------------

resource "aws_cloudwatch_event_target" "route" {
  for_each = var.event_routes

  target_id = each.key
  rule      = aws_cloudwatch_event_rule.captures[each.key].name
  arn       = each.value.target_arn
}

resource "aws_iam_role" "default" {
  name = "${var.project_id}-db-provision-lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "default" {
  function_name    = "provision_db"
  role             = aws_iam_role.default.arn
  filename         = local.payload
  source_code_hash = filebase64sha256(local.payload)
  handler          = "index.test"
  runtime          = "python3.8"

  environment {
    variables = {
      RDS_HOST            = aws_db_instance.default.address
      VPC_CIDR_BLOCK      = var.vpc.cidr_block
      RDS_DB_NAME         = var.name
      HELPER_FUNCTION_ARN =
      SECRET_NAME         = var.secret_id
    }
  }
}
