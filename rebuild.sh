#!/bin/bash

# OpenCV rebuild script

# Exit on any error
set -e

# Configuration
OPENCV_SOURCE_DIR="opencv/"
OPENCV_CONTRIB_DIR="$HOME/libcam-opencv/opencv_contrib/"
INSTALL_DIR="/usr/local"
BUILD_DIR="build"

# Navigate to OpenCV source directory
cd "$OPENCV_SOURCE_DIR"

# Remove old build directory if it exists
if [ -d "$BUILD_DIR" ]; then
    echo "Removing old build directory..."
    rm -rf "$BUILD_DIR"
fi

# Create and enter new build directory
mkdir "$BUILD_DIR" && cd "$BUILD_DIR"

# Configure the build
echo "Configuring OpenCV build..."
cmake -D CMAKE_BUILD_TYPE=RELEASE \
      -D CMAKE_INSTALL_PREFIX="$INSTALL_DIR" \
      -D INSTALL_C_EXAMPLES=ON \
      -D INSTALL_PYTHON_EXAMPLES=ON \
      -D OPENCV_GENERATE_PKGCONFIG=ON \
      -D OPENCV_EXTRA_MODULES_PATH="$OPENCV_CONTRIB_DIR/modules" \
      -D BUILD_EXAMPLES=ON \
      -D WITH_LIBCAMERA=ON \
      -D WITH_TBB=ON \
      -D WITH_V4L=ON \
      -D WITH_QT=ON \
      -D WITH_OPENGL=ON \
      -D WITH_CUDA=OFF \
      ..

# Build OpenCV
echo "Building OpenCV..."
make -j$(nproc)

# Install OpenCV
echo "Installing OpenCV..."
sudo make install

# Update library cache
sudo ldconfig

# Verify installation
echo "Verifying installation..."
opencv_version
pkg-config --modversion opencv4

echo "OpenCV rebuild complete!"
