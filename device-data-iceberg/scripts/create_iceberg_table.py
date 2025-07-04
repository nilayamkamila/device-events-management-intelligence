from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .appName("IcebergCreateTable") \
    .config("spark.sql.catalog.glue_catalog", "org.apache.iceberg.spark.SparkCatalog") \
    .config("spark.sql.catalog.glue_catalog.catalog-impl", "org.apache.iceberg.aws.glue.GlueCatalog") \
    .config("spark.sql.catalog.glue_catalog.io-impl", "org.apache.iceberg.aws.s3.S3FileIO") \
    .config("spark.sql.catalog.glue_catalog.warehouse", "s3://device-data-iceberg-s3warehouse/stores/") \
    .getOrCreate()

# Create a basic Iceberg table
spark.sql("""
    CREATE TABLE IF NOT EXISTS glue_catalog.icebergdb.sample_table (
        id INT,
        name STRING,
        created_at TIMESTAMP
    )
    USING iceberg
""")

print("✅ Iceberg table created!")

spark.sql("""
    INSERT INTO glue_catalog.icebergdb.sample_table VALUES
        (1, 'Alice', current_timestamp()),
        (2, 'Bob', current_timestamp()),
        (3, 'Charlie', current_timestamp())
""")

print("✅ Data inserted into Iceberg table!")

# Step 3: Read the data back
df = spark.sql("SELECT * FROM glue_catalog.icebergdb.sample_table")
df.show(truncate=False)

print("✅ Data read from Iceberg table!")
