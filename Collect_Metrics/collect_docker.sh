#!/bin/bash

# Import common functions
source Collect_Metrics/common_functions.sh

INFLUXDB_MEASUREMENT_DOCKER="docker_container_metrics"
INFLUXDB_MEASUREMENT_CONTAINER_STATUS="container_status_metrics"
INFLUXDB_MEASUREMENT_DEPLOYMENT_STATUS="docker_deployment_metrics"
INFLUXDB_MEASUREMENT_EXIT_STATUS="docker_exit_status"
INFLUXDB_MEASUREMENT_DOCKER_DEPLOYMENT_COUNT="docker_deployment_count"

successful_deployments=0
failed_deployments=0


# Convert human-readable sizes to bytes
convert_to_bytes() {
    value=$1
    case $value in
        *KiB) echo "$(echo $value | sed 's/KiB//') * 1024" | bc ;;
        *MiB) echo "$(echo $value | sed 's/MiB//') * 1024 * 1024" | bc ;;
        *GiB) echo "$(echo $value | sed 's/GiB//') * 1024 * 1024 * 1024" | bc ;;
        *kB) echo "$(echo $value | sed 's/kB//') * 1000" | bc ;;
        *MB) echo "$(echo $value | sed 's/MB//') * 1000000" | bc ;;
        *GB) echo "$(echo $value | sed 's/GB//') * 1000000000" | bc ;;
        *B) echo "$(echo $value | sed 's/B//') * 1" | bc ;;
        *) echo $value ;;
    esac
}

# Function to sanitize container name for InfluxDB
sanitize_container_name() {
    echo "$1" | tr -d ' ' | tr ',' '_'
}

# # Function to push deployment data to InfluxDB
# push_deployment_to_influxdb() {    
#     local timestamp=$(date +%s%N)  # Nanoseconds

#     curl -i -XPOST "http://$INFLUXDB_HOST:$INFLUXDB_PORT/write?db=$INFLUXDB_DATABASE" \
#     --data-binary "docker_deployments count=1 $timestamp"
# }


# Function to collect Docker container metrics
collect_docker_metrics() {
    # Get container IDs and names
    container_info=$(docker ps --format "{{.ID}},{{.Names}}")

    # Loop through each container and extract its metrics
    while IFS=',' read -r container_id container_name; do
        # Collect metrics for the specific container ID
        docker_stats=$(docker stats --no-stream --format \
        "{{.CPUPerc}},{{.MemUsage}},{{.NetIO}},{{.BlockIO}},{{.PIDs}}" "$container_id")

        IFS=',' read -r cpu mem netio blockio pids <<< "$docker_stats"

        # Remove non-numeric parts from CPU and convert to float
        cpu=$(echo $cpu | tr -d '%')

        # Extract numeric memory usage and convert to bytes
        mem_usage=$(echo $mem | awk '{print $1}')
        mem_usage_bytes=$(convert_to_bytes "$mem_usage")

        # Extract and convert net and block I/O values
        net_rx=$(echo $netio | cut -d'/' -f1 | tr -d ' ')
        net_rx_bytes=$(convert_to_bytes "$net_rx")

        net_tx=$(echo $netio | cut -d'/' -f2 | tr -d ' ')
        net_tx_bytes=$(convert_to_bytes "$net_tx")

        block_read=$(echo $blockio | cut -d'/' -f1 | tr -d ' ')
        block_read_bytes=$(convert_to_bytes "$block_read")

        block_write=$(echo $blockio | cut -d'/' -f2 | tr -d ' ')
        block_write_bytes=$(convert_to_bytes "$block_write")

        # Sanitize the container name for InfluxDB
        sanitized_container_name=$(sanitize_container_name "$container_name")

        # Format the tags and fields for InfluxDB
        # Tags: container_id, container_name
        # Fields: cpu_usage, mem_usage, net_rx, net_tx, block_read, block_write, pids
        fields="cpu_usage=$cpu,mem_usage=$mem_usage_bytes,net_rx=$net_rx_bytes,net_tx=$net_tx_bytes,block_read=$block_read_bytes,block_write=$block_write_bytes,pids=$pids"
        tags="container_id=\"$container_id\",container_name=\"$sanitized_container_name\""
        
        echo "Docker Container $sanitized_container_name ($container_id) data: $tags $fields"

        # Push data to InfluxDB with tags and fields
        push_to_influxdb "$INFLUXDB_MEASUREMENT_DOCKER,$tags" "$fields"

    done <<< "$container_info"
}


# Function to collect Docker container status (number of running/stopped containers)
collect_container_status() {
    running_containers=$(docker ps -q | wc -l)
    total_containers=$(docker ps -a -q | wc -l)
    stopped_containers=$((total_containers - running_containers))

    # Format the fields for InfluxDB
    fields="running_containers=$running_containers,stopped_containers=$stopped_containers,total_containers=$total_containers"
    echo "Docker container status: $fields"

    # Push container status to InfluxDB
    push_to_influxdb "$INFLUXDB_MEASUREMENT_CONTAINER_STATUS" "$fields"
}

# Track the number of deployments and failures
collect_container_deployment_status() {
    # successful_deployments=0
    # failed_deployments=0

    # Monitor Docker events
    docker events --filter 'event=start' --filter 'event=die' |
    while read event; do
        if echo "$event" | grep "start"; then
            ((successful_deployments++))
            echo "Successful deployments: $successful_deployments"
            push_to_influxdb "$INFLUXDB_MEASUREMENT_DOCKER_DEPLOYMENT_COUNT" "count=1" # Push to InfluxDB each time a container starts
        elif echo "$event" | grep "die"; then
            ((failed_deployments++))
            echo "Failed deployments: $failed_deployments"
        fi
    done

    # Format the fields for InfluxDB
    fields="successful_deployments=$successful_deployments,failed_deployments=$failed_deployments"
    echo "Docker container deployment status: $fields"

    # Push container status to InfluxDB
    push_to_influxdb "$INFLUXDB_MEASUREMENT_DEPLOYMENT_STATUS" "$fields"
}

# Count pass and fail statuses based on exit codes
docker_container_exit_status()
{
    pass_count=0
    fail_count=0

    # Get the list of containers
    container_ids=$(docker ps -a -q)

    # Loop through containers to check their exit codes
    for container_id in $container_ids; do
        exit_code=$(docker inspect $container_id --format='{{.State.ExitCode}}')
        if [ "$exit_code" -eq 0 ]; then
            ((pass_count++))
        else
            ((fail_count++))
        fi
    done

    # Format the fields for InfluxDB
    fields="pass_count=$pass_count,fail_count=$fail_count"
    echo "Docker container exit status: $fields"

    # Push container status to InfluxDB
    push_to_influxdb "$INFLUXDB_MEASUREMENT_EXIT_STATUS" "$fields"
}

# Run functions in a loop
while true; do
    collect_docker_metrics
    collect_container_status
    collect_container_deployment_status
    docker_container_exit_status

    sleep 1
done
