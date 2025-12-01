cmake_minimum_required(VERSION 3.22)
project(vpn_native LANGUAGES C CXX)

# Set common compile features
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Ensure position-independent code for shared libs
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Force 16KB max page size for Android 15+ requirement
add_link_options("-Wl,-z,max-page-size=16384")

# Example stub library targets. Replace sources with real ones when available.

add_library(openvpn SHARED
        stub/openvpn_stub.c)
target_include_directories(openvpn PRIVATE .)

add_library(jbcrypto SHARED
        stub/jbcrypto_stub.c)
target_include_directories(jbcrypto PRIVATE .)

add_library(opvpnutil SHARED
        stub/opvpnutil_stub.c)
target_include_directories(opvpnutil PRIVATE .)

add_library(ovpnexec SHARED
        stub/ovpnexec_stub.c)
target_include_directories(ovpnexec PRIVATE .)

# Link against log if needed
find_library(log-lib log)
foreach(t IN ITEMS openvpn jbcrypto opvpnutil ovpnexec)
    target_link_libraries(${t} PRIVATE ${log-lib})
endforeach()


