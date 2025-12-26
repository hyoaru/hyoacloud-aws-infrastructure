#!/bin/bash
set -e

# Usage: ./scripts/destroy-core.sh [layer_name]
# Example: ./scripts/destroy-core.sh 000-iam-policies

LAYER=$1
REGION="ap-southeast-1"

# Input validation
if [[ -z "${LAYER}" ]]; then
  echo "Usage: ./scripts/destroy-core.sh [layer]"
  echo "Example: ./scripts/destroy-core.sh 000-iam-policies"
  exit 1
fi

# Get the current script directory
CURRENT_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIRECTORY="$(realpath "$CURRENT_DIRECTORY/..")"

# Define the parameters
TEMPLATE_FILE="${ROOT_DIRECTORY}/core/${LAYER}.yaml"
STACK_NAME="core-${LAYER}"

if [[ ! -f "${TEMPLATE_FILE}" ]]; then
  echo "Layer not found: $LAYER"
  exit 1
fi

echo -e "\nDESTROYING CORE RESOURCE"
echo "Stack: ${STACK_NAME}"
echo "Region: ${REGION}"

# Destroy
aws cloudformation delete-stack \
  --stack-name "${STACK_NAME}" \
  --region "${REGION}"

echo "Success! Stack ${STACK_NAME} has been deleted"
