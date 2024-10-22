#!/bin/bash

# Import common functions
source Collect_Metrics/common_functions.sh

INFLUXDB_MEASUREMENT_MEMORY="memory_usage_metrics"

# Function to collect memory data using sar
collect_memory_data() {
    sar_data=$(sar -r 1 1 | grep "Average")

    free_mem=$(echo $sar_data | awk '{print $2}')
    avail_mem=$(echo $sar_data | awk '{print $3}')
    used_mem=$(echo $sar_data | awk '{print $4}')
    perc_mem_used=$(echo $sar_data | awk '{print $5}')
    buffer_mem=$(echo $sar_data | awk '{print $6}')
    cached_mem=$(echo $sar_data | awk '{print $7}')

    
    commit_mem=$(echo $sar_data | awk '{print $8}')
    perc_commit_mem=$(echo $sar_data | awk '{print $9}')
    active_mem=$(echo $sar_data | awk '{print $10}')
    inactive_mem=$(echo $sar_data | awk '{print $11}')
    dirty_mem=$(echo $sar_data | awk '{print $12}')

    # Format the fields for InfluxDB
    fields="kbmemfree=$free_mem,kbavail=$avail_mem,kbmemused=$used_mem,%memused=$perc_mem_used,kbbuffers=$buffer_mem,kbcache=$cached_mem,kbcommit=$commit_mem,%commit=$perc_commit_mem,kbactive=$active_mem,kbinactive=$inactive_mem,kbdirty=$dirty_mem"
    echo "Memory data: $fields"

    # Push data to InfluxDB
    push_to_influxdb "$INFLUXDB_MEASUREMENT_MEMORY" "$fields"
}

# Run the function
while true;do
    collect_memory_data
    sleep 1
done
