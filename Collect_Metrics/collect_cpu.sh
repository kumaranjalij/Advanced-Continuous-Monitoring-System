#!/bin/bash

# Import common functions
source Collect_Metrics/common_functions.sh

INFLUXDB_MEASUREMENT_CPU="cpu_usage_metrics"


# Function to collect CPU collective data using sar
collect_cpu_data() {
    sar_data=$(sar -u 1 1 | grep "Average")
    user=$(echo $sar_data | awk '{print $3}')
    nice=$(echo $sar_data | awk '{print $4}')
    system=$(echo $sar_data | awk '{print $5}')
    iowait=$(echo $sar_data | awk '{print $6}')
    steal=$(echo $sar_data | awk '{print $7}')
    idle=$(echo $sar_data | awk '{print $8}')

    # Format the fields as required by InfluxDB
    fields="user=$user,nice=$nice,system=$system,iowait=$iowait,steal=$steal,idle=$idle"
    echo "CPU data: $fields"

    # Push data to InfluxDB
    push_to_influxdb "$INFLUXDB_MEASUREMENT_CPU" "$fields"
}

# Run the function
while true; do
    collect_cpu_data
    sleep 1
done
