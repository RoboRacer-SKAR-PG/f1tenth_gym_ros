FROM ros:foxy

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

CMD ["bash", "-c", "source /opt/ros/foxy/setup.bash && source install/setup.bash && ros2 launch f1tenth_gym_ros gym_bridge_launch.py"]
