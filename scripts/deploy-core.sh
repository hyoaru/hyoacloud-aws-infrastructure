#!/bin/bash
set -e

# Usage: ./scripts/deploy-core.sh [layer_name]
# Example: ./scripts/deploy-core.sh 000-iam-policies

LAYER=$1
REGION="ap-southeast-1"

# Input validation
if [[ -z "${LAYER}" ]]; then
  echo "Usage: ./scripts/deploy-core.sh [layer]"
  echo "Example: ./scripts/deploy-core.sh 000-iam-policies"
  exit 1
fi

# Get the current script directory
CURRENT_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIRECTORY="$(realpath "$CURRENT_DIRECTORY/..")"

# Define file paths
TEMPLATE_FILE="${ROOT_DIRECTORY}/core/${LAYER}.yaml"
STACK_NAME="core-${LAYER}"

if [[ ! -f "${TEMPLATE_FILE}" ]]; then
  echo "Template not found: $TEMPLATE_FILE"
  exit 1
fi

echo -e "\nDEPLOYING CORE RESOURCE"
echo "Stack: ${STACK_NAME}"
echo "Region: ${REGION}"
echo "Template: ${TEMPLATE_FILE}"

# Deploy
aws cloudformation deploy \
  --template-file "${TEMPLATE_FILE}" \
  --stack-name "${STACK_NAME}" \
  --region "${REGION}" \
  --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND \
  --no-fail-on-empty-changeset

echo "Success! Stack ${STACK_NAME} is active in ${REGION}"
