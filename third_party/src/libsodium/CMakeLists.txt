cmake_minimum_required(VERSION 3.14)

project(sodium VERSION 1.0 LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 17)
add_compile_options(-DCONFIGURED -DHAVE_TI_MODE)
if (APPLE)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -march=armv8-a+crypto+aes")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -march=armv8-a+crypto+aes")
endif ()

# source files
file(GLOB_RECURSE SOURCES src/**/*.c)

set(SODIUM_HDR "src/libsodium/crypto_core/curve25519/ref10"
        "src/libsodium/crypto_generichash/blake2b/ref"
        "src/libsodium/crypto_onetimeauth/poly1305"
        "src/libsodium/crypto_onetimeauth/poly1305/donna"
        "src/libsodium/crypto_onetimeauth/poly1305/sse2"
        "src/libsodium/crypto_pwhash/argon2"
        "src/libsodium/crypto_pwhash/scryptsalsa208sha256"
        "src/libsodium/crypto_scalarmult/curve25519"
        "src/libsodium/crypto_scalarmult/curve25519/donna_c64"
        "src/libsodium/crypto_scalarmult/curve25519/ref10"
        "src/libsodium/crypto_scalarmult/curve25519/sandy2x"
        "src/libsodium/crypto_shorthash/siphash24/ref"
        "src/libsodium/crypto_sign/ed25519/ref10"
        "src/libsodium/crypto_stream/chacha20"
        "src/libsodium/crypto_stream/chacha20/dolbeau"
        "src/libsodium/crypto_stream/chacha20/ref"
        "src/libsodium/crypto_stream/salsa20"
        "src/libsodium/crypto_stream/salsa20/ref"
        "src/libsodium/crypto_stream/salsa20/xmm6"
        "src/libsodium/crypto_stream/salsa20/xmm6int"
        "src/libsodium/include"
        "src/libsodium/include/sodium"
        "src/libsodium/include/sodium/private")
# include directories and link libraries
include_directories(${SODIUM_HDR})

# link libraries for the target
add_library(${PROJECT_NAME} SHARED ${SOURCES})

# install libraries
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/src/libsodium TYPE INCLUDE
        FILES_MATCHING PATTERN "*.h")
install(TARGETS ${PROJECT_NAME}
        EXPORT SodiumTargets
        ARCHIVE DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
        LIBRARY DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
        RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
        INCLUDES DESTINATION ${CMAKE_INSTALL_PREFIX}/include)

# Set target properties
set_target_properties(${PROJECT_NAME} PROPERTIES
        CXX_STANDARD ${CMAKE_CXX_STANDARD}
        CXX_EXTENSIONS OFF
        CXX_STANDARD_REQUIRED ON
)
