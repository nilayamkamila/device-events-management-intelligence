##### Firehose Stack CloudFormation Deployment
Clone and Change the Directory
```
git clone git@github.com:nilayamkamila/device-events-management-intelligence.git
cd device-events-management-intelligence/device-data-stream-firehose
```
##### Review & Execute Firehose CloudFormation Template
- Review firehose-s3-iamrole-lambda-logger.yaml
- Execute command as below: firehose-stack-cloudformation-deploy.sh
- ```./firehose-stack-cloudformation-deploy.sh```

##### Create IoT Core Rule
cd device-events-management-intelligence/device-data-iot-core
- Review iotcore-firehose-stream-iottopicrule-logger-lambda.yaml
- Execute command as below: iotcore-stack-cloudformation-deploy.sh
```aidl
./iotcore-stack-cloudformation-deploy.sh
```
##### Update Lambda Function Allow IoT Core Rule
- Review the commented code in iotcore-stack-cloudformation-deploy.sh
- Execute command as below:
```aws lambda add-permission \
  --function-name device-data-iotcore-lambda \
  --principal iot.amazonaws.com \
  --statement-id AllowIoTInvokeFromTopicRule \
  --action lambda:InvokeFunction \
  --source-arn arn:aws:iot:us-east-1:337550871092:rule/DeviceDataIotcoreTopicRule
```
##### Test IoT Core Rule
- A Python Script is provided to test the IoT Core Rule.
- Review the script: IotCoreIngestMQTTPublisher.py
  All Certificates and Keys are to be captured from AWS Console by following the below link
    https://docs.aws.amazon.com/iot/latest/developerguide/iot-core-setup.html
- Execute the script as below:
- 
```
/usr/bin/python3 IotCoreIngestMQTTPublisher.py
```