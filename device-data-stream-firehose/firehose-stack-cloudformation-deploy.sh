aws cloudformation create-change-set \
  --template-body file://firehose-s3-iamrole-lambda-logger.yaml \
  --stack-name Device-Data-Stream-Stack \
  --change-set-name PreviewChangeSet \
  --capabilities CAPABILITY_NAMED_IAM

aws cloudformation deploy \
  --template-file firehose-s3-iamrole-lambda-logger.yaml \
  --stack-name Device-Data-Stream-Stack \
  --capabilities CAPABILITY_NAMED_IAM