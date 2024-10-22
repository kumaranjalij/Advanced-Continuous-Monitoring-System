#!/bin/bash

# Import common functions
source Collect_Metrics/common_functions.sh

INFLUXDB_MEASUREMENT_NETWORK="network_metrics"
# INTERFACE="lo"

# Function to collect network data using sar
collect_network_data() {
    sar_data=$(sar -n DEV 1 1 | grep "Average")

    while read -r line; do
        iface=$(echo $line | awk '{print $2}')
        rxpck_s=$(echo $line | awk '{print $3}')
        txpck_s=$(echo $line | awk '{print $4}')
        rxkB_s=$(echo $line | awk '{print $5}')
        txkB_s=$(echo $line | awk '{print $6}')
        ifutil=$(echo $line | awk '{print $9}')

        # Format the fields for InfluxDB
        fields="rxpck_s=${rxpck_s},txpck_s=${txpck_s},rxkB_s=${rxkB_s},txkB_s=${txkB_s},ifutil=${ifutil}"
        echo "Network data for $iface: $fields"

        # Push data to InfluxDB
        push_to_influxdb "$INFLUXDB_MEASUREMENT_NETWORK,iface=$iface" "$fields"
    done <<< "$sar_data"
}

# Run the function
while true;do
    collect_network_data
    sleep 1
done
