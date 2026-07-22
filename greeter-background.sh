#!/bin/bash

# Directory containing the images
IMAGE_DIR="/home/juanjo/wallpapers"

# Get a random image from the directory
IMAGE=$(ls "$IMAGE_DIR" | shuf -n 1)

# Output the full path to the image
echo "$IMAGE_DIR/$IMAGE"

