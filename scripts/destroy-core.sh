#!/bin/bash
set -e

# Usage: ./scripts/destroy-core.sh [group] [layer]
# Example: ./scripts/destroy-core.sh 000-iam-policies 00-base

GROUP=$1
LAYER=$2
REGION="ap-southeast-1"

# Input validation
if [[ -z "${GROUP}" || -z "${LAYER}" ]]; then
  echo "Usage: ./scripts/destroy-core.sh [group] [layer]"
  echo "Example: ./scripts/destroy-core.sh 000-iam-policies 00-base"
  exit 1
fi

# Get the current script directory
CURRENT_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIRECTORY="$(realpath "$CURRENT_DIRECTORY/..")"

# Define the parameters
TEMPLATE_FILE="${ROOT_DIRECTORY}/core/${GROUP}/${LAYER}.yaml"
STACK_NAME="core-${GROUP}-${LAYER}"

if [[ ! -f "${TEMPLATE_FILE}" ]]; then
  echo "Template not found: $TEMPLATE_FILE"
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
