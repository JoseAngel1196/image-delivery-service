aws s3 cp nginx.conf s3://nginx-conf-image-delivery-service --profile developer_jhidalgo
aws s3 cp server s3://server-application-image-delivery-service --recursive --profile developer_jhidalgo
aws s3 cp web-application/ s3://web-application-image-delivery-service --recursive --profile developer_jhidalgo