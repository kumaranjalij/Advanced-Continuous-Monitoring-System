#!/bin/bash

# InfluxDB configurations
INFLUXDB_HOST="localhost"
INFLUXDB_PORT="8086"
INFLUXDB_DATABASE="sys_metrics"


# Function to push data to InfluxDB
# Arguments:
#   1. measurement name
#   2. fields (formatted as field1=value1,field2=value2,...)
push_to_influxdb() {
    local measurement=$1
    local fields=$2
    local timestamp=$(date +%s%N)  # Nanoseconds

    # Replace with your InfluxDB credentials and database details
    curl -i -XPOST "http://$INFLUXDB_HOST:$INFLUXDB_PORT/write?db=$INFLUXDB_DATABASE" \
    --data-binary "$measurement $fields $timestamp"
}

# Example usage:
# push_to_influxdb "cpu" "user=23.5,nice=0.0,system=10.2,idle=65.3"
