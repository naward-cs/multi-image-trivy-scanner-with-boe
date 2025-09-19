#!/bin/bash

# # List of images to scan
# IMAGES="
# ubuntu:20.04
# nginx:latest
# "

# # Loop through each image and run Trivy scan
# for IMAGE in $IMAGES; do
#   echo "Scanning image: $IMAGE"
#   trivy image \
#     --format template \
#     --template "@/home/nward/csv.tpl"  \
#     --severity CRITICAL,HIGH,MEDIUM,LOW  \
#     -o "trivy-report-${IMAGE/:/-}.csv" \
#     "$IMAGE"
#   echo "Scan complete for $IMAGE"
#   echo "----------------------------------------"
# done


# Define a list of image names and tags
IMAGES="
semaphoreui/semaphore:latest
freeipa/freeipa-server:latest
"

# Define the output file
OUTPUT_FILE="trivy-report-combined.csv"

# Print the CSV header once
echo '"Target","VulnerabilityID","Severity","PkgName","InstalledVersion","FixedVersion","Title","Description"' > "$OUTPUT_FILE"

# Loop through the images and append the Trivy output
for image in $IMAGES; do
  echo "Scanning $image..."
  trivy image \
    --format template \
    --template "@/home/nward/csv.tpl" \
    --severity LOW,MEDIUM,HIGH,CRITICAL \
    --ignore-status unknown,not_affected,will_not_fix \
    "$image" >> "$OUTPUT_FILE"
done