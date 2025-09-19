#!/bin/bash

# --- Check for Docker and Trivy ---
if ! command -v docker &> /dev/null
then
    echo "Docker could not be found. Please install Docker and try again."
    exit 1
fi

if ! command -v trivy &> /dev/null
then
    echo "Trivy could not be found. Please install Trivy and try again."
    echo "Refer to the official Trivy documentation for installation instructions: https://trivy.dev/"
    exit 1
fi

if ! command -v jq &> /dev/null
then
    echo "jq could not be found. Please install jq and try again."
    exit 1
fi

# --- Check for image name argument ---
if [ -z "$1" ]
then
    echo "Usage: $0 <image_name>:<tag>"
    exit 1
fi

IMAGE_NAME=$1

# --- Create a directory for the reports ---
OUTPUT_DIR="boe_${IMAGE_NAME//[:\/]/-}"
mkdir -p "$OUTPUT_DIR"
echo "Creating evidence directory: $OUTPUT_DIR"
echo ""

echo "====================================================="
echo "  Obtaining 'Body of Evidence' for Docker Image: $IMAGE_NAME"
echo "====================================================="

# --- Pull Image ---
echo "--- Pulling Image for quick use ---"
docker pull "$IMAGE_NAME"

# --- 1. Get Image Manifest and Configuration ---
echo "--- 1. Image Manifest and Configuration (docker inspect) ---"
docker inspect "$IMAGE_NAME" > "$OUTPUT_DIR/docker_inspect.json"
echo "Saved to $OUTPUT_DIR/docker_inspect.json"
echo ""

# --- 2. List all layers ---
echo "--- 2. Image Layers (docker history) ---"
docker history --no-trunc "$IMAGE_NAME"> "$OUTPUT_DIR/docker_history.txt"
echo "Saved to $OUTPUT_DIR/docker_history.txt"
echo ""

# --- 3. Explore the filesystem within a temporary container ---
echo "--- 3. Filesystem Tree (ls -R) ---"
docker run --rm -it "$IMAGE_NAME" ls -R / 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g' > "$OUTPUT_DIR/filesystem_tree.txt"
echo "Saved to $OUTPUT_DIR/filesystem_tree.txt"
echo ""

#--- 4. Generate a human-readable summary of the Trivy report ---
echo "--- 4. Trivy Scan Summary ---"
echo "Here is a summary of the Trivy scan findings:"
#trivy image --severity HIGH,CRITICAL,MEDIUM,LOW --ignore-status unknown,not_affected,will_not_fix "$IMAGE_NAME"
trivy image \
  --severity HIGH,CRITICAL,MEDIUM,LOW \
  --ignore-status unknown,not_affected,will_not_fix \
  --format template \
  --template "@template-summary-report.tpl" \
  "$IMAGE_NAME" | tee "$OUTPUT_DIR/trivy_summary.txt"
# trivy image \
#   --severity HIGH,CRITICAL,MEDIUM,LOW \
#   --ignore-status unknown,not_affected,will_not_fix \
#   --format template \
#   --template "@template-summary-report.tpl" \
#   "$IMAGE_NAME" > "$OUTPUT_DIR/trivy_summary.txt"
echo ""

# --- 5. Perform a comprehensive security scan with Trivy ---
echo "--- 5. Security Scan with Trivy ---"
echo "Note: This may take a moment as Trivy downloads the vulnerability database."
echo "Scanning for vulnerabilities, misconfigurations, and secrets..."
trivy image \
  --severity HIGH,CRITICAL,MEDIUM,LOW \
  --ignore-status unknown,not_affected,will_not_fix \
  --output "$OUTPUT_DIR/trivy_scan_report.txt" \
  "$IMAGE_NAME"
trivy image \
  --severity HIGH,CRITICAL,MEDIUM,LOW \
  --ignore-status unknown,not_affected,will_not_fix \
  --format json \
  --output "$OUTPUT_DIR/trivy_scan_report.json" \
  "$IMAGE_NAME"
