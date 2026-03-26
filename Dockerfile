# MIT License

# Copyright (c) 2020 Hongrui Zheng

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

FROM ros:humble

ENV DEBIAN_FRONTEND=noninteractive
ENV ROS_DOMAIN_ID=0
ENV RMW_IMPLEMENTATION="rmw_cyclonedds_cpp"

SHELL ["/bin/bash", "-c"]

# Use local ubuntu mirror
RUN sed -i 's|http://archive.ubuntu.com/ubuntu|http://ubuntu.task.gda.pl/ubuntu|g' /etc/apt/sources.list && \
    sed -i 's|http://security.ubuntu.com/ubuntu|http://ubuntu.task.gda.pl/ubuntu|g' /etc/apt/sources.list

RUN apt-get update --fix-missing && \
    apt-get install -y \
        git \
        nano \
        vim \
        python3-pip \
        libeigen3-dev \
        tmux \
        ros-foxy-rmw-cyclonedds-cpp \
        ros-foxy-rviz2 && \
    apt-get -y dist-upgrade && \
    rm -rf /var/lib/apt/lists/*

RUN pip3 install transforms3d

RUN git clone https://github.com/RoboRacer-SKAR-PG/f1tenth_gym && \
    pip3 install -e ./f1tenth_gym

RUN mkdir -p /sim_ws/src/f1tenth_gym_ros
COPY . /sim_ws/src/f1tenth_gym_ros

RUN source /opt/ros/foxy/setup.bash && \
    cd /sim_ws && \
    apt-get update --fix-missing && \
    rosdep install -i --from-path src --rosdistro foxy -y && \
    colcon build

WORKDIR /sim_ws

CMD ["/bin/bash", "-c", "source /opt/ros/foxy/setup.bash && source install/setup.bash && ros2 launch f1tenth_gym_ros gym_bridge_launch.py"]
