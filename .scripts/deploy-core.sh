#!/bin/bash
set -e

# Usage: ./scripts/deploy-core.sh [group] [layer]
# Example: ./scripts/deploy-core.sh identity user-self-management-policies

GROUP=$1
LAYER=$2
REGION="ap-southeast-1"

# Input validation
if [[ -z "${GROUP}" || -z "${LAYER}" ]]; then
  echo "Usage: ./scripts/deploy-core.sh [group] [layer]"
  echo "Example: ./scripts/deploy-core.sh identity user-self-management-policies"
  exit 1
fi

# Get the current script directory
CURRENT_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIRECTORY="$(realpath "$CURRENT_DIRECTORY/..")"

# Define file paths
TEMPLATE_FILE="${ROOT_DIRECTORY}/core/${GROUP}/${LAYER}.yaml"
STACK_NAME="core-${GROUP}-${LAYER}"

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
