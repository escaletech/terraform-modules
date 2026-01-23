variable "name" {
  description = "The name of the ECR repository."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the repository."
  type        = map(string)
  default     = {}
}

variable "lifecycle_policy" {
  description = "The JSON policy text for the ECR lifecycle policy. If not specified, a default policy will be used to expire untagged images after 14 days and keep a maximum of 10 tagged images."
  type        = string
  default     = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire untagged images after 14 days",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 14
            },
            "action": {
                "type": "expire"
            }
        },
        {
            "rulePriority": 2,
            "description": "Keep last 10 tagged images",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["v"],
                "countType": "imageCountMoreThan",
                "countNumber": 10
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}
