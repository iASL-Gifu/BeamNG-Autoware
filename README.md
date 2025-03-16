# BeamNG - Autoware

This project aims to integrate **[BeamNG.tech](https://beamng.tech/)**'s realistic vehicle simulation environment with the **[Autoware](https://autowarefoundation.github.io/autoware-documentation/main/)** autonomous driving system, enabling vehicles to drive autonomously in a virtual environment.

## System Configuration

This system operates by linking two PCs: **Windows** and **Linux**.  
The roles of each PC are as follows:  

### 🖥️ Windows Side
On the Windows side, **BeamNG.tech** is launched as the simulation environment to acquire vehicle status and surrounding environment data.  
The acquired data is transmitted to the Linux side via **Zenoh** using **zenoh_beamng_bridge**.  

1. **[BeamNG.tech](https://beamng.tech/)**:  
   - Simulates vehicle behavior and surrounding conditions in a virtual environment.  
2. **[zenoh_beamng_bridge](https://github.com/peregrine-884/zenoh_beamng_bridge)**:  
   - Sends data acquired from BeamNG to the Linux side via Zenoh.  
   - Also receives control commands from the Linux side to operate the vehicle in BeamNG.  

### 🐧 Linux Side
On the Linux side, the data received from Windows is converted into **ROS 2** topics by **zenoh-plugin-ros2dds**, and autonomous driving control is performed by **Autoware**.  

1. **[zenoh-plugin-ros2dds](https://github.com/eclipse-zenoh/zenoh-plugin-ros2dds)**:  
   - Publishes data received from Zenoh as ROS 2 topics.  
   - Sends control commands from Autoware to the Windows side via Zenoh.  
2. **[Autoware](https://github.com/peregrine-884/custom_autoware/tree/beamng)**:  
   - Performs path planning and control based on the received data, enabling autonomous driving of the vehicle.  

In this configuration, the simulation runs on Windows while autonomous driving computations and control are handled on Linux.  

## Setup Instructions

### 1. Windows Setup
Follow the instructions in the README of the [zenoh_beamng_bridge](https://github.com/peregrine-884/zenoh_beamng_bridge) repository. This will prepare the environment for connecting Zenoh and BeamNG.

After that, modify the [default.json5](https://github.com/peregrine-884/zenoh_beamng_bridge/blob/main/config/zenoh/default.json5) file.  
Change the `endpoints` to the IP address of the Linux PC you're connecting to.

### 2. Linux Setup

#### 2.1 zenoh-plugin-ros2dds

##### Install Rust  
Use the official installer: [Rust Installation](https://www.rust-lang.org/tools/install)

##### Install LLVM and Clang development packages  
```bash
sudo apt install llvm-dev libclang-dev
```

##### Clone and build `zenoh-plugin-ros2dds`  
To ensure compatibility with the version of Zenoh on the Windows side, clone the specified branch and build it:
```bash
git clone -b release/1.0.0-alpha.6 https://github.com/eclipse-zenoh/zenoh-plugin-ros2dds.git
cd zenoh-plugin-ros2dds
cargo build --release
```

##### Place configuration and startup files  
After building `zenoh-plugin-ros2dds`:
- Put the `run_zenoh_bridge.sh` in the root directory.
- Put the `config.json5` in the `zenoh-plugin-ros2dds/config/` directory and update the `endpoints` with your Windows PC's IP:  
```
connect: {
 endpoints: [
   // "<proto>/<windows_ip>:<port>"
 ]
}
```

#### 2.2 Autoware Setup

##### Build Autoware
Follow the [official documentation](https://autowarefoundation.github.io/autoware-documentation/main/installation/autoware/source-installation/) to build Autoware.

However, when cloning the repository, use the one configured to run vehicles in BeamNG. Use the following command to clone the repository:
```bash
git clone -b beamng https://github.com/peregrine-884/custom_autoware.git

```

After running `vcs import src < autoware.repos`, download the [file](https://drive.google.com/file/d/1Nxo5UGMgvXiMzyajMbKD2x4BSRcBsN8H/view?usp=drive_link), extract it, and place the contents in the `custom_autoware/src` directory.

##### DDS Configuration
For DDS configuration, refer to the settings in [this guide](https://autowarefoundation.github.io/autoware-documentation/main/installation/additional-settings-for-developers/network-configuration/dds-settings/)

## Startup Instructions

### On Windows

#### 1. **Start BeamNG.tech**  
```bash
cd <path-to-beamng.tech-directory>
Bin64\BeamNG.tech.x64.exe -console -nosteam -tcom-listen-ip "127.0.0.1" -lua "extensions.load('tech/techCore');tech_techCore.openServer(64256)"
```

#### 2. **Start beamng_zenoh_bridge**  
Start the desired task based on the files available in the `zenoh_beamng_bridge/scripts` folder as follows:
```bash
cd zenoh_beamng_bridge\scripts
./<task_name>
```
Replace `<task_name>` with the name of the task you want to run. Examples of available tasks include:
- `autoware_drive.bat` — Vehicle control with Autoware
- `create_pointcloud_map.bat` — Generate a PointCloud map
- `create_accel_brake_map.bat` — Create an Accel-Brake map

### 2. On Linux

#### 1. **Start zenoh-plugin-ros2dds**
```bash
cd zenoh-plugin-ros2dds
./run_zenoh_bridge.sh
```

#### 2. **Start the ROS 2 packages based on the task**  
Depending on the task, launch the corresponding ROS 2 nodes.

##### 1. **Creating the PointCloud Map**  
To create the PointCloud map, use the [**lidarslam_ros2**](https://github.com/rsasaki0109/lidarslam_ros2) package.  
Follow the instructions in the repository to set up and create the PointCloud map.

##### 2. **Creating the Accel-Brake Map**  
To create the Accel-Brake map, use the [**autoware_accel_brake_map_calibrator**](https://github.com/autowarefoundation/autoware.universe/tree/main/vehicle/autoware_accel_brake_map_calibrator) package provided by Autoware.  
Refer to the documentation in the repository to calibrate and generate the Accel-Brake map.

##### 3. **Autonomous Driving with Autoware**  
For autonomous driving tasks, use the custom Autoware package you built earlier: [**custom_autoware**](https://github.com/peregrine-884/custom_autoware).  
Start Autoware using the following commands:
```bash
cd custom_autoware
source install/setup.bash
ros2 launch autoware_launch autoware.launch.xml vehicle_model:=beamng_vehicle sensor_model:=beamng_sensor_kit map_path:=<path-to-pcd-and-osm>
```



