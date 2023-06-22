
FROM ubuntu:18.04
## Install AWS CLI
RUN apt-get update && \
    apt-get install -y \
        python3 \
        python3-pip \
        python3-setuptools \
        groff \
        less \
        jq \
        zip \
        unzip \
    curl \
    && curl -sL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip \
    && unzip awscliv2.zip \
    && aws/install \
    && rm -rf awscliv2.zip \
    && apt-get clean 
RUN mkdir /var/batchjob
## Set Your AWS Access credentials
ARG AWS_ACCESS_KEY_ID
ENV AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ENV AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
ARG AWS_DEFAULT_REGION=eu-west-1
#RUN /bin/bash -l -c "aws s3 cp s3://oa-eui-dev-plt-env-kpidev-oa/batch/MVP+Dev_Snowflake_ES.zip /var/batchjob"
#RUN unzip -q /var/batchjob/MVP+Dev_Snowflake_ES.zip
#RUN /bin/bash -l -c "mv /var/batchjob/MVP+Dev_Snowflake_ES.db /var/batchjob/Snowflake_ES.db"
#RUN /bin/bash -l -c "rm -rf /var/batchjob/MVP+Dev_Snowflake_ES.zip"
## download sqlite3 db
WORKDIR /var/batchjob
## Entry Point
COPY . /var/batchjob/
CMD chmod 777 /var/batchjob/*.sh
ENTRYPOINT ["/bin/bash","-c","/var/batchjob/start.sh"]
