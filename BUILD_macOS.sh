#!/bin/bash

C_CLEAR="\033[0m"
C_RED="\033[31m"
C_GREEN="\033[32m"
C_YELLOW="\033[33m"
C_H1="\033[1;101;97m"
C_H2="\033[1;105;97m"
C_H3="\033[1;45;97m"

BASE_DIR=$(pwd)
CPUS=$(sysctl -n hw.ncpu)

LOG="${BASE_DIR}/build.log"
touch $LOG &> /dev/null


echo -e "${C_H1} VCV RACK INSTALLATION SCRIPT ${C_CLEAR}"





echo -e "${C_H2} CHECK GLOBAL DEPENDENCIES ${C_CLEAR}"

check_dependency () {
    local TOOL=$1
    echo -e "${C_H3} ${TOOL} ${C_CLEAR}"
    which ${TOOL} &> /dev/null
    if [[ $? != 0 ]]; then
        echo -e "${C_RED}not installed${C_CLEAR}"
        echo -e "${C_YELLOW}install ${TOOL} - this might take a while ...${C_CLEAR}"
        $(brew install ${TOOL}) &> /dev/null
    else
        echo -e "${C_GREEN}ok${C_CLEAR}"
    fi
}

echo -e "${C_H3} Brew Package Manager ${C_CLEAR}"
which brew &> /dev/null
if [[ $? != 0 ]]; then
    echo -e "${C_RED}not installed${C_CLEAR}"
    echo -e "${C_YELLOW}install brew - this might take a while ...${C_CLEAR}"
    $(/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)") &> /dev/null
else
    echo -e "${C_GREEN}ok${C_CLEAR}"
fi

check_dependency git
check_dependency wget
check_dependency cmake
check_dependency autoconf
check_dependency automake
check_dependency libtool






echo -e "${C_H2} SELECT VCV RACK VERSION ${C_CLEAR}"
echo -e "supported versions: ${C_GREEN}v0.6${C_CLEAR} and ${C_GREEN}v1${C_CLEAR}"
read -p 'install version: ' VERSION
if [[ "$VERSION" != "v0.6" ]] && [[ "$VERSION" != "v1" ]]; then
    echo -e "${C_RED}\"${VERSION}\" is not supported.${C_CLEAR}"
    echo -e "choose ${C_GREEN}v0.6${C_CLEAR} or ${C_GREEN}v1${C_CLEAR}"
    exit -1
fi

echo "install plugins"
read -p "y (yes) or n (no): " INSTALL_PLUGINS
if [[ "$INSTALL_PLUGINS" != "y" ]] && [[ "$INSTALL_PLUGINS" != "n" ]]; then
    echo -e "${C_RED}Won't install any plugins.${C_CLEAR}"
    INSTALL_PLUGINS=n
fi

echo "install Bridge"
read -p "y (yes) or n (no): " INSTALL_BRIDGE
if [[ "$INSTALL_BRIDGE" != "y" ]] && [[ "$INSTALL_BRIDGE" != "n" ]]; then
    echo -e "${C_RED}Won't install Bridge.${C_CLEAR}"
    INSTALL_PLUGINS=n
fi






echo -e "${C_H1} INSTALL VCV RACK ${VERSION} ${C_CLEAR}"
if [ ! -d "Rack_${VERSION}" ]; then
    echo -e "${C_GREEN}clone Rack ${VERSION}${C_CLEAR}"
    echo -e "${C_YELLOW}this might take a while ...${C_CLEAR}"
    git clone https://github.com/VCVRack/Rack.git "Rack_${VERSION}" &> $LOG
    if [[ $? != 0 ]]; then
        echo -e "${C_RED}failed (see ${LOG})${C_CLEAR}"
        exit -1
    else
        echo -e "${C_GREEN}finished${C_CLEAR}"
    fi
    echo -e "${C_GREEN}update submodules${C_CLEAR}"
    echo -e "${C_YELLOW}this might take a while ...${C_CLEAR}"
    cd ./Rack_$VERSION
    git submodule update --init --recursive &> $LOG
    if [[ $? != 0 ]]; then
        echo -e "${C_RED}failed (see ${LOG})${C_CLEAR}"
        exit -1
    else
        echo -e "${C_GREEN}finished${C_CLEAR}"
    fi
    cd ../
else
    echo -e "${C_GREEN}already cloned Rack${C_CLEAR}"
fi

cd ./Rack_$VERSION
BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ "$BRANCH" != "$VERSION" ]]; then
    git checkout $VERSION &> /dev/null
    git pull  &> /dev/null
    echo -e "${C_GREEN}update submodules${C_CLEAR}"
    echo -e "${C_YELLOW}this might take a while ...${C_CLEAR}"
    git submodule update --init --recursive &> $LOG
    if [[ $? != 0 ]]; then
        echo -e "${C_RED}failed (see ${LOG})${C_CLEAR}"
        exit -1
    else
        echo -e "${C_GREEN}finished${C_CLEAR}"
    fi
