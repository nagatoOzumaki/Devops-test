#!/bin/bash

# Name of the ZIP file
ZIP_FILE="lambda_function_api.zip"

# Directory to store temporary files
TMP_DIR="lambda_tmp"

# Create temporary directory
mkdir -p "$TMP_DIR"

# Copy application code and dependencies to temporary directory
cp lambda.py "$TMP_DIR/"
cp requirements.txt "$TMP_DIR/"
pip install -r requirements.txt -t "$TMP_DIR/"

# Exclude unwanted files and create the ZIP archive
zip -r "$ZIP_FILE" "$TMP_DIR" -x "*.pyc" "__pycache__" "*.git*" "*.idea*" "*.DS_Store*" "*.zip" "venv/*"

# Display the contents of the ZIP file
unzip -l "$ZIP_FILE"

# Clean up temporary files
rm -rf "$TMP_DIR"

echo "Packaging complete. ZIP file: $ZIP_FILE"
