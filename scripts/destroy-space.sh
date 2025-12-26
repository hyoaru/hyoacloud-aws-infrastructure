#!/bin/bash
set -e

# Usage: ./scripts/destroy-space.sh [environment] [layer_name]
# Example: ./scripts/destroy-space.sh dev 000-iam-policies

ENVIRONMENT=$1
LAYER=$2
REGION="ap-southeast-1"

# Input validation
if [[ -z "${ENVIRONMENT}" || -z "${LAYER}" ]]; then
  echo "Usage: ./scripts/destroy-space.sh [environment] [layer]"
  echo "Example: ./scripts/destroy-space.sh dev 000-iam-policies"
  exit 1
fi

# Get the current script directory
CURRENT_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIRECTORY="$(realpath "$CURRENT_DIRECTORY/..")"

# Define the parameters
STACK_NAME="space-${ENVIRONMENT}-${LAYER}"

echo -e "\nDESTROYING SPACE RESOURCE"
echo "Stack: ${STACK_NAME}"
echo "Region: ${REGION}"

# Destroy
aws cloudformation delete-stack \
  --stack-name "${STACK_NAME}" \
  --region "${REGION}"

echo "Success! Stack ${STACK_NAME} has been deleted"