else
    echo -e "${C_GREEN}Rack is already on branch ${VERSION}${C_CLEAR}"
fi

git fetch &> /dev/null
if [[ $(git rev-parse HEAD) != $(git rev-parse @{u}) ]]; then
    git pull &> /dev/null
    git submodule update --init --recursive &> $LOG
    if [[ $? != 0 ]]; then
        echo -e "${C_RED}failed (see ${LOG})${C_CLEAR}"
        exit -1
    else
        echo -e "${C_GREEN}finished${C_CLEAR}"
    fi
else
    echo -e "${C_GREEN}branch ${VERSION} is up to date${C_CLEAR}"
fi

if [ -d "build" ]; then
    echo -e "${C_RED}clean old build${C_CLEAR}"
    make clean &> /dev/null
    make cleanplugins &> /dev/null
fi

echo -e "${C_H2} build Rack ${VERSION} dependencies ${C_CLEAR}"
echo -e "${C_YELLOW}this might take a while ...${C_CLEAR}"
make dep -j${CPUS} &> $LOG
if [[ $? != 0 ]]; then
    echo -e "${C_RED}failed (see ${LOG})${C_CLEAR}"
    exit -1
else
    echo -e "${C_GREEN}finished${C_CLEAR}"
fi

echo -e "${C_H2} build Rack ${VERSION} ${C_CLEAR}"
echo -e "${C_YELLOW}this might take a while ...${C_CLEAR}"
make -j${CPUS} &> $LOG
if [[ $? != 0 ]]; then
    echo -e "${C_RED}failed (see ${LOG})${C_CLEAR}"
    exit -1
else
    echo -e "${C_GREEN}finished${C_CLEAR}"
fi

if [ -d "docs" ]; then
    echo -e "${C_H2} build Rack ${VERSION} documentation ${C_CLEAR}"
    echo -e "${C_YELLOW}this might take a while ...${C_CLEAR}"
    cd ./docs
    make clean &> /dev/null
    make doxygen &> $LOG
    if [[ $? != 0 ]]; then
        echo -e "${C_RED}failed (see ${LOG})${C_CLEAR}"
        exit -1
    else
        echo -e "${C_GREEN}finished${C_CLEAR}"
    fi
    cd ../
fi



if [[ "$INSTALL_BRIDGE" == "y" ]]; then
    echo -e "${C_H1} INSTALL BRIDGE FOR VCV RACK ${VERSION} ${C_CLEAR}"
    if [ ! -d "Bridge" ]; then
        echo -e "${C_GREEN}clone Bridge${C_CLEAR}"
        echo -e "${C_YELLOW}this might take a while ...${C_CLEAR}"
        git clone https://github.com/VCVRack/Bridge.git &> $LOG
        if [[ $? != 0 ]]; then
            echo -e "${C_RED}failed (see ${LOG})${C_CLEAR}"
            exit -1
        else
            echo -e "${C_GREEN}finished${C_CLEAR}"
        fi
    else
        echo -e "${C_GREEN}already cloned Bridge${C_CLEAR}"
    fi
    cd ./Bridge
    git fetch &> /dev/null
    if [[ $(git rev-parse HEAD) != $(git rev-parse @{u}) ]]; then
        git pull &> /dev/null
    else
        echo -e "${C_GREEN}repository is up to date${C_CLEAR}"
    fi
    echo -e "${C_H2} build Bridge AudioUnit component ${C_CLEAR}"
    echo -e "${C_YELLOW}this might take a while ...${C_CLEAR}"
    cd ./AU
    if [ -d "build" ]; then
        echo -e "${C_RED}clean old build${C_CLEAR}"
        make clean &> /dev/null
    fi
    if [ ! -d "AudioUnitExamplesAudioUnitEffectGeneratorInstrumentMIDIProcessorandOffline" ]; then
        echo -e "${C_GREEN}clone Bridge dependencies${C_CLEAR}"
        echo -e "${C_YELLOW}this might take a while ...${C_CLEAR}"
        git clone https://github.com/derikon/AudioUnitExample.git &> $LOG
        if [[ $? != 0 ]]; then
            echo -e "${C_RED}failed (see ${LOG})${C_CLEAR}"
            exit -1
        else
            echo -e "${C_GREEN}finished${C_CLEAR}"
        fi
        mv ./AudioUnitExample/AudioUnitExamplesAudioUnitEffectGeneratorInstrumentMIDIProcessorandOffline ./ &> $LOG
        rm -rf ./AudioUnitExample &> $LOG
    fi
    make dist -j${CPUS} &> $LOG
    if [[ $? != 0 ]]; then
        echo -e "${C_RED}failed (see ${LOG})${C_CLEAR}"
        exit -1
    else
        echo -e "${C_GREEN}finished${C_CLEAR}"
    fi
    cd ../VST
    #[TODO] build VST plugin
    #echo -e "${C_H2} build Bridge VST plugin ${C_CLEAR}"
    #echo -e "${C_YELLOW}this might take a while ...${C_CLEAR}"
    cd ../../
