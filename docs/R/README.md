```
sudo apt update && sudo apt install -y \
  libfontconfig1-dev \
  libfreetype6-dev \
  libuv1-dev \
  libharfbuzz-dev \
  libfribidi-dev \
  libssl-dev \
  libxml2-dev \
  libcurl4-openssl-dev
sudo apt install -y \
    pkg-config \
    libtiff-dev \
    libwebp-dev \
    libfreetype-dev \
    libpng-dev \
    libjpeg-dev
  sudo apt update
  sudo apt install -y \
    build-essential \
    pkg-config \
    libudunits2-dev \
    libgdal-dev \
    libgeos-dev \
    libproj-dev
# 检查
pkg-config --cflags freetype2 libpng libtiff-4 libjpeg libwebp libwebpmux
```