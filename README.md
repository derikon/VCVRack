# VCV Rack

[VCV Rack](https://vcvrack.com/) is an open-source and cross-platform virtual modular synthesizer.

This repository is use to build VCV Rack in several versions for research and development purposes.


## Build

1. clone this repository: `git clone https://github.com/derikon/VCVRack.git`
2. `cd VCVRack`
3. `./BUILD_macOS.sh`

The build script checks for build dependencies: `brew`, `git`, `wget`, `cmake`, `autoconf`, `automake`, `libtool`

You can decide which Rack version to build and if the standard plugins should be build as well.

+ [Fundamental](https://github.com/VCVRack/Fundamental): v0.6 and v1
+ [Befaco](https://github.com/VCVRack/Befaco): v0.6 and v1
+ [Template](https://github.com/VCVRack/Template): v0.6 and v1 (only used for development purpose)
+ [ESeries](https://github.com/VCVRack/ESeries): v0.6
+ [AudibleInstruments](https://github.com/VCVRack/AudibleInstruments): v0.6


## Development

Rack by default uses `make` to build executables. I also want to use `cmake` and added a `CMakeLists.txt`.

### Configure Clion

1. Open CMakeLists.txt in [Clion](https://www.jetbrains.com/clion/)
2. Go to Run -> Edit Configurations in menu bar. You should see a build configuration for each VCV Rack version.
3. Select build configuration (e.g. Rack_v1)
    1. Executable: select the **Rack** executable from the version specific subdirectory
    2. Program arguments: add `-d` for debug mode
4. select a target and run it
