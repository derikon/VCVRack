cmake_minimum_required(VERSION 3.10)
project(Rack)

option(BUILD_V0.6 "build VCV Rack version v0.6" ON)
option(BUILD_V1 "build VCV Rack version v1" ON)

if(BUILD_V0.6)
    message("Build ${PROJECT_NAME} v0.6")
    set(V0.6_DIR ${PROJECT_SOURCE_DIR}/Rack_v0.6)
    add_custom_target(${PROJECT_NAME}_v0.6 COMMAND make -C ${V0.6_DIR}
    CLION_EXE_DIR=${V0.6_DIR})
endif(BUILD_V0.6)

if(BUILD_V1)
    message("Build ${PROJECT_NAME} v1")
    set(V1_DIR ${PROJECT_SOURCE_DIR}/Rack_v1)
    add_custom_target(${PROJECT_NAME}_v1 COMMAND make -C ${V1_DIR}
    CLION_EXE_DIR=${V1_DIR})
endif(BUILD_V1)
