terraform {
  required_version = ">= 1.5.5"
  required_providers {
    aws = "= 5.8.0"
  }
}
provider "aws" {
  region     = var.regionvalue
  access_key = var.access_key
  secret_key = var.secret_key
}
variable "regionvalue" {
  type        = string
  description = "Region"
}
variable "access_key" {
  type        = string
  description = "AWS Access Key"
}
variable "secret_key" {
  type        = string
  description = "AWS Secret Key"
}
variable "bucket_prefix" {
  type        = string
  description = "Unique name of the bucket"
}
resource "aws_s3_bucket" "s3" {
  bucket_prefix = var.bucket_prefix
  tags = {
    Name = var.bucket_prefix
  }
}
output "arn" {
  description = "ARN of the bucket"
  value       = aws_s3_bucket.s3.arn
}

output "name" {
  description = "Name (id) of the bucket"
  value       = aws_s3_bucket.s3.id
}

output "domainname" {
  description = "Domain Name of Bucket"
  value       = aws_s3_bucket.s3.bucket_domain_name
}
