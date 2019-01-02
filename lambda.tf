resource "aws_iam_role" "example_lambda" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_logging" {
  name = "lambda_logging"
  path = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  policy_arn = "${aws_iam_policy.lambda_logging.arn}"
  role       = "${aws_iam_role.example_lambda.name}"
}

resource "aws_iam_role_policy_attachment" "example_lambda" {
  policy_arn  = "${aws_iam_policy.example_lambda.arn}"
  role        = "${aws_iam_role.example_lambda.name}"
}

resource "aws_iam_policy" "example_lambda" {
  name        = "policy_lambda"
  description = "A test policy"
  policy      = "${file("policysqsredis.json")}"
}

data "archive_file" "example_lambda" {
  type        = "zip"
  source_dir = "./lambda_package"
  output_path = "./example_lambda.zip"
}

resource "aws_lambda_function" "example_lambda" {
  function_name     = "example_lambda"
  handler           = "example_lambda.handler"
  role              = "${aws_iam_role.example_lambda.arn}"
  runtime           = "python3.6"

  filename          = "./example_lambda.zip"
  source_code_hash  = "${data.archive_file.example_lambda.output_base64sha256}"
  timeout           = 30
  memory_size       = 128
}

resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  batch_size        = 1
  event_source_arn  = "${aws_sqs_queue.terraform_queue.arn}"
  enabled           = true
  function_name     = "${aws_lambda_function.example_lambda.arn}"
}
