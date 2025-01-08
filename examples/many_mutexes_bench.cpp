#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <mutex>


std::mutex mutex;
int *a;

void *Thread(void* unused) {
  for (int j = 0; j < 100; j++) {
    mutex.lock();
    int b = a[j];
    mutex.unlock();
  }

  return 0;
}

int main() {
  int length = 100;
  pthread_t *t = new pthread_t[length];
  a = new int[length];

  for (int i = 0; i < length; i++) {
    int status = pthread_create(&t[i], 0, Thread, (void*)0);
  }

  for (int i = 0; i < length; i++) {
    pthread_join(t[i], 0);
  }

  delete [] t;
  delete [] a;
  return 0;
}
