#!/bin/bash
set -e

# Usage: ./scripts/destroy-space.sh [environment] [group] [layer]
# Example: ./scripts/destroy-space.sh dev 000-iam-policies

ENVIRONMENT=$1
GROUP=$2
LAYER=$3
REGION="ap-southeast-1"

# Input validation
if [[ -z "${ENVIRONMENT}" || -z "${GROUP}" || -z "${LAYER}" ]]; then
  echo "Usage: ./scripts/destroy-space.sh [environment] [group] [layer]"
  echo "Example: ./scripts/destroy-space.sh dev 000-iam-policies 00-base"
  exit 1
fi

# Get the current script directory
CURRENT_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIRECTORY="$(realpath "$CURRENT_DIRECTORY/..")"

# Define the parameters
TEMPLATE_FILE="${ROOT_DIRECTORY}/spaces/infrastructure/${GROUP}/${LAYER}.yaml"
STACK_NAME="space-${ENVIRONMENT}-${GROUP}-${LAYER}"

if [[ ! -f "${TEMPLATE_FILE}" ]]; then
  echo "Template not found: $TEMPLATE_FILE"
  exit 1
fi

echo -e "\nDESTROYING SPACE RESOURCE"
echo "Stack: ${STACK_NAME}"
echo "Region: ${REGION}"

# Destroy
aws cloudformation delete-stack \
  --stack-name "${STACK_NAME}" \
  --region "${REGION}"

echo "Success! Stack ${STACK_NAME} has been deleted"
