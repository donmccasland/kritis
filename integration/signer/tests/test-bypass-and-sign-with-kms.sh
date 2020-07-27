#!/bin/bash

# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

echo ""
echo ""

set -eux

GOOD_IMAGE_URL=gcr.io/$PROJECT_ID/signer-int-good-image:$BUILD_ID
docker build --no-cache -t $GOOD_IMAGE_URL -f ./Dockerfile.good .

clean_up() { ARG=$?; delete_image $GOOD_IMAGE_URL; exit $ARG;}
trap 'clean_up'  EXIT

# push image
docker push $GOOD_IMAGE_URL
# get image url with digest format
GOOD_IMG_DIGEST_URL=$(docker image inspect $GOOD_IMAGE_URL --format '{{index .RepoDigests 0}}')

clean_up() { ARG=$?; delete_image $GOOD_IMAGE_URL; delete_occ $GOOD_IMG_DIGEST_URL; exit $ARG;}
trap 'clean_up'  EXIT

# sign image in bypass mode with kms
./signer -v 10 \
-alsologtostderr \
-mode=bypass-and-sign \
-image=${GOOD_IMG_DIGEST_URL} \
-kms_key_name=projects/$KMS_PROJECT/locations/$KMS_KEYLOCATION/keyRings/$KMS_KEYRING/cryptoKeys/$KMS_KEYNAME/cryptoKeyVersions/$KMS_KEYVERSION \
-kms_digest_alg=$KMS_DIGESTALG \
-policy=policy.yaml \
-note_name=${NOTE_NAME}

# deploy to a binauthz-enabled cluster signer-int-test
clean_up() { ARG=$?; delete_image $GOOD_IMAGE_URL; delete_occ $GOOD_IMG_DIGEST_URL; delete_pod signer-int-test-pod; exit $ARG;}
trap 'clean_up'  EXIT

sleep 5

deploy_image ${GOOD_IMG_DIGEST_URL} signer-int-test-pod

echo ""
echo ""
