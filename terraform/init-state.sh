#!/bin/bash

STATE_REGION="us-west-2"
STATE_PREFIX="infra-aws-backups-state"

account_id(){
	aws sts get-caller-identity --query "Account" --output text
}

create_tf_state_bucket() {
	ACCOUNT_ID=$(account_id)
	if [ -z "${ACCOUNT_ID}" ]; then
		echo "Cannot find account id .. exiting"
		exit 1
	fi

	STATE_BUCKET=$(aws --region "${STATE_REGION}" s3 ls | grep "${STATE_PREFIX}" | cut -d ' ' -f 3)
	if [ -z "${STATE_BUCKET}" ]; then
		# Poor mans $(openssl rand -hex 16) (openssl & dependancies are ~3MB)
		STATE_BUCKET="${STATE_PREFIX}-${ACCOUNT_ID}"

		echo "Creating remote state bucket ${STATE_BUCKET}"
		aws --region "${STATE_REGION}" s3 mb "s3://${STATE_BUCKET}"
		aws --region "${STATE_REGION}" s3api put-bucket-versioning --bucket "${STATE_BUCKET}" --versioning-configuration Status=Enabled
	else
		# Check for versionning
		BUCKET_VERSIONNING=$(aws --region "${STATE_REGION}" s3api get-bucket-versioning --bucket "${STATE_BUCKET}" | jq -r .Status)
		if [ "${BUCKET_VERSIONNING}" != "Enabled" ]; then
			echo "Enabling Versionning on state bucket"
			aws --region "${STATE_REGION}" s3api put-bucket-versioning --bucket "${STATE_BUCKET}" --versioning-configuration Status=Enabled
		fi
	fi
}

create_state_table() {
    ACCOUNT_ID=$(account_id)
    if [ -z "${ACCOUNT_ID}" ]; then
        echo "Cannot find account id .. exiting"
        exit 1
    fi

    STATE_TABLE=$(aws dynamodb list-tables --region "${STATE_REGION}" --query "TableNames[]" --output text | grep "${STATE_PREFIX}")
    if [ -z "${STATE_TABLE}" ]; then
        STATE_TABLE="${STATE_PREFIX}-${ACCOUNT_ID}"

        echo "Creating dynamodb state table ${STATE_TABLE}"
        aws dynamodb create-table \
            --region "${STATE_REGION}" \
            --table-name "${STATE_TABLE}" \
            --attribute-definitions AttributeName=LockID,AttributeType=S \
            --key-schema AttributeName=LockID,KeyType=HASH \
            --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1
    fi
}

create_tf_state_bucket
create_state_table
