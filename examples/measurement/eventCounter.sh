if [ $# -ne 1 ]; then
  echo "Usage: $0 <file>"
  exit 1
fi

file=$1

# Count occurrences of fork( and join( combined
fork_count=$(grep -o 'fork(' "$file" | wc -l)
join_count=$(grep -o 'join(' "$file" | wc -l)
total_fork_join=$((fork_count + join_count))

# Count occurrences of wr( and rd( combined
wr_count=$(grep -o 'wr(' "$file" | wc -l)
rd_count=$(grep -o 'rd(' "$file" | wc -l)
total_wr_rd=$((wr_count + rd_count))

# Count occurrences of acq( and rel( combined
acq_count=$(grep -o 'acq(' "$file" | wc -l)
rel_count=$(grep -o 'rel(' "$file" | wc -l)
total_acy_rel=$((acq_count + rel_count))

echo "Total occurrences of 'fork(' and 'join(': $total_fork_join"
echo "Total occurrences of 'wr(' and 'rd(': $total_wr_rd"
echo "Total occurrences of 'acq(' and 'rel(': $total_acy_rel"
