output "glue_job_name" {
  value = aws_glue_job.create_table.name
}

output "iceberg-table_s3_path" {
  value = "s3://${aws_s3_bucket.iceberg_data.bucket}"
}

output "script_s3_path" {
  value = "s3://${var.existing_s3_bucket_name}/scripts/create_iceberg_table.py"
}
