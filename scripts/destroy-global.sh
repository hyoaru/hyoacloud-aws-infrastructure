#!/bin/bash
set -e

# Usage: ./scripts/destroy-global.sh [environment] [layer_name]
# Example: ./scripts/destroy-global.sh dev 000-iam-policies

ENVIRONMENT=$1
LAYER=$2
REGION="ap-southeast-1"

# Input validation
if [[ -z "${ENVIRONMENT}" || -z "${LAYER}" ]]; then
  echo "Usage: ./scripts/destroy-global.sh [environment] [layer]"
  echo "Example: ./scripts/destroy-global.sh dev 000-iam-policies"
  exit 1
fi

# Get the current script directory
CURRENT_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIRECTORY="$(realpath "$CURRENT_DIRECTORY/..")"

# Define the parameters
STACK_NAME="global-${ENVIRONMENT}-${LAYER}"

echo -e "\nDESTROYING GLOBAL RESOURCE"
echo "Stack: ${STACK_NAME}"
echo -e "Region: ${REGION}\n"

# Destroy
aws cloudformation delete-stack \
  --stack-name "${STACK_NAME}" \
  --region "${REGION}"

echo "Success! Stack ${STACK_NAME} has been deleted"
