FROM nvidia/cuda:12.0.1-base-ubuntu20.04

ENV DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-c"]

COPY sources.list /etc/apt/sources.list

RUN apt-get update && \
    apt-get install -y \
    build-essential \
    gcc g++ gdb \
    cmake \
    python3 \
    python3-pip \
    libgoogle-glog-dev \
    libeigen3-dev \
    libyaml-cpp-dev \
    git \
    && apt-get clean

RUN pip3 install evo -i https://pypi.tuna.tsinghua.edu.cn/simple
RUN pip3 install jupyter -i https://pypi.tuna.tsinghua.edu.cn/simple

RUN apt-get update && \
    apt-get install -y curl && \
    apt-get install -y lsb-release && \
    sh -c '. /etc/lsb-release && echo "deb http://mirrors.tuna.tsinghua.edu.cn/ros/ubuntu/ `lsb_release -cs` main" > /etc/apt/sources.list.d/ros-latest.list' &&\
    curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add - && \
    apt-get update

RUN sed -i 's/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list

RUN apt-get update && \
    apt-get install -y \
    ros-noetic-ros-base \
    ros-noetic-rviz \
    ros-noetic-pcl-msgs

RUN apt-get update && \
    apt-get install -y libboost-dev && \
    apt-get install -y libeigen3-dev && \
    apt-get install -y libflann-dev && \
    apt-get install -y libvtk7-dev

ARG PCL_VERSION=1.12.0
RUN cd ~ && mkdir software && cd software && \
    git clone https://mirror.ghproxy.com/https://github.com/PointCloudLibrary/pcl.git && \
    cd pcl && git checkout pcl-$PCL_VERSION && \
    mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local/pcl-$PCL_VERSION .. && \
    make -j4 &&  make -j4 install && \
    cd ~ && rm -rf software

ARG PCL_CONVERSIONS_TAG=1.7.4
RUN source /opt/ros/noetic/setup.bash && \
    cd ~ && mkdir software && cd software && \
    git clone https://mirror.ghproxy.com/https://github.com/ros-perception/perception_pcl.git && \
    cd perception_pcl && git checkout $PCL_CONVERSIONS_TAG && cd pcl_conversions && \
    mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt/ros/noetic .. &&\
    make install -j4 &&\
    cd ~ && rm -rf software

RUN apt-get update && \
    apt-get install -y libavcodec-dev libavformat-dev libswscale-dev && \
    apt-get install -y libgstreamer-plugins-base1.0-dev libgstreamer1.0-dev && \
    apt-get install -y libgtk2.0-dev libgtk-3-dev && \
    apt-get install -y libpng-dev libjpeg-dev libopenexr-dev libtiff-dev libwebp-dev

ARG OPENCV_VERSION=4.6.0
RUN cd ~ && mkdir software && cd software && \
    git clone https://mirror.ghproxy.com/github.com/opencv/opencv_contrib.git && \
    cd opencv_contrib && git checkout $OPENCV_VERSION && cd .. && \
    git clone https://mirror.ghproxy.com/https://github.com/opencv/opencv.git && \
    cd opencv && git checkout $OPENCV_VERSION && \
    mv ../opencv_contrib/modules/ximgproc ./modules && \
    mv ../opencv_contrib/modules/line_descriptor ./modules && \
    find . -type f -exec sed -i 's|https://raw.githubusercontent.com|https://mirror.ghproxy.com/https://raw.githubusercontent.com|g' {} + && \
    mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local/opencv-$OPENCV_VERSION .. &&\
    make install -j4 &&\
    cd ~ && rm -rf software

RUN cd ~ && mkdir software && cd software && \
    git clone https://mirror.ghproxy.com/https://github.com/gflags/gflags.git && \
    cd gflags && mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS=-fPIC .. &&\
    make install -j4 &&\
    cd ~ && rm -rf software

RUN cd ~ && mkdir software && cd software && \
    git clone https://mirror.ghproxy.com/https://github.com/google/glog.git && \
    cd glog && git checkout b33e3ba && mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. &&\
    make install -j4 &&\
    cd ~ && rm -rf software

# RUN apt-get update && \
#     apt-get install -y libgflags-dev && \
#     apt-get install -y libgoogle-glog-dev

RUN groupadd -g 1000 shitong && \
    useradd -u 1000 -g shitong -m -s /bin/bash shitong
USER shitong
RUN echo "source /opt/ros/noetic/setup.bash" >> /home/shitong/.bashrc
