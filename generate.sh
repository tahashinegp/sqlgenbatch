#!/bin/bash
# comment out these 2 lines after development is finished
export AWS_PROFILE=sqlgen-batch
export AWS_BATCH_JOB_ARRAY_INDEX=0

echo "Execution started for job id: $AWS_BATCH_JOB_ARRAY_INDEX"

export S3_BUCKET="oa-eui-dev-plt-env-kpidev-oa"
export ZIP_FILE="MVP+Dev_Snowflake_ES.zip"
export DB_FILE=$(echo $ZIP_FILE | sed -e s~\.zip~\.db~g)

# export SOURCE_DB_FILE="$S3_BUCKET/batch/$ZIP_FILE"
export SOURCE_DB_FILE="$S3_BUCKET/batch/$DB_FILE"
export DEST_FOLDER="$S3_BUCKET/batch/completed"
export JOB_FOLDER="$S3_BUCKET/batch/jobs/$AWS_BATCH_JOB_ARRAY_INDEX"

rm -rf inputs
mkdir -p inputs

echo "Checking if user files are present"
if [[ $(aws s3 ls s3://$JOB_FOLDER | head) ]]
then
    echo "Found job, processing"
	# aws s3 cp s3://$SOURCE_DB_FILE ./
    echo "Copying user files"
	aws s3 cp --include *.json --recursive s3://$JOB_FOLDER inputs/

	# echo "Unzipping db file"
	# unzip $ZIP_FILE
	# echo "Unzipping finished, deleting original zip"
	# rm -rf MVP+Dev_Snowflake_ES.zip
	echo "Processing user files"
	for USER_FILE in $(ls inputs)
	do 
		echo "Processing $USER_FILE file"
        echo "Copying raw db file from s3"
        aws s3 cp s3://$SOURCE_DB_FILE ./
        USER_QUERY_FILE="inputs/$USER_FILE"
        USER=$(cat $USER_QUERY_FILE | jq -r ".user")
        echo "Found user: $USER"

        USER_DB_FILE="$USER.db"
        USER_ZIP_FILE="$USER.zip"

        echo "Copying db file for user"
		mv $DB_FILE $USER_DB_FILE
        chmod 777 $USER_DB_FILE
        echo "Shriking database"
		python3 -u shrinkdb.py "$USER_DB_FILE" "$USER_QUERY_FILE"
        echo "Compressing user database"
		zip -m "$USER_ZIP_FILE" "$USER_DB_FILE"
        echo "Copying compressed user db to S3"
		aws s3 cp $USER_ZIP_FILE s3://$DEST_FOLDER/
        echo "Cleaning up user db"
		rm $USER_ZIP_FILE
		echo "Completed processing $USER_FILE"
	done
else 
		echo "No user files to process."
fi

echo "Execution finished for job id: $AWS_BATCH_JOB_ARRAY_INDEX"