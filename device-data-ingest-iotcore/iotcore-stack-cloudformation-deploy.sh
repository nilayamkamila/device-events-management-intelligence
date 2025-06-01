#aws cloudformation create-change-set \
#  --template-body file://iotcore-firehose-stream-iottopicrule-logger-lambda.yaml \
#  --stack-name iotcore-lambda-firehose-stack \
#  --change-set-name PreviewChangeSet \
#  --capabilities CAPABILITY_NAMED_IAM
#sleep 90
aws cloudformation deploy \
  --template-file iotcore-firehose-stream-iottopicrule-logger-lambda.yaml \
  --stack-name iotcore-lambda-firehose-stack \
  --parameter-overrides FirehoseStreamName=Device-Data-Stream-Firehose \
  --capabilities CAPABILITY_NAMED_IAM

#aws lambda add-permission \
#  --function-name device-data-iotcore-lambda \
#  --principal iot.amazonaws.com \
#  --statement-id AllowIoTInvokeFromTopicRule \
#  --action lambda:InvokeFunction \
#  --source-arn arn:aws:iot:us-east-1:337550871092:rule/DeviceDataIotcoreTopicRule