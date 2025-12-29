#!/bin/bash
set -e

# Usage: ./scripts/destroy-space.sh [environment] [project] [group] [layer]
# Example: ./scripts/destroy-space.sh dev two-tier 000-iam-policies 000-base

ENVIRONMENT=$1
PROJECT=$2
GROUP=$3
LAYER=$4
REGION="ap-southeast-1"

# Input validation
if [[ -z "${ENVIRONMENT}" || -z "${PROJECT}" || -z "${GROUP}" || -z "${LAYER}" ]]; then
  echo "Usage: ./scripts/destroy-space.sh [environment] [group] [layer]"
  echo "Example: ./scripts/destroy-space.sh dev two-tier 000-iam-policies 000-base"
  exit 1
fi

# Get the current script directory
CURRENT_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIRECTORY="$(realpath "$CURRENT_DIRECTORY/..")"

# Define the parameters
TEMPLATE_FILE="${ROOT_DIRECTORY}/projects/${PROJECT}/infrastructure/${GROUP}/${LAYER}.yaml"
STACK_NAME="project-${PROJECT}-${ENVIRONMENT}-${GROUP}-${LAYER}"

if [[ ! -f "${TEMPLATE_FILE}" ]]; then
  echo "Template not found: $TEMPLATE_FILE"
  exit 1
fi

echo -e "\nDESTROYING PROJECT RESOURCE"
echo "Stack: ${STACK_NAME}"
echo "Region: ${REGION}"

# Destroy
aws cloudformation delete-stack \
  --stack-name "${STACK_NAME}" \
  --region "${REGION}"

echo "Success! Stack ${STACK_NAME} has been deleted"
