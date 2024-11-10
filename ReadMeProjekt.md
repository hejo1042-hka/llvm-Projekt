# TSan Projektarbeit

## Requirements

- CMAKE 3.13.4 or higher
- One of the following OS:
    - Android (aarch64, x86_64)
    - Darwin (arm64, x86_64)
    - FreeBSD (64-bit)
    - Linux (aarch64, x86_64, powerpc64, powerpc64le)
    - NetBSD (64-bit)

## Build

1. Clone this project
2. `mkdir build && cd build`
3. `cmake -DLLVM_TARGETS_TO_BUILD=X86 -DLLVM_ENABLE_PROJECTS="clang;compiler-rt;" -DCMAKE_BUILD_TYPE=Release ../llvm`
   This will build clang and the runtime libraries including the ThreadSanitizer project.
   For debug puprposes use `CMAKE_BUILD_TYPE=Debug`
4. `cmake --build . -jn`  to build with `n` cores.
5. (optional) `make check-tsan` to build and run tests for TSan

More information about llvm and the build flags can be found [here](https://llvm.org/docs/GettingStarted.html#requirements).

## Usage

In order to compile your program with TSan enabled, you have two options.

### Option 1 (CMake)

1. Add the following to the cmake file of your program:

    ```cmake
    set(CMAKE_CXX_COMPILER "path/to/your/llvm/project/build/bin/clang++")

    add_link_options(-fsanitize=thread)

    add_executable(program_name your_program.cc)
    add_executable(program_name_sanitized  your_programm.cc)
    set_target_properties(program_name_sanitized PROPERTIES COMPILE_FLAGS "-fsanitize=thread -fPIE -pie -g -O1")
    ```

2. `mkdir build && cd build`
3. `cmake path/to/source`
4. `make`
5. Run your programm with `./program_name_sanitized 2>log.txt`, which will write the TSan output into `log.txt`
6. Open the log file `log.txt` to analyze the TSan output
