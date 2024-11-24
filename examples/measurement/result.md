# Execution Time Measurements (Average Time in Nanoseconds)

| Test Case                         | Exact Source Location | Fixed Source Location (123) | Without Sanitization |
|-----------------------------------|----------------------:|----------------------------:|---------------------:|
| **tiny_race**                     |         1.826.626.830 |               1.822.252.511 |        1.010.202.251 |
| **mutex_test**                    |           716.803.717 |                 727.468.271 |           10.889.846 |
| **locking_example**               |           816.602.994 |                 820.139.131 |            7.278.513 |
| **mini_bench_local**              |        15.095.990.192 |              15.063.655.025 |            8.999.076 |
| **start_many_threads**            |           812.918.887 |                 875.231.893 |           16.017.213 |
| **mini_bench_shared**             |        14.536.261.936 |              14.802.770.866 |            7.335.853 |
