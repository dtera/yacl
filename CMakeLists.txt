cmake_minimum_required(VERSION 3.14)

project(yacl VERSION 1.0 LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 17)

file(GLOB SOURCES yacl/base/*.cc yacl/crypto/base/mpint/*.cc yacl/utils/parallel_*.cc yacl/utils/thread_pool.cc)
file(GLOB TEST_SRCS yacl/base/*_test.cc yacl/crypto/base/mpint/*_test.cc yacl/utils/parallel_test.cc)
file(GLOB BENCH_SRCS yacl/base/*_bench.cc yacl/crypto/base/mpint/benchmark/mpint_bench.cc)
list(REMOVE_ITEM SOURCES ${TEST_SRCS} ${BENCH_SRCS})
list(REMOVE_ITEM TEST_SRCS ${CMAKE_CURRENT_SOURCE_DIR}/yacl/base/dynamic_bitset_test.cc)
list(REMOVE_ITEM BENCH_SRCS ${CMAKE_CURRENT_SOURCE_DIR}/yacl/base/block_bench.cc)

# include directories and link libraries
include_directories(. third_party/include)
link_directories(third_party/lib)
set(EXTRA_LIB)
if (APPLE)
    find_package(benchmark REQUIRED)
    find_package(gflags REQUIRED)
    execute_process(COMMAND brew --prefix libomp OUTPUT_VARIABLE BREW_libomp_PREFIX OUTPUT_STRIP_TRAILING_WHITESPACE)
    include_directories(${BREW_libomp_PREFIX}/include)
    link_libraries(${BREW_libomp_PREFIX}/lib/libomp.dylib)
    list(APPEND EXTRA_LIB benchmark::benchmark gflags)
else ()
    link_directories(third_party/lib64)
endif ()

# link libraries for the target
add_library(${PROJECT_NAME}_lib SHARED ${SOURCES})
#target_sources(${PROJECT_NAME}_lib PRIVATE ${SOURCES})
target_link_libraries(${PROJECT_NAME}_lib absl_int128 absl_strings absl_symbolize absl_stacktrace tommath fmt
        ${EXTRA_LIB})

set(EXE_TARGETS)

# Building bench
foreach (bench_file ${BENCH_SRCS})
    string(REPLACE ".cc" "" bench_name ${bench_file})
    string(REGEX REPLACE "(.*)?/" "" bench_name ${bench_file})
    add_executable(${PROJECT_NAME}_${bench_name} ${bench_file})
    target_link_libraries(${PROJECT_NAME}_${bench_name} ${PROJECT_NAME}_lib)
    list(APPEND EXE_TARGETS ${PROJECT_NAME}_${bench_name})
endforeach ()

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

enable_testing()
add_executable(${PROJECT_NAME}_tests yacl/tests.cc)
target_link_libraries(${PROJECT_NAME}_tests ${PROJECT_NAME}_lib
        GTest::GTest
        )
target_sources(${PROJECT_NAME}_tests PRIVATE ${TEST_SRCS})
list(APPEND EXE_TARGETS ${PROJECT_NAME}_tests)

foreach (target ${EXE_TARGETS})
    message("target: ${target}")
endforeach ()
set_target_properties(${EXE_TARGETS} PROPERTIES
        CXX_STANDARD ${CMAKE_CXX_STANDARD}
        CXX_EXTENSIONS OFF
        CXX_STANDARD_REQUIRED ON
        )
