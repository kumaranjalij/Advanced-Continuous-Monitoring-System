#!/bin/bash

# Import common functions
source Collect_Metrics/common_functions.sh

INFLUXDB_MEASUREMENT_IO="io_stats_metrics"

# Function to collect I/O data using sar
collect_io_data() {
    sar_data=$(sar -b 1 1 | grep "Average")
    
    tps=$(echo $sar_data | awk '{print $2}')
    rtps=$(echo $sar_data | awk '{print $3}')
    wtps=$(echo $sar_data | awk '{print $4}')
    dtps=$(echo $sar_data | awk '{print $5}')
    bread=$(echo $sar_data | awk '{print $6}')
    bwrtn=$(echo $sar_data | awk '{print $7}')
    bdscd=$(echo $sar_data | awk '{print $8}')

    # Format the fields for InfluxDB
    fields="tps=$tps,rtps=$rtps,wtps=$wtps,dtpd=$dtps,bread=$bread,bwrtn=$bwrtn,bdscd=$bdscd"
    echo "I/O data: $fields"

    # Push data to InfluxDB
    push_to_influxdb "$INFLUXDB_MEASUREMENT_IO" "$fields"
}

# Run the function
while true;do
    collect_io_data
    sleep 1
done
