resource "aws_iam_user" "vault-tor1-development" {
  name = "vault-tor1-development"
  path = "/"
}

resource "aws_iam_access_key" "vault-tor1-development" {
  depends_on = [
    aws_iam_user.vault-tor1-development
  ]
  user = aws_iam_user.vault-tor1-development.name
}

resource "aws_iam_user_policy" "vault-tor1-development" {
  name = aws_iam_user.vault-tor1-development.name
  user = aws_iam_user.vault-tor1-development.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:AttachUserPolicy",
        "iam:CreateAccessKey",
        "iam:CreateUser",
        "iam:DeleteAccessKey",
        "iam:DeleteUser",
        "iam:DeleteUserPolicy",
        "iam:DetachUserPolicy",
        "iam:GetUser",
        "iam:ListAccessKeys",
        "iam:ListAttachedUserPolicies",
        "iam:ListGroupsForUser",
        "iam:ListUserPolicies",
        "iam:PutUserPolicy",
        "iam:AddUserToGroup",
        "iam:RemoveUserFromGroup"
      ],
      "Resource": ["arn:aws:iam::368332934196:user/vault-*"]
    }
  ]
}



EOF
}

resource "aws_iam_policy" "daylite-api-tor1-development" {
  name        = "daylite-api-tor1-development"
  path        = "/"
  description = "Policy for the tor1-development cluster for daylite-api, granting read and write access to the bucket."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:GetObject",
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::marketcircle-development-daylite-attachments/*",
          "arn:aws:s3:::marketcircle-transient-daylite-attachments/*",
          "arn:aws:s3:::marketcircle-development-daylite-email-migration/*",
          "arn:aws:s3:::marketcircle-transient-daylite-email-migration/*",
        ]
      },
    ]
  })
}

resource "vault_aws_secret_backend" "aws" {
  depends_on = [
    aws_iam_access_key.vault-tor1-development
  ]
  access_key = aws_iam_access_key.vault-tor1-development.id
  secret_key = aws_iam_access_key.vault-tor1-development.secret

}

resource "vault_aws_secret_backend_role" "daylite-api" {
  backend         = vault_aws_secret_backend.aws.path
  name            = "daylite-api"
  credential_type = "iam_user"
  policy_arns = [
    aws_iam_policy.daylite-api-tor1-development.arn,
  ]
}
