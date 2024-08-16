# libcamera and OpenCV Installation Script

This script automates the process of installing libcamera and OpenCV from source on Ubuntu/Debian systems. It handles dependency installation, downloading the source code, and compiling both libraries.

## Prerequisites

- Ubuntu or Debian-based Linux distribution
- Sudo privileges

## Usage

1. Save the script content to a file named `setup-libcam-opencv.sh`.
2. Make the script executable:
   ```
   chmod +x install_libcamera_opencv.sh
   ```
3. Run the script with sudo privileges:
   ```
   sudo ./install_libcamera_opencv.sh
   ```

## What the Script Does

1. Updates package lists
2. Installs necessary dependencies for both libcamera and OpenCV
3. Clones, builds, and installs libcamera from source
4. Clones, builds, and installs OpenCV from source

## Script Details

### Dependency Installation

The script installs the following groups of dependencies:

- Common build tools (build-essential, cmake, pkg-config, git)

`sudo apt-get install -y build-essential cmake pkg-config git`

- libcamera-specific dependencies

```
sudo apt-get install -y \
   meson ninja-build libdw-dev libudev-dev libboost-dev \
   libgnutls28-dev openssl libssl-dev libyaml-dev python3-yaml \ 
   python3-ply python3-jinja2 libglib2.0-dev libdrm-dev libevent-dev libunwind-dev

```

- OpenCV-specific dependencies

```
sudo apt-get install -y libgtk-3-dev libavcodec-dev libavformat-dev libswscale-dev \
    libv4l-dev libxvidcore-dev libx264-dev libjpeg-dev libpng-dev libtiff-dev \
    gfortran openexr libatlas-base-dev python3-dev python3-numpy libtbb2 \
    libtbb-dev libdc1394-22-dev
```


### libcamera Installation

- Source: https://git.libcamera.org/libcamera/libcamera.git
- Build system: Meson and Ninja

```
git clone https://git.linuxtv.org/libcamera.git
cd libcamera && \
meson build && \    
ninja -C build && \
ninja -C build install || error "Failed to build libcamera"
```

### OpenCV Installation

- Source: https://github.com/opencv/opencv.git
- Build system: CMake and Make
- The script uses a basic configuration. You may need to modify the CMake options for your specific needs.
```
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
make -j$(nproc) && \
make install && \
ldconfig

opencv_version && \
    pkg-config --modversion opencv4
```

## Customization

- The script uses all available cores for compiling OpenCV (`make -j$(nproc)`). Adjust this number based on your system's capabilities by modifying the `-j4` flag.
- The OpenCV build configuration is set up with some common options. You might want to adjust these based on your specific needs by modifying the CMake command.


## Troubleshooting

If you encounter any issues:

- For build errors, check that all dependencies are correctly installed, including meson and that your system meets the minimum requirements for libcamera and OpenCV.

## Contributing

Feel free to fork this script and submit pull requests for any improvements or bug fixes.

## License

This script is provided "as is", without warranty of any kind. You are free to use and modify it for your personal or commercial projects.


## Resources

- [Libcamera](https://libcamera.org/getting-started.html)
- [Opencv work](https://github.com/advait-0/opencv/tree/libcamera-final) 