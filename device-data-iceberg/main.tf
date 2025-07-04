provider "aws" {
  region = "us-east-1"
}

locals {
  jar_urls = [
    "${var.maven_base_2}/org/apache/iceberg/iceberg-spark-runtime-${var.iceberg_spark_version}/${var.iceberg_version}/iceberg-spark-runtime-${var.iceberg_spark_version}-${var.iceberg_version}.jar",
    "${var.maven_base_2}/org/apache/iceberg/iceberg-aws/${var.iceberg_version}/iceberg-aws-${var.iceberg_version}.jar",
    "${var.maven_base_2}/org/apache/iceberg/iceberg-api/${var.iceberg_version}/iceberg-api-${var.iceberg_version}.jar",
    "${var.maven_base_2}/org/apache/iceberg/iceberg-core/${var.iceberg_version}/iceberg-core-${var.iceberg_version}.jar",
    "${var.maven_base_2}/com/amazonaws/aws-java-sdk-bundle/${var.aws_sdk_version}/aws-java-sdk-bundle-${var.aws_sdk_version}.jar"
  ]

  jar_filenames = [
    "iceberg-spark-runtime-3.3_2.12-${var.iceberg_version}.jar",
    "iceberg-aws-${var.iceberg_version}.jar",
    "iceberg-api-${var.iceberg_version}.jar",
    "iceberg-core-${var.iceberg_version}.jar",
    "aws-java-sdk-bundle-${var.aws_sdk_version}.jar"
  ]
}
resource "null_resource" "download_jars" {
  provisioner "local-exec" {
    command = join(" && ", concat(
      ["mkdir -p jars"],
      [for i, url in local.jar_urls : "curl -L -o jars/${local.jar_filenames[i]} ${url}"]
    ))
  }

  triggers = {
    always_run = timestamp()
  }
}

resource "aws_s3_bucket" "iceberg_data" {
  bucket = "device-data-iceberg-s3warehouse"
  force_destroy = true
}

resource "aws_s3_object" "job_script" {
  bucket = aws_s3_bucket.iceberg_data.bucket
  key    = "scripts/create_iceberg_table.py"
  source = "${path.module}/scripts/create_iceberg_table.py"
}

resource "aws_s3_object" "upload_jars" {
  for_each = toset(local.jar_filenames)
  bucket = aws_s3_bucket.iceberg_data.bucket
  key    = "${var.s3_prefix}/${each.value}"
  source = "${path.module}/${var.s3_prefix}/${each.value}"
  depends_on = [null_resource.download_jars]
}

resource "aws_glue_catalog_database" "iceberg_db" {
  name = "icebergdb"
}

resource "aws_iam_policy" "iceberg_s3_policy" {
  name = "device-data-iceberg-glue-s3-access"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:GetBucketLocation"
        ],
        Resource = [
          "arn:aws:s3:::device-data-iceberg-s3warehouse",
          "arn:aws:s3:::device-data-iceberg-s3warehouse/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "glue_role" {
  name = "device-data-iceberg-glue-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "glue.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "glue_policy" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy_attachment" "attach_iceberg_s3" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.iceberg_s3_policy.arn
}

resource "aws_glue_job" "create_table" {
  name     = "device-data-gluejob-iceberg"
  role_arn = aws_iam_role.glue_role.arn

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket.iceberg_data.bucket}/scripts/create_iceberg_table.py"
    python_version  = "3"
  }

  glue_version = "5.0"

  default_arguments = {
    "--enable-glue-datacatalog" = "true"
    "--job-language"            = "python"
    "--TempDir"                 = "s3://${aws_s3_bucket.iceberg_data.bucket}/temp/"
    "--enable-glue-datacatalog" = "true"
    "--extra-jars" = join(",", [
      "s3://${aws_s3_bucket.iceberg_data.bucket}/${var.s3_prefix}/iceberg-aws-${var.iceberg_version}.jar",
      "s3://${aws_s3_bucket.iceberg_data.bucket}/${var.s3_prefix}/iceberg-core-${var.iceberg_version}.jar",
      "s3://${aws_s3_bucket.iceberg_data.bucket}/${var.s3_prefix}/iceberg-api-${var.iceberg_version}.jar",
      "s3://${aws_s3_bucket.iceberg_data.bucket}/${var.s3_prefix}/aws-java-sdk-bundle-${var.aws_sdk_version}.jar",
      "s3://${aws_s3_bucket.iceberg_data.bucket}/${var.s3_prefix}/iceberg-spark-runtime-${var.iceberg_spark_version}-${var.iceberg_version}.jar"
    ])
  }
  max_retries         = 0
  number_of_workers   = 2
  worker_type         = "G.1X"
}
