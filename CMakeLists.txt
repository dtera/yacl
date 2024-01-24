cmake_minimum_required(VERSION 3.14)

project(yacl VERSION 1.0 LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 17)

option(GE_M1_CHIP "WHETHER M1 CHIP" ON)
add_definitions(-DMSGPACK_NO_BOOST)
add_definitions(-DFMT_HEADER_ONLY)
# brew install grpc
set(GRPC_ROOT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/third_party/)  # /opt/homebrew/opt/grpc /usr/local/grpc
if (APPLE)
    execute_process(COMMAND brew --prefix libomp OUTPUT_VARIABLE BREW_libomp_PREFIX OUTPUT_STRIP_TRAILING_WHITESPACE)
    include_directories(${BREW_libomp_PREFIX}/include)
    link_libraries(${BREW_libomp_PREFIX}/lib/libomp.dylib)
else ()
    set(CMAKE_INSTALL_RPATH "${GRPC_ROOT_DIR}/lib")
    link_directories(third_party/lib64)
endif ()
#set(CMAKE_LOCAL "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
#list(APPEND CMAKE_MODULE_PATH ${CMAKE_LOCAL}/modules)
include(cmake/FindGRPC.cmake)
include(cmake/FindProtobuf.cmake)

#foreach (pkg Protobuf)
#    string(REGEX REPLACE "(:(.*)?)|(Opt@)" "" pkg_name ${pkg})
#    string(REGEX MATCH ":(.*)?$" f1 ${pkg})
#    string(FIND ${pkg} "Opt@" f2)
#    set(c "")
#    set(r "")
#    if (NOT ${f1} STREQUAL "")
#        string(REGEX REPLACE "(.*)?:" "" c ${pkg})
#        string(REGEX REPLACE "," ";" c ${c})
#    endif ()
#    if (${f2} STREQUAL -1)
#        set(r "REQUIRED")
#    endif ()
#    find_package(${pkg_name} ${c} ${r})
#endforeach ()

