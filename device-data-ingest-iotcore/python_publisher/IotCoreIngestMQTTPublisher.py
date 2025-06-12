from AWSIoTPythonSDK.MQTTLib import AWSIoTMQTTClient
import json
from datetime import datetime

# Replace these with your actual paths and endpoint
client_id = "basicPubSub"
iot_endpoint = "a3w0igapc77zf8-ats.iot.us-east-1.amazonaws.com"
topic = "sdk/test/python"

#ca_path = "AmazonRootCA1.pem"
ca_path = "root-CA.crt"
cert_path = "Device-Data-IoT-Service.cert.pem"
key_path = "Device-Data-IoT-Service.private.key"

# Create and configure the MQTT client
mqtt_client = AWSIoTMQTTClient(client_id)
mqtt_client.configureEndpoint(iot_endpoint, 8883)
mqtt_client.configureCredentials(ca_path, key_path, cert_path)

# Optional: Set timeouts and retries
mqtt_client.configureOfflinePublishQueueing(-1)  # Infinite queueing
mqtt_client.configureDrainingFrequency(2)  # Draining: 2 Hz
mqtt_client.configureConnectDisconnectTimeout(10)
mqtt_client.configureMQTTOperationTimeout(5)

# Connect
print("Connecting to AWS IoT Core...")
mqtt_client.connect()
print("Connected!")

# Create a JSON payload
payload = {
    "message": "Hello AWS IoT Nilayam!",
    #"timestamp": datetime.utcnow().isoformat() + "Z",
    "temperature": 23.5,
    "payload": {
        "humidity": 45.6,
        "pressure": 1013.25
    }
}

# Publish to topic
print(f"Publishing to topic '{topic}'...")
mqtt_client.publish(topic, json.dumps(payload), 1)
print("Message published!")

# Disconnect
mqtt_client.disconnect()
print("Disconnected.")