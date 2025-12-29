#!/bin/bash
set -e

# Usage: ./scripts/deploy-space.sh [environment] [project] [group] [layer]
# Example: ./scripts/deploy-space.sh dev two-tier 000-iam-policies 000-base

ENVIRONMENT=$1
PROJECT=$2
GROUP=$3
LAYER=$4
REGION="ap-southeast-1"

# Input validation
if [[ -z "${ENVIRONMENT}" || -z "${PROJECT}" || -z "${GROUP}" || -z "${LAYER}" ]]; then
  echo "Usage: ./scripts/deploy-space.sh [environment] [group] [layer]"
  echo "Example: ./scripts/deploy-space.sh dev two-tier 000-iam-policies 000-base"
  exit 1
fi

# Get the current script directory
CURRENT_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIRECTORY="$(realpath "$CURRENT_DIRECTORY/..")"

# Define file paths
TEMPLATE_FILE="${ROOT_DIRECTORY}/projects/${PROJECT}/infrastructure/${GROUP}/${LAYER}.yaml"
PARAMETER_FILE="${ROOT_DIRECTORY}/projects/${PROJECT}/parameters/${ENVIRONMENT}/${GROUP}/${LAYER}.json"
STACK_NAME="project-${PROJECT}-${ENVIRONMENT}-${GROUP}-${LAYER}"

if [[ ! -f "${TEMPLATE_FILE}" ]]; then
  echo "Template not found: $TEMPLATE_FILE"
  exit 1
fi

# If a parameter file exists for this env, read it. Otherwise, use empty defaults.
if [[ -f "$PARAMETER_FILE" ]]; then
  # Convert JSON file to "Key=Value" format for CLI
  PARAMS=$(jq -r 'to_entries | map("\(.key)=\(.value)") | .[]' $PARAMETER_FILE)
  PARAMETER_OVERRIDES="--parameter-overrides Region=${REGION} $PARAMS"
else
  echo "No parameter file found for ${ENVIRONMENT}. Using defaults."
  PARAMETER_OVERRIDES=""
fi

echo -e "\nDEPLOYING PROJECT RESOURCE"
echo "Stack: ${STACK_NAME}"
echo "Region: ${REGION}"
echo "Template: ${TEMPLATE_FILE}"

# Deploy
aws cloudformation deploy \
  --template-file "${TEMPLATE_FILE}" \
  --stack-name "${STACK_NAME}" \
  --region "${REGION}" \
  --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND \
  --no-fail-on-empty-changeset \
  $PARAMETER_OVERRIDES

echo "Success! Stack ${STACK_NAME} is active in ${REGION}"
