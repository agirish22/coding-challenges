#!/bin/bash

# Install or update needed software
apt-get update
apt-get install -yq git supervisor python3-pip python3-venv jq

# Fetch source code
mkdir /opt/app
git clone https://github.com/agirish22/simple-flask-feedback-app.git /opt/app
# Python environment setup
python3 -m venv /opt/app/feedback/env
source /opt/app/feedback/env/bin/activate
pip3 install -r /opt/app/feedback/requirements.txt

# secrets URI is of the form projects/$PROJECT_NUMBER/secrets/$SECRET_NAME/versions/$SECRET_VERSION
secretUri=$(curl -sS "http://metadata.google.internal/computeMetadata/v1/instance/attributes/secret-id" -H "Metadata-Flavor: Google")

# split into array based on `/` delimeter
IFS="/" read -r -a secretsConfig <<< "$secretUri"

# get SECRET_NAME and SECRET_VERSION
SECRET_NAME=${secretsConfig[3]}
SECRET_VERSION=${secretsConfig[5]}

# access secret from secretsmanager
secrets=$(gcloud secrets versions access "$SECRET_VERSION" --secret="$SECRET_NAME")

# set secrets as env vars
# we want to use wordsplitting
export $(echo "$secrets" | jq -r "to_entries|map(\"\(.key)=\(.value|tostring)\")|.[]")

# Start application
cd /opt/app/
gunicorn feedback.main:app -b 0.0.0.0:80
