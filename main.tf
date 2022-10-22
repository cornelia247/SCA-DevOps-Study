provider "aws" {
  region     = "eu-west-2"
  access_key = "*****************"
  secret_key = "****************"
}

resource "aws_iam_role" "lambda_role" {
  name = "terraform_aws_lambda_role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action" :"sts:AssumeRole",
        "Principal": {
            "Service": "lamda.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid":    ""
      }
    ]
}
EOF
}
 #IAM policy for logging from a lambda
 
 resource "aws_iam_policy" "iam_policy_for_lambda" {
  name        = "aws_iam_policy_for_terraform_aws_lamda_role"
  path        = "/"
  description = "AWS I AM POLICY for managing aws lamda role"
  policy     =  <<EOF
{
    "Version" :"2012-10-17",
    "Statement" : [
     {
      "Action": [
         "logs:CreateLogGroup",
         "logs:CreateLogStream",
         "logs:PutLogEvents"
        ],
       "Resource" : "arn:aws:logs:*:*:*",
        "Effect"   : "Allow"
      }
    ]
}
EOF
}


resource "aws_iam_user_policy_attachment" "attach_iam_policy_to_iam_role" {
  user       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.iam_policy_for_lambda.arn
}

#Archive a single file. 

data "archive_file" "zip_the_python_code" {
  type        = "zip"
  source_dir = "${path.module}/python/"
  output_path = "${path.module}/python/hello-python.zip"
}

#Create a lamda function
#In terraform ${path.module} is the current directory.

resource "aws_lambda_function" "terraform_lambda_func" {
  filename      = "${path.module}/python/hello-python.zip"
  function_name = "jojo_lambda_function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "hello-python.lambda_handler"
  runtime       = "python3.8"
  depends_on    = [aws_iam_policy]
}
  

    
 
 