programs=(
    "tiny_race_sanitized"
    "mutex_test_sanitized"
    "locking_example_sanitized"
    "mini_bench_local_sanitized"
    "start_many_threads_sanitized"
    "mini_bench_shared_sanitized"
)

number_runs=4

output_file=../measurement/execution_times.txt
#echo "Execution Time Measurements (in nanoseconds):" > "$output_file" # overwrite previous content
echo "Execution Time Measurements (in nanoseconds):" >> "$output_file"

for program in "${programs[@]}"
do
    total_time=0

    for ((i = 0; i < number_runs; i++)); do
        start_time=$(date +%s%N)
        TSAN_OPTIONS="log_path=logFile.txt" ./"$program"
        end_time=$(date +%s%N)
        elapsed_time=$((end_time - start_time))
        total_time=$((total_time + elapsed_time))
    done

    # Calculate average time
    average_time=$((total_time / number_runs))
    echo "$program - Average Time: $average_time nanoseconds total: $total_time"

    # Write to output file
    echo "$program - Average Time: $average_time nanoseconds total: $total_time" >> "$output_file"
done

echo "Results written to $output_file."