trivy image \
  --severity HIGH,CRITICAL,MEDIUM,LOW \
  --ignore-status unknown,not_affected,will_not_fix \
  --format template --template "@template-html-report.tpl" \
  --output "$OUTPUT_DIR/trivy_scan_report.html" \
  "$IMAGE_NAME"
trivy image \
  --severity HIGH,CRITICAL,MEDIUM,LOW \
  --ignore-status unknown,not_affected,will_not_fix \
  --format template --template "@template-csv-report.tpl" \
  --output "$OUTPUT_DIR/trivy_scan_report.csv" \
  "$IMAGE_NAME"
 echo "Trivy scan completed. Two Report saved to $OUTPUT_DIR/trivy_scan_report.txt and $OUTPUT_DIR/trivy_scan_report.json"
 echo ""

# --- 6. Generate a SBOM with Trivy report ---
echo "--- 6. creating SBOM ---"
# if command -v syft &> /dev/null
# then
#     echo "Generating SBOM with Syft..."
#     syft "$IMAGE_NAME" -o cyclonedx-json > "$OUTPUT_DIR/sbom-cdx.json"
#     syft "$IMAGE_NAME" -o spdx-json > "$OUTPUT_DIR/sbom-spdx.json"
#     echo "2 SBOMs generated using Syft and saved to $OUTPUT_DIR/sbom-spdx.json and $OUTPUT_DIR/sbom-cdx.json"
# else
echo "Generating SBOM with Trivy..."
trivy image \
  --severity HIGH,CRITICAL,MEDIUM,LOW \
  --ignore-status unknown,not_affected,will_not_fix \
  --format cyclonedx \
  --output "$OUTPUT_DIR/sbom-cdx.json" \
  "$IMAGE_NAME" 
trivy image \
  --severity HIGH,CRITICAL,MEDIUM,LOW \
  --ignore-status unknown,not_affected,will_not_fix \
  --format spdx-json \
  --output "$OUTPUT_DIR/sbom-spdx.json" \
  "$IMAGE_NAME"
echo "SBOM generated using Trivy and saved to $OUTPUT_DIR/sbom.json"
# fi
echo ""

echo "====================================================="
echo "  Generating a single text document..."
echo "====================================================="
(
  echo "Body of Evidence for Docker Image: $IMAGE_NAME"
  echo "--------------------------------------------------------"
  echo "Summary"
  echo "Image Name: $IMAGE_NAME"
  echo "Generated On: $(date)"
  echo ""
  
  echo "--------------------------------------------------------"
  echo "Docker Inspect Metadata"
  echo "--------------------------------------------------------"
  jq '.' "${OUTPUT_DIR}/docker_inspect.json"
  echo ""

  echo "--------------------------------------------------------"
  echo "Docker Image History"
  echo "--------------------------------------------------------"
  cat "${OUTPUT_DIR}/docker_history.txt"

  echo "--------------------------------------------------------"
  echo "Vulnerability  Summary"
  echo "--------------------------------------------------------"
  cat "${OUTPUT_DIR}/trivy_summary.txt"
  echo ""

  echo "--------------------------------------------------------"
  echo "Vulnerability Report"
  echo "--------------------------------------------------------"
  cat "${OUTPUT_DIR}/trivy_scan_report.txt"
  echo ""

  echo "--------------------------------------------------------"
  echo "Software Bill of Materials (SBOM)"
  echo "--------------------------------------------------------"
  jq '.' "${OUTPUT_DIR}/sbom-spdx.json"
  echo ""
  
  echo "--------------------------------------------------------"
  echo "Docker Image Filesystem Tree (ls -R)"
  echo "--------------------------------------------------------"
  cat "${OUTPUT_DIR}/filesystem_tree.txt"
  
) > "${OUTPUT_DIR}/compiled-report.txt"

echo "====================================================="
echo "All individual evidence files and the combined report have been saved to the '$OUTPUT_DIR' directory."
echo "Script finished."
echo "====================================================="