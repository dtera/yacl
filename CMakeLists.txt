cmake_minimum_required(VERSION 3.14)

project(yacl VERSION 1.0 LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 17)

option(GE_M1_CHIP "WHETHER M1 CHIP" ON)
set(EXTRA_LIB)
add_definitions(-DMSGPACK_NO_BOOST)

# brew install grpc
if (APPLE)
    if (GE_M1_CHIP)
        set(OPT_PATH /opt/homebrew/opt)
    else ()
        set(OPT_PATH /usr/local/opt)
    endif ()
    set(GRPC_ROOT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/third_party/grpc)  # ${OPT_PATH}/grpc
    find_package(benchmark REQUIRED)
    find_package(gflags REQUIRED)
    execute_process(COMMAND brew --prefix libomp OUTPUT_VARIABLE BREW_libomp_PREFIX OUTPUT_STRIP_TRAILING_WHITESPACE)
    include_directories(${BREW_libomp_PREFIX}/include)
    link_libraries(${BREW_libomp_PREFIX}/lib/libomp.dylib)
    list(APPEND EXTRA_LIB benchmark::benchmark gflags)
else ()
    set(GRPC_ROOT_DIR /usr/local/grpc)
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
file(GLOB_RECURSE RM_SRCS yacl/base/dynamic_bitset_test.cc yacl/link/*
        yacl/crypto/base/drbg/intel_entropy_source.* yacl/crypto/primitives/ot/* yacl/crypto/primitives/vole/*
        yacl/crypto/primitives/dpf/*.cc yacl/crypto/base/test/alg_data_test.cc yacl/io/kv/leveldb_kvstore.cc
        yacl/io/kv/kvstore_test.cc yacl/utils/serialize.*)
list(REMOVE_ITEM SOURCES ${TEST_SRCS} ${BENCH_SRCS} ${RM_SRCS})
list(REMOVE_ITEM TEST_SRCS ${RM_SRCS})
list(REMOVE_ITEM BENCH_SRCS ${RM_SRCS})

# config auto generated for protobuf
file(GLOB_RECURSE PROTOS yacl/*.proto)
file(GLOB_RECURSE RM_PROTOS yacl/crypto/primitives/dpf/*.proto yacl/link/*.proto yacl/utils/*.proto)
list(REMOVE_ITEM PROTOS ${RM_PROTOS})
set(PROTO_GENERATED_DIR ${CMAKE_CURRENT_SOURCE_DIR}/third_party/proto-generated)
file(MAKE_DIRECTORY ${PROTO_GENERATED_DIR})
protobuf_generate_cpp(PROTO_SRCS PROTO_HDRS ${PROTO_GENERATED_DIR} ${PROTOS})
grpc_generate_cpp(GRPC_SRCS GRPC_HDRS ${PROTO_GENERATED_DIR} ${PROTOS})

# include directories and link libraries
include_directories(. include ${PROTO_GENERATED_DIR} third_party/include
        third_party/include/libsodium/include third_party/include/libsodium/include/sodium)
link_directories(third_party/lib)

set(ABSL_LIB absl_int128 absl_strings absl_symbolize absl_stacktrace absl_throw_delegate)
# link libraries for the target
add_library(${PROJECT_NAME} SHARED ${SOURCES} ${PROTO_SRCS}) #${GRPC_SRCS}
#target_sources(${PROJECT_NAME}_lib PRIVATE ${SOURCES})
target_link_libraries(${PROJECT_NAME} ${ABSL_LIB} # protobuf::libprotobuf protobuf::libprotobuf-lite
        tommath fmt ssl crypto blake3 sodium curve25519 mcl leveldb)
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
    target_link_libraries(${dir}_${name} ${PROJECT_NAME} ${EXTRA_LIB} GTest::GTest)
    list(APPEND EXE_TARGETS ${dir}_${name})
endforeach ()

enable_testing()

# Building special target
add_executable(alg_data_test ${CMAKE_CURRENT_SOURCE_DIR}/yacl/crypto/base/test/alg_data_test.cc)
target_link_libraries(alg_data_test ${PROJECT_NAME} GTest::GTest)
list(APPEND EXE_TARGETS alg_data_test)

# Building tests
add_executable(${PROJECT_NAME}_tests yacl/tests.cc)
target_link_libraries(${PROJECT_NAME}_tests ${PROJECT_NAME}
        ${EXTRA_LIB} GTest::GTest
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
