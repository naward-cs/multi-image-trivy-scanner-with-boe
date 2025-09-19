#!/bin/bash

# Define a list of image names and tags
IMAGES="
semaphoreui/semaphore:v2.16.18
sonatype/nexus3:3.81.1
freeipa/freeipa-server:rocky-9-4.12.2
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
    --template "@template-csv-multi-report.tpl" \
    --severity LOW,MEDIUM,HIGH,CRITICAL \
    --ignore-status unknown,not_affected,will_not_fix \
    "$image" >> "$OUTPUT_FILE"
done