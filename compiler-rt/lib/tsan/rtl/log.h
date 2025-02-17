#ifndef TSAN_LOG_H
#define TSAN_LOG_H

#include "stdio.h"
#include "tsan_rtl.h"
#include "sanitizer_common/sanitizer_common.h"
#include "tsan_defs.h"
#include "tsan_interface.h"
#include "tsan_platform.h"
#include "tsan_report.h"
#include "tsan_sync.h"
#include "sanitizer_common/sanitizer_file.h"
#include "sanitizer_common/sanitizer_placement_new.h"
#include "sanitizer_common/sanitizer_report_decorator.h"
#include "sanitizer_common/sanitizer_stacktrace_printer.h"

// Options for what should be logged
// #define ENABLE_TSAN_DEFAULT_OUTPUT
#define LOG_THREAD_ON_READ
#define LOG_THREAD_ON_WRITE
#define LOG_MUTEX_LOCK_UNLOCK
#define LOG_THREAD_JOIN
#define LOG_THREAD_FORK

// LOG Message Format Options
// #define LOG_CALL_STACK
// #define LOG_NO_SOURCE
// #define LOG_HASH_SOURCE

#endif //TSAN_LOG_H
