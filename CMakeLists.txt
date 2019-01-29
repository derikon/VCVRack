cmake_minimum_required(VERSION 3.10)
project(Rack)

set(V0.6_DIR ${PROJECT_SOURCE_DIR}/Rack_v0.6)
set(V1_DIR ${PROJECT_SOURCE_DIR}/Rack_v1)

add_custom_target(${PROJECT_NAME}_v1 COMMAND make -C ${V1_DIR}
    CLION_EXE_DIR=${V1_DIR})

add_custom_target(${PROJECT_NAME}_v0.6 COMMAND make -C ${V0.6_DIR}
    CLION_EXE_DIR=${V0.6_DIR})
