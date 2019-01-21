#!/bin/bash
environment_name="$1"
version_label="$2"
S3_BUCKET="hello-world-application"
echo "The value of $1 and $2"
cd ../Custom_Application && zip -r deployment.zip .
if aws s3 ls "s3://$S3_BUCKET" 2>&1 | grep -q 'NoSuchBucket'
then
      aws s3 mb s3://"$S3_BUCKET"
fi
aws s3 cp ../Custom_Application/deployment.zip s3://"$S3_BUCKET" --region ap-southeast-2
rm -rf ../Custom_Application/deployment.zip
aws elasticbeanstalk create-application-version --application-name eb-app-test-go-hello-world \
    --version-label "$version_label" \
    --source-bundle S3Bucket="hello-world-application",S3Key="deployment.zip" \
    --auto-create-application \
    --region ap-southeast-2
aws elasticbeanstalk update-environment --application-name eb-app-test-go-hello-world \
    --environment-name "$environment_name" \
    --version-label "$version_label" --region ap-southeast-2

