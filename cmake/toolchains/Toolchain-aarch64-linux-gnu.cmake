# More on cross-compilation: https://cmake.org/cmake/help/latest/manual/cmake-toolchains.7.html

include(CMakeForceCompiler)

# this one is important
set(CMAKE_SYSTEM_NAME Linux)

set(CMAKE_SYSTEM_PROCESSOR aarch64)

#this one not so much
set(CMAKE_SYSTEM_VERSION 1)

# specify the cross compiler
find_program(C_COMPILER aarch64-linux-gnu-gcc)

if(NOT C_COMPILER)
	message(STATUS "Make sure to: apt-get install aarch64-linux-gnu-gcc")
	message(FATAL_ERROR "could not find aarch64-linux-gnu-gcc compiler")
endif()
cmake_force_c_compiler(${C_COMPILER} GNU)

find_program(CXX_COMPILER aarch64-linux-gnu-g++)

if(NOT CXX_COMPILER)
	message(FATAL_ERROR "could not find aarch64-linux-gnu-g++ compiler")
endif()
cmake_force_cxx_compiler(${CXX_COMPILER} GNU)

# compiler tools
foreach(tool objcopy nm ld)
	string(TOUPPER ${tool} TOOL)
	find_program(${TOOL} aarch64-linux-gnu-${tool})
	if(NOT ${TOOL})
		message(FATAL_ERROR "could not find aarch64-linux-gnu-${tool}")
	endif()
endforeach()

# os tools
foreach(tool echo grep rm mkdir nm cp touch make unzip)
	string(TOUPPER ${tool} TOOL)
	find_program(${TOOL} ${tool})
	if(NOT ${TOOL})
		message(FATAL_ERROR "could not find ${TOOL}")
	endif()
endforeach()

set(LINKER_FLAGS "-Wl,-gc-sections")
set(CMAKE_EXE_LINKER_FLAGS ${LINKER_FLAGS})
set(CMAKE_C_FLAGS ${C_FLAGS})
set(CMAKE_CXX_LINKER_FLAGS ${C_FLAGS} -mcpu=cortex-a53 -O3 -funsafe-math-optimizations -mthumb-interwork -ftree-vectorize)

# where is the target environment
set(CMAKE_FIND_ROOT_PATH  get_file_component(${C_COMPILER} PATH))

# search for programs in the build host directories
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
# for libraries and headers in the target directories
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# enable static linking
#set(LDFLAGS "--disable-shared")
