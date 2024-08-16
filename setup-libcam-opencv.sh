#!/bin/bash

# Function to print error messages
error() {
    echo "Error: $1" >&2
    exit 1
}

# Function to install packages
install_packages() {
    sudo apt-get install -y "$@" || error "Failed to install packages: $@"
}

# Update package lists
sudo apt-get update || error "Failed to update package lists"

# Install common build tools and libraries
install_packages build-essential cmake pkg-config git

# Install libcamera dependencies
install_packages meson ninja-build libdw-dev libudev-dev libboost-dev \
    libgnutls28-dev openssl libssl-dev libyaml-dev python3-yaml \
    python3-ply python3-jinja2 libglib2.0-dev libdrm-dev libevent-dev \
    libunwind-dev

# Install OpenCV dependencies
install_packages libgtk-3-dev libavcodec-dev libavformat-dev libswscale-dev \
    libv4l-dev libxvidcore-dev libx264-dev libjpeg-dev libpng-dev libtiff-dev \
    gfortran openexr libatlas-base-dev python3-dev python3-numpy libtbb2 \
    libtbb-dev libdc1394-22-dev

echo "All dependencies have been successfully installed."


pip install --no-cache-dir meson 
pip install pybind11 jinja2 pyyaml ply

# Clone libcamera repository
git clone https://git.linuxtv.org/libcamera.git || error "Failed to clone libcamera repository"

# Navigate to libcamera source directory and build libcamera
cd libcamera && \
meson build && \    
ninja -C build && \
ninja -C build install || error "Failed to build libcamera"


# Clone OpenCV repository
cd ..
git clone https://github.com/opencv/opencv.git && \
git clone https://github.com/opencv/opencv_contrib.git && \
cd opencv && \
mkdir build && \
cd build && \
cmake \
-D CMAKE_BUILD_TYPE=Release \
-D OPENCV_GENERATE_PKGCONFIG=YES \
-D CMAKE_INSTALL_PREFIX=/usr/local \
-D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules .. && \
#     -D WITH_FFMPEG=YES \
#     -D WITH_LIBCAMERA=ON \
#     -D WITH_GSTREAMER=ON \
make -j$(nproc) && \
make install && \
ldconfig

opencv_version && \
    pkg-config --modversion opencv4