# source files
file(GLOB_RECURSE SOURCES yacl/*.cc)
file(GLOB_RECURSE TEST_SRCS yacl/*test*.cc)
file(GLOB_RECURSE BENCH_SRCS yacl/*bench*.cc)
file(GLOB_RECURSE RM_SRCS yacl/base/dynamic_bitset_test.cc yacl/crypto/base/test/alg_data_test.cc
        yacl/io/kv/leveldb_kvstore.cc yacl/io/kv/kvstore_test.cc yacl/crypto/base/drbg/intel_entropy_source.cc
        yacl/crypto/base/ecc/mcl/*.cc yacl/crypto/base/field/mcl/*.cc yacl/crypto/base/pairing/mcl/*.cc
        yacl/crypto/primitives/ot/*.cc yacl/crypto/primitives/vole/*.cc yacl/crypto/primitives/dpf/*.cc
        yacl/crypto/primitives/code/*.cc yacl/link/*.cc yacl/math/galois_field/mcl_field/*.cc
        yacl/utils/serialize.* yacl/utils/platform_utils*)
list(REMOVE_ITEM SOURCES ${TEST_SRCS} ${BENCH_SRCS} ${RM_SRCS})
list(REMOVE_ITEM TEST_SRCS ${RM_SRCS})
list(REMOVE_ITEM BENCH_SRCS ${RM_SRCS})

# config auto generated for protobuf
file(GLOB_RECURSE PROTOS yacl/*.proto)
file(GLOB_RECURSE RM_PROTOS yacl/crypto/primitives/dpf/*.proto yacl/link/transport/*.proto yacl/utils/*.proto)
list(REMOVE_ITEM PROTOS ${RM_PROTOS})
set(PROTO_GENERATED_DIR ${CMAKE_CURRENT_SOURCE_DIR}/third_party/proto-generated)
file(MAKE_DIRECTORY ${PROTO_GENERATED_DIR})
protobuf_generate_cpp(PROTO_SRCS PROTO_HDRS ${PROTO_GENERATED_DIR} ${PROTOS})
grpc_generate_cpp(GRPC_SRCS GRPC_HDRS ${PROTO_GENERATED_DIR} ${PROTOS})

file(GLOB ABSL_LIBS third_party/lib/libabsl_*)
# include directories and link libraries
include_directories(. include ${PROTO_GENERATED_DIR} third_party/include
        third_party/include/libsodium/include third_party/include/libsodium/include/sodium)
link_directories(third_party/lib)
link_libraries(${ABSL_LIBS})

# add third_party lib
set(THIRD_PARTY_MODULES)
file(GLOB THIRD_PARTY_PATHS ${CMAKE_CURRENT_SOURCE_DIR}/third_party/src/*)
foreach (third_party_dir ${THIRD_PARTY_PATHS})
    if (IS_DIRECTORY ${third_party_dir})
        file(GLOB THIRD_PARTY_SRCS ${third_party_dir}/*.c ${third_party_dir}/*.cc ${third_party_dir}/*.cpp)
        list(LENGTH THIRD_PARTY_SRCS size)
        if (NOT ${size} EQUAL 0)
            string(REGEX REPLACE "(.*)?/" "" module_name ${third_party_dir})
            add_library(${module_name} ${THIRD_PARTY_SRCS})
            target_link_libraries(${module_name} ssl crypto)
            list(APPEND THIRD_PARTY_MODULES ${module_name})
        endif ()
    endif ()
endforeach ()

# link libraries for the target
add_library(${PROJECT_NAME} SHARED ${SOURCES} ${PROTO_SRCS}) #${GRPC_SRCS}
target_link_libraries(${PROJECT_NAME} protobuf protobuf-lite # mcl
        tommath fmt ssl crypto blake3 sodium curve25519 leveldb cpu_features ${THIRD_PARTY_MODULES})
if (NOT APPLE)
    target_link_libraries(${PROJECT_NAME} stdc++fs)
endif ()
set(EXE_TARGETS)

# Building tests
include(FetchContent)
FetchContent_Declare(
        googletest
        GIT_REPOSITORY https://github.com/google/googletest.git
        GIT_TAG release-1.12.1
)
FetchContent_MakeAvailable(googletest)
add_library(GTest::GTest INTERFACE IMPORTED)
target_link_libraries(GTest::GTest INTERFACE GTest::gtest GTest::gtest_main GTest::gmock GTest::gmock_main)

# Building bench
foreach (path ${BENCH_SRCS})
    string(REPLACE ".cc" "" name ${path})
    string(REGEX REPLACE "(.*)?/" "" name ${name})
    string(REGEX REPLACE "/[^/]+\.cc" "" dir ${path})
    string(REGEX REPLACE "(.*)?/" "" dir ${dir})
    add_executable(${dir}_${name} ${path})
    target_link_libraries(${dir}_${name} ${PROJECT_NAME} benchmark gflags GTest::GTest)
    list(APPEND EXE_TARGETS ${dir}_${name})
endforeach ()

enable_testing()

# Building special target
#add_executable(alg_data_test ${CMAKE_CURRENT_SOURCE_DIR}/yacl/crypto/base/test/alg_data_test.cc)
#target_link_libraries(alg_data_test ${PROJECT_NAME} GTest::GTest)
#list(APPEND EXE_TARGETS alg_data_test)

# Building tests
add_executable(${PROJECT_NAME}_tests yacl/tests.cc)
target_link_libraries(${PROJECT_NAME}_tests ${PROJECT_NAME}
        gflags GTest::GTest
)
target_sources(${PROJECT_NAME}_tests PRIVATE ${TEST_SRCS})
list(APPEND EXE_TARGETS ${PROJECT_NAME}_tests)

# Print all targets
foreach (target ${EXE_TARGETS})
    message("target: ${target}")
endforeach ()

# Set target properties
set_target_properties(${EXE_TARGETS} PROPERTIES
        CXX_STANDARD ${CMAKE_CXX_STANDARD}
        CXX_EXTENSIONS OFF
        CXX_STANDARD_REQUIRED ON
)
