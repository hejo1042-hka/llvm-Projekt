cmake_minimum_required(VERSION 3.5)
set(CMAKE_CXX_COMPILER "/home/user/Dokumente/Projekt2/llvm-Projekt/build/bin/clang++")
project(examples)

add_executable(tiny_race tiny_race.cc)
add_executable(tiny_race_sanitized tiny_race.cc)
set_target_properties(tiny_race_sanitized PROPERTIES COMPILE_FLAGS "-fsanitize=thread -g -O0")
target_link_options(tiny_race_sanitized PRIVATE -fsanitize=thread)

add_executable(mutex_test mutex_test.cc)
add_executable(mutex_test_sanitized mutex_test.cc)
set_target_properties(mutex_test_sanitized PROPERTIES COMPILE_FLAGS "-fsanitize=thread -g -O0")
target_link_options(mutex_test_sanitized PRIVATE -fsanitize=thread)

add_executable(locking_example locking_example.cc)
add_executable(locking_example_sanitized locking_example.cc)
set_target_properties(locking_example_sanitized PROPERTIES COMPILE_FLAGS "-fsanitize=thread -g -O0")
target_link_options(locking_example_sanitized PRIVATE -fsanitize=thread)

add_executable(mini_bench_local mini_bench_local.cpp)
add_executable(mini_bench_local_sanitized mini_bench_local.cpp)
set_target_properties(mini_bench_local_sanitized PROPERTIES COMPILE_FLAGS "-fsanitize=thread -g -O0")
target_link_options(mini_bench_local_sanitized PRIVATE -fsanitize=thread)

add_executable(start_many_threads start_many_threads.cpp)
add_executable(start_many_threads_sanitized start_many_threads.cpp)
set_target_properties(start_many_threads_sanitized PROPERTIES COMPILE_FLAGS "-fsanitize=thread -g -O0")
target_link_options(start_many_threads_sanitized PRIVATE -fsanitize=thread)

add_executable(mini_bench_shared mini_bench_shared.cpp)
add_executable(mini_bench_shared_sanitized mini_bench_shared.cpp)
set_target_properties(mini_bench_shared_sanitized PROPERTIES COMPILE_FLAGS "-fsanitize=thread -g -O0")
target_link_options(mini_bench_shared_sanitized PRIVATE -fsanitize=thread)
