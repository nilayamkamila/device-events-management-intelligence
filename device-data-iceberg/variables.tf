variable "existing_s3_bucket_name" {
  description = "Name of the existing S3 bucket to store Iceberg data and scripts"
  type        = string
}

variable "iceberg_version" {
  default = "1.2.1"
}

variable "iceberg_spark_version" {
  default = "3.3_2.12"
}

variable "aws_sdk_version" {
  default = "1.11.1026"
}

variable "s3_prefix" {
  default = "jars"
}

variable "maven_base_2" {
  default = "https://repo1.maven.org/maven2"
}
