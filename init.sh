#!/bin/bash

# Provide project, organization, billing account id, service account creation key boolean, support email for IAP, as arguments
#
# Set $BILLING_ACCOUNT_ID to false or ID, false when billing permissions are not granted
# Set $CREATE_SERVICE_ACCOUNT_KEY to true or false, false if Terraform account is not yet created
#
# gcloud commands to get Organization ID, Project Name, and Billing Account ID
# gcloud organizations list
# gcloud projects list
# gcloud alpha billing accounts list --filter=open=true
#

# DEV: simplycubed-builder-dev
# export PROJECT_NAME="simplycubed-builder-dev"
# export ORGANIZATION_ID="1013393027722"
# export BILLING_ACCOUNT_ID="false"
# export CREATE_SERVICE_ACCOUNT_KEY="false"
# export SUPPORT_EMAIL="support@simplycubed.com"
#
# PROD: simplycubed-builder-prod
# export PROJECT_NAME="simplycubed-builder-prod"
# export ORGANIZATION_ID="1013393027722"
# export BILLING_ACCOUNT_ID="false"
# export CREATE_SERVICE_ACCOUNT_KEY="false"
# export SUPPORT_EMAIL="support@simplycubed.com"
#
# ./init.sh $PROJECT_NAME $ORGANIZATION_ID $BILLING_ACCOUNT_ID $CREATE_SERVICE_ACCOUNT_KEY $SUPPORT_EMAIL
#
# Initial execution set CREATE_SERVICE_ACCOUNT_KEY to "true" however subsequent runs to "false"

# Fail fast when a command fails or a variable is undefined
set -eu