fi




if [[ "$INSTALL_PLUGINS" != "y" ]]; then
    exit 0
fi
echo -e "${C_H1} INSTALL VCV RACK ${VERSION} PLUGINS ${C_CLEAR}"


install_plugin () {
    local PLUGIN=$1
    cd ./plugins
        echo -e "${C_H2} ${PLUGIN} ${C_CLEAR}"
    if [ ! -d "${PLUGIN}" ]; then
        echo -e "${C_GREEN}clone ${PLUGIN} ${VERSION}${C_CLEAR}"
        echo -e "${C_YELLOW}this might take a while ...${C_CLEAR}"
        git clone "https://github.com/VCVRack/${PLUGIN}.git" &> $LOG
        if [[ $? != 0 ]]; then
            echo -e "${C_RED}failed (see ${LOG})${C_CLEAR}"
            exit -1
        else
            echo -e "${C_GREEN}finished${C_CLEAR}"
        fi
        echo -e "${C_GREEN}update submodules${C_CLEAR}"
        echo -e "${C_YELLOW}this might take a while ...${C_CLEAR}"
        cd ./$PLUGIN
        git submodule update --init --recursive &> $LOG
        if [[ $? != 0 ]]; then
            echo -e "${C_RED}failed (see ${LOG})${C_CLEAR}"
            exit -1
        else
            echo -e "${C_GREEN}finished${C_CLEAR}"
        fi
        cd ../
    else
        echo -e "${C_GREEN}already cloned ${PLUGIN}${C_CLEAR}"
    fi

    cd ./$PLUGIN
    BRANCH=$(git rev-parse --abbrev-ref HEAD)
    if [[ "$BRANCH" != "$VERSION" ]]; then
        git checkout $VERSION &> /dev/null
        git pull &> /dev/null
        echo -e "${C_GREEN}update submodules${C_CLEAR}"
        echo -e "${C_YELLOW}this might take a while ...${C_CLEAR}"
        git submodule update --init --recursive &> $LOG
        if [[ $? != 0 ]]; then
            echo -e "${C_RED}failed (see ${LOG})${C_CLEAR}"
            exit -1
        else
            echo -e "${C_GREEN}finished${C_CLEAR}"
        fi
    else
        echo -e "${C_GREEN}${PLUGIN} is already on branch ${VERSION}${C_CLEAR}"
    fi

    git fetch &> /dev/null
    if [[ $(git rev-parse HEAD) != $(git rev-parse @{u}) ]]; then
        git pull &> /dev/null
        echo -e "${C_GREEN}update submodules${C_CLEAR}"
        echo -e "${C_YELLOW}this might take a while ...${C_CLEAR}"
        git submodule update --init --recursive &> $LOG
        if [[ $? != 0 ]]; then
            echo -e "${C_RED}failed (see ${LOG})${C_CLEAR}"
            exit -1
        else
            echo -e "${C_GREEN}finished${C_CLEAR}"
        fi
    else
        echo -e "${C_GREEN}branch ${VERSION} is up to date${C_CLEAR}"
    fi

    if [ -d "build" ]; then
        echo -e "${C_RED}clean old build${C_CLEAR}"
        make clean &> /dev/null
    fi

    echo -e "${C_H3} build ${PLUGIN} ${VERSION} dependencies ${C_CLEAR}"
    echo -e "${C_YELLOW}this might take a while ...${C_CLEAR}"
    make dep -j${CPUS} &> $LOG
    if [[ $? != 0 ]]; then
        echo -e "${C_RED}failed (see ${LOG})${C_CLEAR}"
        exit -1
    else
        echo -e "${C_GREEN}finished${C_CLEAR}"
    fi

    echo -e "${C_H3} build ${PLUGIN} ${VERSION} ${C_CLEAR}"
    echo -e "${C_YELLOW}this might take a while ...${C_CLEAR}"
    make -j${CPUS} &> $LOG
    if [[ $? != 0 ]]; then
        echo -e "${C_RED}failed (see ${LOG})${C_CLEAR}"
        exit -1
    else
        echo -e "${C_GREEN}finished${C_CLEAR}"
    fi
    make dist &> $LOG
    cd ../../
}


install_plugin Fundamental
install_plugin Befaco
install_plugin Template

if [[ "$VERSION" == "v0.6" ]]; then
    install_plugin AudibleInstruments
    install_plugin ESeries
fi
