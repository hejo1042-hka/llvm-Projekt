#include <mutex>
#include <thread>
#include <iostream>

int main()
{
     int a = 0;
     std::mutex mutex;
mutex.lock();
     std::thread t1([&]
     {
          mutex.lock();
          std::cout << "Thread 1 prints a: " << a << std::endl;
          mutex.unlock();
          a = 42;
          std::cout << "Thread 1 prints a: " << a << std::endl; 
     });
     std::thread t2([&]
     { 
          std::cout << "Thread 2 prints a: " << a << std::endl;
          mutex.lock();
          a = 43;
          mutex.unlock();
          std::cout << "Thread 1 prints a: " << a << std::endl; 
     });
     for (size_t i = 0; i < 200000; i++) {

     }
     mutex.unlock();
     t1.join();
     t2.join();
}