if [ $# -eq 0 ]; then
  echo "No arguments supplied"
  exit 1
fi

PROJECT_NAME=$1
ORGANIZATION_ID=$2
BILLING_ACCOUNT_ID=$3
CREATE_SERVICE_ACCOUNT_KEY=$4
SUPPORT_EMAIL=$5

echo ""
echo "Preparing Terraform resources and service account with the following values:"
echo "==================================================="
echo "PROJECT_NAME: $PROJECT_NAME"
echo "ORGANIZATION_ID: $ORGANIZATION_ID"
echo "BILLING_ACCOUNT_ID: $BILLING_ACCOUNT_ID"
echo "CREATE_SERVICE_ACCOUNT_KEY: $CREATE_SERVICE_ACCOUNT_KEY"
echo "SUPPORT_EMAIL: $SUPPORT_EMAIL"
echo "==================================================="
echo ""
echo "Continuing in 5 seconds. Ctrl+C to cancel"
sleep 5

echo "=> Creating project inside the organization ${ORGANIZATION_ID}"
project_exists=$(gcloud projects list --filter "$PROJECT_NAME" | grep "$PROJECT_NAME" | wc -l | tr -d ' ' | head -n 1)
if [ "$project_exists" = "0" ]; then
  gcloud projects create $PROJECT_NAME --organization $2
else
  echo "=> Project already exists. Skipping"
fi

project_id=$(gcloud projects list --filter $PROJECT_NAME | grep ${PROJECT_NAME} | awk '{print $1}' | head -n 1)

if [ "$BILLING_ACCOUNT_ID" != "false" ]; then
  echo "=> Linking $BILLING_ACCOUNT_ID Billing Account to your project"
  gcloud beta billing projects link $project_id \
    --billing-account=$BILLING_ACCOUNT_ID
fi

# Full list of services
# gcloud services list --available
echo "=> Enabling required APIs"
gcloud --project $project_id services enable bigquery.googleapis.com
gcloud --project $project_id services enable bigquerystorage.googleapis.com
gcloud --project $project_id services enable cloudbilling.googleapis.com
gcloud --project $project_id services enable cloudbuild.googleapis.com
gcloud --project $project_id services enable cloudfunctions.googleapis.com
gcloud --project $project_id services enable cloudkms.googleapis.com
gcloud --project $project_id services enable cloudresourcemanager.googleapis.com
gcloud --project $project_id services enable compute.googleapis.com
gcloud --project $project_id services enable container.googleapis.com
gcloud --project $project_id services enable dns.googleapis.com
gcloud --project $project_id services enable iam.googleapis.com
gcloud --project $project_id services enable iap.googleapis.com
gcloud --project $project_id services enable oslogin.googleapis.com
gcloud --project $project_id services enable redis.googleapis.com
gcloud --project $project_id services enable secretmanager.googleapis.com
gcloud --project $project_id services enable servicenetworking.googleapis.com
gcloud --project $project_id services enable sql-component.googleapis.com
gcloud --project $project_id services enable sqladmin.googleapis.com

gcloud --project $project_id services enable identitytoolkit.googleapis.com

# TODO: Monitor this new feature request to automate Enabling the Identity Platform
echo "=> Need to manually 'Enable Identity Platform', this is a known limitation"
echo "=> https://issuetracker.google.com/issues/186147991?pli=1#comment6"

echo "=> Project APIs enabled successfully"

# Full is of IAM roles
# https://cloud.google.com/iam/docs/understanding-roles
service_account_exists=$(gcloud iam service-accounts list --project $project_id --filter terraform | grep terraform | wc -l | tr -d ' ')
if [ "$service_account_exists" = "0" ]; then
  gcloud iam service-accounts create terraform \
    --display-name "Terraform admin account" \
    --project $project_id
  echo "=> Creating terraform service account"
else
  echo "=> Service Account already exist"
fi

echo "=> Setting Terraform IAM permissions"

gcloud projects add-iam-policy-binding $project_id \
  --member "serviceAccount:terraform@${project_id}.iam.gserviceaccount.com" \
  --role="roles/editor"
gcloud projects add-iam-policy-binding $project_id \
  --member "serviceAccount:terraform@${project_id}.iam.gserviceaccount.com" \
  --role="roles/iam.securityAdmin"
gcloud projects add-iam-policy-binding $project_id \
  --member "serviceAccount:terraform@${project_id}.iam.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor"
gcloud projects add-iam-policy-binding $project_id \
  --member "serviceAccount:terraform@${project_id}.iam.gserviceaccount.com" \
  --role="roles/servicenetworking.networksAdmin"
gcloud projects add-iam-policy-binding $project_id \
  --member "serviceAccount:terraform@${project_id}.iam.gserviceaccount.com" \
  --role="roles/container.admin"
gcloud projects add-iam-policy-binding $project_id \
  --member "serviceAccount:terraform@${project_id}.iam.gserviceaccount.com" \
  --role="roles/iap.settingsAdmin"
gcloud projects add-iam-policy-binding $project_id \
  --member "serviceAccount:terraform@${project_id}.iam.gserviceaccount.com" \
  --role="roles/iam.roleAdmin"
gcloud projects add-iam-policy-binding $project_id \
  --member "serviceAccount:terraform@${project_id}.iam.gserviceaccount.com" \
  --role="roles/cloudfunctions.admin"

if [ "$CREATE_SERVICE_ACCOUNT_KEY" = true ]; then
  echo "=> Creating key for service account, check key.json file in the root of this project"
  gcloud iam service-accounts keys create key.json \
    --iam-account "terraform@${project_id}.iam.gserviceaccount.com"
fi

# Create OAUTH Brand Application
IAP_BRAND_NAME=$(gcloud alpha iap oauth-brands list --project $project_id | grep name | cut -f 2 -d ' ' | head -n 1)

oauth_exists=$(gcloud alpha iap oauth-brands list --project $project_id | grep name | cut -f 2 -d ' ')
if [ "$oauth_exists" = "0" ]; then
  gcloud alpha iap oauth-brands create --application_title="OAUTH Tooling" --support_email=$SUPPORT_EMAIL --project $project_id
  IAP_BRAND_NAME=$(gcloud alpha iap oauth-brands list --project $project_id | grep name | cut -f 2 -d ' ' | head -n 1)
  echo "=> Create OAUTH Brand Application"
else
  echo "=> OAUTH Brand Application already exists"
fi

echo "OUTPUT"
echo "================================="
echo "IAP BRAND NAME: $IAP_BRAND_NAME"
echo "================================="
