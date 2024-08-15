# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    wget \
    unzip \
    gcc \
    g++ \
    pkg-config \
    libssl-dev \
    libyaml-dev \
    python3-yaml \
    python3-ply \
    python3-jinja2 \
    libpython3-dev \
    pybind11-dev \  
    libyaml-dev \
    libdw-dev \
    libunwind-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libv4l-dev \
    libxvidcore-dev \
    libx264-dev \
    libgtk2.0-dev \
    libatlas-base-dev \
    gfortran \
    libhdf5-dev \
    libhdf5-serial-dev \
    libhdf5-103 \
    python3 \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    ninja-build \
    libcanberra-gtk-module \
    libcanberra-gtk3-module \
    && apt-get clean


#RUN pip install meson
RUN pip install --no-cache-dir meson pybind11 jinja2 pyyaml ply

# Install libcamera from source
RUN git clone https://git.libcamera.org/libcamera/libcamera.git && \
    cd libcamera && \
    meson build && \
    ninja -C build && \
    ninja -C build install


# Install OpenCV from source
RUN git clone https://github.com/opencv/opencv.git && \
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

RUN opencv_version && \
    pkg-config --modversion opencv4

# Copy the current directory contents into the container at /app
COPY libcamera_opencv_example.cpp /app/libcamera_opencv_example.cpp

# Run the application
RUN g++ -std=c++17 libcamera_opencv_example.cpp -o libcamera_opencv_example $(pkg-config --cflags --libs opencv4 libcamera)

