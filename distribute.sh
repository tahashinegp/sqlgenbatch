#!/bin/bash
# comment out the next lines after development is finished
# export AWS_PROFILE=sqlgen-batch
export S3_BUCKET="oa-eui-dev-plt-env-kpidev-oa"
export USER_FOLDER="$S3_BUCKET/batch/users"
export JOBS_FOLDER="$S3_BUCKET/batch/jobs"
export COMPLETED_FOLDER="$S3_BUCKET/batch/completed"
export JOB_COUNT=100
export ZIP_FILE="MVP+Dev_Snowflake_ES.zip"
export DB_FILE=$(echo $ZIP_FILE | sed -e s~\.zip~\.db~g)
export SOURCE_DB_FILE="$S3_BUCKET/batch/$ZIP_FILE"
export DEST_DB_FILE="$S3_BUCKET/batch/$DB_FILE"

echo "Initializing for distributing files into $JOB_COUNT jobs"
rm -rf users
mkdir -p users

echo "Copying user input files locally"
aws s3 cp --recursive --include *.json s3://$USER_FOLDER/ ./users/

echo "Creating distribution folder"

rm -rf dist
mkdir -p dist
for i in $(seq $JOB_COUNT)
do
	mkdir -p dist/$((i-1))
done

CURRENT=0

echo "Distributing files"

for FILE in $(ls users)
do
	CURRENT_FOLDER="./dist/$CURRENT"
	cp ./users/$FILE $CURRENT_FOLDER

	if [ $CURRENT == $(($JOB_COUNT-1)) ]
	then
		CURRENT=0
	else
		CURRENT=$((CURRENT+1))
	fi
done

echo "Finished distributing files locally, copying to S3"
aws s3 rm --recursive s3://$JOBS_FOLDER/
echo "Cleaned up jobs folder"
aws s3 cp --recursive ./dist/ s3://$JOBS_FOLDER/
echo "Finished copying files, cleaning up completed folder"
aws s3 rm --recursive s3://$COMPLETED_FOLDER/
echo "Copying db file"
aws s3 cp s3://$SOURCE_DB_FILE ./
echo "Unzipping db file"
unzip $ZIP_FILE
echo "Unzipping finished, deleting original zip"
rm -rf MVP+Dev_Snowflake_ES.zip
echo "copy db file to s3"
aws s3 cp $DB_FILE s3://$DEST_DB_FILE
echo "DB file copying finished"
echo "Finished distribution"