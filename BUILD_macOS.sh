#!/bin/bash

BASE_DIR=$(pwd)

echo "base directory is" $BASE_DIR

echo "update submodules ..."
git submodule update --init --recursive

cd ./Rack_v0.6
echo "build Rack v0.6 dependencies"
make dep -j8
echo "build Rack v0.6"
make -j8

echo "build Rack v0.6 plugins"
cd ./plugins

echo "clone AudibleInstruments v0.6"
git clone https://github.com/VCVRack/AudibleInstruments.git
cd ./AudibleInstruments
git checkout v0.6
git submodule update --init --recursive
echo "build AudibleInstruments v0.6"
make -j8
make dist

cd ../

echo "clone Fundamental v0.6"
git clone https://github.com/VCVRack/Fundamental.git
cd ./Fundamental
git checkout v0.6
echo "build Fundamental v0.6"
make dep -j8
make -j8
make dist

cd ../

echo "clone Befaco v0.6"
git clone https://github.com/VCVRack/Befaco.git
cd ./Befaco
git checkout v0.6
echo "build Befaco v0.6"
make -j8
make dist

cd ../

echo "clone ESeries v0.6"
git clone https://github.com/VCVRack/ESeries.git
cd ./ESeries
git checkout v0.6
echo "build ESeries v0.6"
make -j8
make dist

cd ../

echo "clone Template v0.6"
git clone https://github.com/VCVRack/Template.git
cd ./Template
git checkout v0.6
echo "build Template v0.6"
make -j8






cd $BASE_DIR

cd ./Rack_v1
echo "build Rack v1 dependencies"
make dep -j8
echo "build Rack v1"
make -j8

