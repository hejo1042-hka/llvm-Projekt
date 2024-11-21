# TSan Projektarbeit

This is the documentation for the Projektarbeit "ThreadSanitizer - Trace Generierung zwecks Offline Analyse". The foundation for this work, was already created by Martin Glauner and Julian Aßmann and can be found [here](https://github.com/martinglauner/llvm-project).

## update to current llvm version
The first part of the current project was to update the code of Martin Glauner and Julian Aßmann to the current llvm-project state. That was necessary because in the time after they finished their project and the current time, some updates happened. Especially the update of the virtual memory address randomization, that now uses more bits than at the time of the project from Martin Glauner and Julian Aßmann. Since TSan is using these addresses, but was not updated to the most recent version it could not work with the longer randomized addresses. More information to this problem can be found [here](https://github.com/google/sanitizers/issues/1716) and [here](https://stackoverflow.com/questions/77850769/fatal-threadsanitizer-unexpected-memory-mapping-when-running-on-linux-kernels).
Therefore, I took all the important parts, that Martin Glauner and Julian Aßmann already provided with their code and added those to the current version of the llvm project.
1. This includes the file [log.h](compiler-rt/lib/tsan/rtl/log.h) where you can comment in and out the lines, that define what actions shall be logged.
2. In the file [tsan_report.cpp](compiler-rt/lib/tsan/rtl/tsan_report.cpp) a method was added to print the log messages.
3. In [tsan_rtl_thread.cpp](compiler-rt/lib/tsan/rtl/tsan_rtl_thread.cpp) the fork(s) and join(s) of threads are registered and then logged.
4. The file [tsan_rtl_mutex.cpp](compiler-rt/lib/tsan/rtl/tsan_rtl_mutex.cpp) is responsible for registering and logging the lock and unlock events for mutexes.
5. In the file [tsan_rtl_access.cpp](compiler-rt/lib/tsan/rtl/tsan_rtl_access.cpp) all read and write events to memory location are captured and then logged.
6. In the file [tsan_rtl_report.cpp](compiler-rt/lib/tsan/rtl/tsan_rtl_report.cpp) a method ```PrintFileAndLine``` was added, which is used by most of the added logging functionality to generate and write the actual log message.

## further improvements
Some improvements were made to the original code from Martin Glauner and Julian Aßmann.
1. Not all log messages were actually using the ```PrintFileAndLine``` method. Therefore, all necessary log messages were redirected to use the ```PrintFileAndLine``` method.
2. Unfortunately the log message for a Thread event does not have the same parameters and information available that the other events have. Because of that a new log method ```PrintFileAndLineForThread``` was added.
3. Furthermore, the file [log.h](compiler-rt/lib/tsan/rtl/log.h) provided an option to disable the default output of TSan. Unfortunately not all default log messages were disabled. This was also improved.
4. Because TSan uses some wrapper functionality to handle the Thread fork and join events as well as the Mutex lock and unlock events, the code position that was written in the log message was not correct and instead pointed to the code position of the wrapper. To actually show the real code postion, an option ```LOG_CALL_STACK``` was added, which logs the whole call stack for events that are logged. When this option is enabled, the log message includes all code-position, up until the position, from where in the event was triggered by the code of the user. This can look like this: 
   ```
   T0|fork(T1)|/home/user/Dokumente/Projekt2/llvm-Projekt/compiler-rt/lib/tsan/rtl/tsan_interceptors_posix.cpp:1041
           /home/user/Dokumente/Projekt2/llvm-Projekt/examples/tiny_race.cc:38
   ```
5. Another important change was the update of the format of the log messages. Before there was no clear format used in the log messages. Now the ```STD (Standard) Format``` is used to log the events. The output for the STD Format looks like this: ```Thread_id|operation(memory_location/Thread_id)|program_location```. The possible operations are:
   - r (read)
   - w (write)
   - acq (acquire of lock object)
   - rel (release of lock object)
   - fork
   - join
   
   Further information of the STD Format can be found [here](https://github.com/focs-lab/rapid). Following is an example STD file.
   ```
   T0|r(V123)|345
   T1|w(V234.23[0])|456
   T0|fork(T2)|123
   T2|acq(L34)|120
   T2|rel(L34)|130
   T0|join(T2)|134
   ```
   When you compare the sample STD file to the current output of log messages of this code you can see, that the source code location of the STD Format is far shorter, than the current log message. That is because, the STD sample seems to hash the source location, while we provide the entire path of the source location. 
6. Another feature was the discovery of how to redirect the logged events in a file instead of printing them to the console. Printing them to the console is not recommended, because that can interfere with the output of the actual program. It is rather easy to redirect the log output to a file, because llvm already provides the functionality for that. To write our log messages we use the ```Printf``` function, defined by TSan in [sanitizer_printf.cpp](compiler-rt/lib/sanitizer_common/sanitizer_printf.cpp). This function can already handle the write of messages to a file. And does all the needed things for that, for example the eventually necessary reopening of the log file and so on. In order to tell TSan in which file the log messages shall be written we can provide the option ```TSAN_OPTIONS="log_path=logFile.txt" ./program_name_sanitized``` at the start of the sanitized program.

## analyze runtime 

The idea here is to check, how much longer it takes TSan to run a programm, when the source code location is printed with the whole path to the file compared to when only a short number (hash) is printed.

## How to use it

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
   This will probably take a while.
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
5. Run your program with `TSAN_OPTIONS="log_path=logFile.txt" ./program_name_sanitized`. This will run your program and write all the TSan log messages in the file logFile.txt.pid. pid is the process id. 
   1. Run your programm with `./program_name_sanitized 2>log.txt`, which will write the TSan output into `log.txt` You can also run it with `./program_name_sanitized` this will print all log infos to the console. 
   This is not recommend because this will interfere with all the things printed to the console by your program.
6. Open the log file `logFile.txt.pid` to analyze the TSan output
