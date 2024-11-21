programs=(
    "tiny_race_sanitized"
    "mutex_test_sanitized"
    "locking_example_sanitized"
    "mini_bench_local_sanitized"
    "start_many_threads_sanitized"
    "mini_bench_shared_sanitized"
)

output_file="execution_times.txt"
echo "Execution Time Measurements (in nanoseconds):" > "$output_file" # overwrite previous content

for program in "${programs[@]}"
do
    total_time=0
    for i in {1..3}
    do
        start_time=$(date +%s%N)
        ./"$program"
        end_time=$(date +%s%N)
        elapsed_time=$((end_time - start_time))
        total_time=$((total_time + elapsed_time))
    done

    # Calculate average time
    average_time=$((total_time / 3))
    echo "$program - Average Time: $average_time nanoseconds"

    # Write to output file
    echo "$program - Average Time: $average_time nanoseconds" >> "$output_file"
done

echo "Results written to $output_file."
