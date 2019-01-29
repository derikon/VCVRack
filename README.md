# VCV Rack

[VCV Rack](https://vcvrack.com/) is an open-source and cross-platform virtual modular synthesizer.

This repository is use to build VCV Rack in several versions for research and development purposes in parallel using CMake.
If you just want to build and run VCV Rack clone the official repository from [https://github.com/VCVRack/Rack.git]() and follow the build instructions from the [manual](https://vcvrack.com/manual/Building.html).


## Build

1. clone this repository: `git clone https://github.com/derikon/VCVRack.git`
2. `cd VCVRack`
3. `./BUILD_macOS.sh`


### Configure Clion for development

1. Open CMakeLists.txt in [Clion](https://www.jetbrains.com/clion/)
2. Go to Run -> Edit Configurations in menu bar. You should see a build configuration for each VCV Rack version.
3. Select build configuration (e.g. Rack_v1)
    1. Executable: select the **Rack** executable from the version specific subdirectory
    2. Program arguments: add `-d` for debug mode
4. select a target and run it
