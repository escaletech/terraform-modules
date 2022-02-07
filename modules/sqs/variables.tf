variable "name" {
  description = "This is the human-readable name of the queue. If omitted, Terraform will assign a random name."
  type        = string
}

variable "environment" {
  description = "Type of environment where the queue will be running."
  type        = string
}

variable "delay_seconds" {
  description = "The time in seconds that the delivery of all messages in the queue will be delayed. An integer from 0 to 900 (15 minutes)"
  type        = number
  default     = 0
}

variable "max_message_size" {
  description = "The limit of how many bytes a message can contain before Amazon SQS rejects it. An integer from 1024 bytes (1 KiB) up to 262144 bytes (256 KiB)"
  type        = number
  default     = 262144
}

variable "message_retention_seconds" {
  description = "The number of seconds Amazon SQS retains a message. Integer representing seconds, from 60 (1 minute) to 1209600 (14 days)"
  type        = number
  default     = 345600
}

variable "receive_wait_time_seconds" {
  description = "The time for which a ReceiveMessage call will wait for a message to arrive (long polling) before returning. An integer from 0 to 20 (seconds)"
  type        = number
  default     = 0
}

variable "vpc_endpoint_name" {
  description = "VPC Endpoint tag Name to restrict SQS access. This is optional but if set, a policy will be applied to SQS queue restricting access over VPC endpoint. It requires vpc_name to be set, also"
  type        = string
  default     = null
}

variable "vpc_name" {
  description = "VPC Name. It's required only if you set sqs_endpoint_name."
  type        = string
  default     = null
}

variable "role_name" {
  description = "If set, attach a policy to this role allowing SQS SendMessage, ReceiveMessage and DeleteMessage."
  type        = string
  default     = null
}

variable "topic_arn" {
  description = "If set, a new statement will be added to allow the topic access the sqs."
  type        = string
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to all resources"
  type        = map(string)
  default     = {}
}

variable "fifo_queue" {
  description = "SQS type. If true, will create a FIFO queue."
  type        = bool
  default     = false
}

variable "content_based_deduplication" {
  description = "Enables content-based deduplication for FIFO queues."
  type        = bool
  default     = false
}

data "aws_region" "current" {}

data "aws_vpc" "vpc" {
  count = var.vpc_name != null ? 1 : 0
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_vpc_endpoint" "sqs" {
  count        = var.vpc_endpoint_name != null ? 1 : 0
  vpc_id       = data.aws_vpc.vpc[0].id
  service_name = "com.amazonaws.${data.aws_region.current.name}.sqs"
}

variable "redrive_policy" {
  description = "Redrive policy."
  type        = string
  default     = ""
}
