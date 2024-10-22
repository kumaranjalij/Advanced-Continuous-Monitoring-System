#!/bin/bash

# Import common functions
source Collect_Metrics/common_functions.sh

INFLUXDB_MEASUREMENT_CPU_COREWISE="cpu_corewise_usage_metrics"

# Function to collect CPU core-wise data using sar
collect_cpu_corewise_data() {
    sar_data=$(sar -P ALL 1 1 | grep "Average")
    
    # Loop through each core and extract its data
    while read -r line; do
        if [[ $line == *Average* ]] && [[ $line != *all* ]] && [[ $line != *CPU* ]]; then
            core=$(echo $line | awk '{print $2}')
            user=$(echo $line | awk '{print $3}')
            nice=$(echo $line | awk '{print $4}')
            system=$(echo $line | awk '{print $5}')
            iowait=$(echo $line | awk '{print $6}')
            steal=$(echo $line | awk '{print $7}')
            idle=$(echo $line | awk '{print $8}')

            # Format the fields for InfluxDB
            fields="user=$user,nice=$nice,system=$system,iowait=$iowait,steal=$steal,idle=$idle"
            echo "CPU Core $core data: $fields"

            # Push data to InfluxDB
            push_to_influxdb "$INFLUXDB_MEASUREMENT_CPU_COREWISE,core=$core" "$fields"
        fi
    done <<< "$sar_data"
}

# Run the function
while true; do
    collect_cpu_corewise_data
    sleep 1
done
