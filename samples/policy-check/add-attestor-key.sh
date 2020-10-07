#!/bin/bash
ATTESTOR_NAME=vuln-check-passed
KMS_KEY_PROJECT_ID=global-grammar-291814
KMS_KEYRING_NAME=attestors
KMS_KEY_NAME=vuln-check-signing-key
KMS_KEY_LOCATION=global
KMS_KEY_PURPOSE=asymmetric-signing
KMS_KEY_ALGORITHM=ec-sign-p256-sha256
KMS_PROTECTION_LEVEL=software
KMS_KEY_VERSION=1
gcloud --project="global-grammar-291814" \
    alpha container binauthz attestors public-keys add \
    --attestor="${ATTESTOR_NAME}" \
    --keyversion-project="${KMS_KEY_PROJECT_ID}" \
    --keyversion-location="${KMS_KEY_LOCATION}" \
    --keyversion-keyring="${KMS_KEYRING_NAME}" \
    --keyversion-key="${KMS_KEY_NAME}" \
    --keyversion="${KMS_KEY_VERSION}"
