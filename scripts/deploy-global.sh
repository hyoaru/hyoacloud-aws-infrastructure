#!/bin/bash
set -e

# Usage: ./scripts/deploy-global.sh [environment] [layer_name]
# Example: ./scripts/deploy-global.sh dev 000-iam-policies

ENVIRONMENT=$1
LAYER=$2
REGION="ap-southeast-1"

# Input validation
if [[ -z "${ENVIRONMENT}" || -z "${LAYER}" ]]; then
  echo "Usage: ./scripts/deploy-global.sh [environment] [layer]"
  echo "Example: ./scripts/deploy-global.sh dev 000-iam-policies"
  exit 1
fi

# Get the current script directory
CURRENT_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIRECTORY="$(realpath "$CURRENT_DIRECTORY/..")"

# Define file paths
TEMPLATE_FILE="${ROOT_DIRECTORY}/global/infrastructure/${LAYER}.yaml"
PARAMETER_FILE="${ROOT_DIRECTORY}/global/parameters/${ENVIRONMENT}/${LAYER}.json"
STACK_NAME="global-${ENVIRONMENT}-${LAYER}"

if [[ ! -f "${TEMPLATE_FILE}" ]]; then
  echo "Template not found: $TEMPLATE_FILE"
  exit 1
fi

# If a parameter file exists for this env, read it. Otherwise, use empty defaults.
if [[ -f "$PARAMETER_FILE" ]]; then
  echo "Using parameter file: ${PARAMETER_FILE}"
  # Convert JSON file to "Key=Value" format for CLI
  PARAMS=$(jq -r 'to_entries | map("\(.key)=\(.value)") | .[]' $PARAMETER_FILE)
  PARAMETER_OVERRIDES="--parameter-overrides $PARAMS"
else
  echo "No parameter file found for ${ENVIRONMENT}. Using defaults."
  PARAMETER_OVERRIDES=""
fi

echo "-"
echo "DEPLOYING GLOBAL RESOURCE"
echo "Stack: ${STACK_NAME}"
echo "Region: ${REGION}"
echo "Template: ${TEMPLATE_FILE}"
echo "-"

# Deploy
aws cloudformation deploy \
  --template-file "$TEMPLATE_FILE" \
  --stack-name "$STACK_NAME" \
  --region "$REGION" \
  --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND \
  --no-fail-on-empty-changeset \
  $PARAMETER_OVERRIDES
