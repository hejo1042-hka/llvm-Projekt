cmake_minimum_required(VERSION 3.5)
#set(CMAKE_CXX_COMPILER "/Users/I575211/Development/llvm-project/build_cmake/bin/clang++")
set(CMAKE_CXX_COMPILER "/home/user/Dokumente/Projekt2/llvm-Projekt/build/bin/clang++")
project(examples)

# add_compile_options(-fsanitize=thread)
add_link_options(-fsanitize=thread)

add_executable(tiny_race tiny_race.cc)
add_executable(tiny_race_sanitized tiny_race.cc)
set_target_properties(tiny_race_sanitized PROPERTIES COMPILE_FLAGS "-fsanitize=thread -g -O0")

#add_executable(mutex_test mutex_test.cc)
#add_executable(mutex_test_sanitized mutex_test.cc)
#set_target_properties(mutex_test_sanitized PROPERTIES COMPILE_FLAGS "-fsanitize=thread -g -O0")
#
#add_executable(locking_example locking_example.cc)
#add_executable(locking_example_sanitized locking_example.cc)
#set_target_properties(locking_example_sanitized PROPERTIES COMPILE_FLAGS "-fsanitize=thread -g -O0")
# add_executable(locking_example_two  locking_example.cc)
# set_target_properties(locking_example_two PROPERTIES COMPILE_FLAGS "-fsanitize=thread -fPIE -pie -g -O1")
