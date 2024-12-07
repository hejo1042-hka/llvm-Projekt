# TSan Projektarbeit

This is the documentation for the Projektarbeit "ThreadSanitizer - Trace Generierung zwecks Offline Analyse". The foundation for this work, was already created by Martin Glauner and Julian Aßmann and can be found [here](https://github.com/martinglauner/llvm-project).

## update to current llvm version
The first part of the current project was to update the code of Martin Glauner and Julian Aßmann to the current llvm-project state. That was necessary because in the time after they finished their project and the current time, some updates happened. Especially the update of the virtual memory address randomization, that now uses more bits than at the time of the project from Martin Glauner and Julian Aßmann. Since TSan is using these addresses, but was not updated to the most recent version it could not work with the longer randomized addresses. More information to this problem can be found [here](https://github.com/google/sanitizers/issues/1716) and [here](https://stackoverflow.com/questions/77850769/fatal-threadsanitizer-unexpected-memory-mapping-when-running-on-linux-kernels).
Therefore, I took all the important parts, that Martin Glauner and Julian Aßmann already provided with their code and added those to the current version of the llvm project.
1. This includes the file [log.h](compiler-rt/lib/tsan/rtl/log.h) where you can comment in and out the lines, that define what actions shall be logged.
2. In the file [tsan_report.cpp](compiler-rt/lib/tsan/rtl/tsan_report.cpp) a method ```PrintFileAndLine``` was added to print the log messages.
3. In [tsan_rtl_thread.cpp](compiler-rt/lib/tsan/rtl/tsan_rtl_thread.cpp) the fork(s) and join(s) of threads are registered and then logged. The fork and join happens in the methods ```ThreadCreate``` and ```ThreadJoin```.
4. The file [tsan_rtl_mutex.cpp](compiler-rt/lib/tsan/rtl/tsan_rtl_mutex.cpp) is responsible for registering and logging the lock and unlock events for mutexes. These events are logged from the Methods ```RecordMutexLock``` and ```MutexUnlock```
5. In the file [tsan_rtl_access.cpp](compiler-rt/lib/tsan/rtl/tsan_rtl_access.cpp) all read and write events to memory location are captured and then logged. Both read and write events are logged from the ```MemoryAccess``` Method.
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

The idea here is to check, how much longer it takes TSan to run a programm, when the source code location is printed with the whole path to the file compared to when only a short number (hash) is printed. To test the runtime improvement with a hash of the source location, a fixed number (123) was used.

To get an average time each tested program was run 4 times. The tested programs where:
- [tiny_race](examples/tiny_race.cc) This program simulates a very simple race. Where three Threads write to the same variable and also read from that variable.
- [mutex_test](examples/tiny_race.cc) This program test, that mutex locks and unlocks are correctly identified. To do that 3 Threads are created and try to get a mutex lock do something and the unlock it.
- [locking_example](examples/locking_example.cc) In this program one Thread writes two variables and the other Thread uses them to calculate something. In order to do that some mutex operation are used. Thou the usage of the mutex operations still allows for race conditions.
- [mini_bench_local](examples/mini_bench_local.cpp) One of the official TSAN test programs. This program creates 4 threads and then each thread writes 100 times 100 numbers to an array. Every Thread access only its own set of positions in the array.
- [start_many_threads](examples/start_many_threads.cpp) One of the official TSAN test programs. This program creates 100 Threads and then joins all of them again.
- [mini_bench_shared](examples/mini_bench_shared.cpp) One of the official TSAN test programs. This program creates 4 threads and then each Thread reads 100 times 100 numbers from a shared array. Every Thread can access every position.

The exact results of the test runs can be found in the file [result.md](examples/measurement/result.md). The measurements resulted only in a very minor increase of runtime, when only a fixed number was printed instead of the whole source location. In both cases, the source location has to be calculated, in one case only the printed statement is shorter. To account for the fact, that even when a hash of the position is printed, the location itself has to be calculated, the part of the code, that calculates the source code position was executed. This code fragment can be found in [tsan_report.cpp line 128](compiler-rt/lib/tsan/rtl/tsan_report.cpp) and in [tsan_report.cpp line 156](compiler-rt/lib/tsan/rtl/tsan_report.cpp).
In the table below the results of the different test cases can be seen. When TSAN is enabled, the execution takes a significant time longer. That is to be expected, because every memory access, Thread operation and mutex operation must be recorded for the analysis. For the programs tiny_race, mutex_test and locking_example, there was only a minor increase in the execution time between the default TSAN output and the Tracer output without a source location. That is because for those three programs only a few operations need to be logged, and only a few operations are executed. All three programs are rather short. For the three programs mini_bench_local, start_many_threads and mini_bench_shared the execution times increase significantly. That is because a lot of operations need to be logged. And another reason here is, that each operation that shall be logged is immediately written to a file. In the sum of the operations relevant here, that takes a lot of time. When now also the source location shall be written to the log file another increase in execution time can be observed. That is, because in oder to determine the source location, a virtual call stack needs to be consulted, to load and traverse this call stack takes additional time. The difference between printing the exact source location and only a hash of it, can be neglected.

The logged operation of the tracer are the same for the three options No Source Location, Fixed Source Location (123), Exact Source Location. When TSAN is disabled, no Operations are logged at all. The default TSAN output does also log some operations and other information. But the default TSAN only writes a log file, when an actual race happens. The three test programs mini_bench_local, start_many_threads ,mini_bench_shared do not produce an actual race. Instead, those three programs are used by the official TSAN test, to check the execution time of TSAN. Because those three programms don't produce an actual race, the default TSAN output logs 0 lines.

### Execution Time Measurements (Average Time in Nanoseconds)

| Test Case              | With TSAN Disabled | Default TSAN Output | No Source Location | Fixed Source Location (123) | Exact Source Location | Logged Operations Tracer | Logged Lines for Default TSAN Output |
|------------------------|-------------------:|--------------------:|-------------------:|----------------------------:|----------------------:|-------------------------:|-------------------------------------:|
| **tiny_race**          |      1.010.253.859 |       1.460.940.819 |      1.482.788.721 |               1.825.988.269 |         1.832.168.491 |                       71 |                                   67 |
| **mutex_test**         |          5.785.554 |         390.576.568 |        401.925.724 |                 723.422.837 |           740.302.229 |                       40 |                                   36 |
| **locking_example**    |          5.375.015 |         445.588.896 |        464.736.824 |                 820.420.049 |           838.791.299 |                       34 |                                   46 |
| **mini_bench_local**   |          6.499.689 |          39.493.128 |     13.779.822.959 |              14.138.933.685 |        14.239.088.413 |                   80.417 |                                    0 |
| **start_many_threads** |         10.427.980 |          69.409.787 |        449.005.205 |                 824.144.521 |           823.809.125 |                      504 |                                    0 |
| **mini_bench_shared**  |          3.839.314 |          39.668.881 |     14.772.432.203 |              14.181.331.147 |        14.501.687.818 |                   80.684 |                                    0 |


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

### CMake

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
