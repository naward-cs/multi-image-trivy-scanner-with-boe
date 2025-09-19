#!/bin/bash

# Define a list of image names and tags
IMAGES="
semaphoreui/semaphore:v2.16.18
sonatype/nexus3:3.81.1
freeipa/freeipa-server:rocky-9-4.12.2
"

for image in $IMAGES; do
  ./boe-scan.sh "$image"
done