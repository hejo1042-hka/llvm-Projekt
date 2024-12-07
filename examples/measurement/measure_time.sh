programs=(
    "tiny_race_sanitized"
    "mutex_test_sanitized"
    "locking_example_sanitized"
    "mini_bench_local_sanitized"
    "start_many_threads_sanitized"
    "mini_bench_shared_sanitized"
)
#programs=(
#    "tiny_race"
#    "mutex_test"
#    "locking_example"
#    "mini_bench_local"
#    "start_many_threads"
#    "mini_bench_shared"
#)

number_runs=4

output_file=./execution_times.txt
#echo "Execution Time Measurements (in nanoseconds):" > "$output_file" # overwrite previous content
echo "Execution Time Measurements (in nanoseconds):" >> "$output_file"

for program in "${programs[@]}"
do
    total_time=0
    total_lines=0

    for ((i = 0; i < number_runs; i++)); do
        start_time=$(date +%s%N)

        TSAN_OPTIONS="log_path=logFile.txt" ../build/"$program" & pid=$!
        wait $pid

        end_time=$(date +%s%N)
        elapsed_time=$((end_time - start_time))
        total_time=$((total_time + elapsed_time))

        log_file="logFile.txt.$pid"

        num_lines=$(wc -l < "$log_file")
        total_lines=$((total_lines + num_lines))
    done

    # Calculate averages
    average_time=$((total_time / number_runs))
    average_lines=$((total_lines / number_runs))
    echo "$program - Average Time: $average_time nanoseconds, Total Time: $total_time nanoseconds, Average Lines Written: $average_lines lines"

    # Write to output file
    echo "$program - Average Time: $average_time nanoseconds, Total Time: $total_time nanoseconds, Average Lines Written: $average_lines lines" >> "$output_file"
done

rm logFile.txt.*
echo "Results written to $output_file."
