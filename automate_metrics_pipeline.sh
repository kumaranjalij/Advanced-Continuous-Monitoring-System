#!/bin/bash

GRAFANA_USER="admin"
GRAFANA_PASS="Anjali@2000"
GRAFANA_URL="http://localhost:3000"
DASHBOARD_UID="fe0vwe709ahhca" # Replace this with your actual Grafana dashboard UID

# Function to install required software (InfluxDB, Grafana, sar)
install_requirements() {
    echo "Installing necessary packages..."

    # # Install InfluxDB
    # if ! command -v influx >/dev/null 2>&1; then
    #     echo "InfluxDB is not installed. Installing InfluxDB..."
    #     sudo apt-get update && sudo apt-get install -y influxdb
    #     sudo systemctl enable influxdb
    #     sudo systemctl start influxdb
    # else
    #     echo "InfluxDB is already installed."
    # fi

    # # Install Grafana
    # if ! command -v grafana-server >/dev/null 2>&1; then
    #     echo "Grafana is not installed. Installing Grafana..."
    #     sudo apt-get install -y software-properties-common
    #     sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
    #     sudo apt-get update && sudo apt-get install -y grafana
    #     sudo systemctl enable grafana-server
    #     sudo systemctl start grafana-server
    # else
    #     echo "Grafana is already installed."
    # fi

    # # Install sysstat(which contains sar)
    # if ! command -v sar >/dev/null 2>&1; then
    #     echo "sar is not installed. Installing sysstat..."
    #     sudo apt-get install -y sysstat 
    # else
    #     echo "sar is already installed."
    # fi

    # # Install curl
    # if ! command -v curl >/dev/null 2>&1; then
    #     echo "curl is not installed. Installing curl..."
    #     sudo apt-get install -y curl 
    # else
    #     echo "curl is already installed."
    # fi

    # echo "All necessary packages are installed."
}

# Function to start InfluxDB and Grafana
start_servers() {
    echo "Starting InfluxDB and Grafana servers..."

    # Start InfluxDB
    sudo systemctl start influxdb

    # Start Grafana
    sudo systemctl start grafana-server

    # Check if Grafana server started successfully
    if ! systemctl is-active --quiet grafana-server; then
        echo "Error: Grafana server failed to start."
        exit 1
    fi

    echo "InfluxDB and Grafana servers started."
}

# Function to run metric collection scripts
run_metric_scripts() {
    echo "Running metric collection scripts..."

    # Run the metric collection scripts in the background and capture their PIDs
    ./Collect_Metrics/collect_cpu.sh &
    cpu_pid=$!

    # Error handling for the metric collection scripts
    if ! kill -0 $cpu_pid 2>/dev/null; then
        echo "Error: CPU data collection script failed to start."
        exit 1
    fi
    
    ./Collect_Metrics/collect_cpu_corewise.sh &
    cpu_core_pid=$!

    if ! kill -0 $cpu_core_pid 2>/dev/null; then
        echo "Error: CPU corewise data collection script failed to start."
        exit 1
    fi
    
    ./Collect_Metrics/collect_io.sh &
    io_pid=$!

    if ! kill -0 $io_pid 2>/dev/null; then
        echo "Error: IO stats collection script failed to start."
        exit 1
    fi
    
    ./Collect_Metrics/collect_memory.sh &
    memory_pid=$!

    if ! kill -0 $memory_pid 2>/dev/null; then
        echo "Error: Memory Usage collection script failed to start."
        exit 1
    fi
    
    ./Collect_Metrics/collect_network.sh &
    network_pid=$!

    if ! kill -0 $network_pid 2>/dev/null; then
        echo "Error: Network stats collection script failed to start."
        exit 1
    fi

    ./Collect_Metrics/collect_docker.sh &
    docker_pid=$!

    if ! kill -0 $docker_pid 2>/dev/null; then
        echo "Error: Docker metrics collection script failed to start."
        exit 1
    fi

    echo "Metric collection scripts are running."

    # Trap SIGINT and SIGTERM to stop scripts gracefully
    # trap "stop_metric_scripts" SIGINT SIGTERM
}

# # Function to stop the metric collection scripts gracefully
stop_metric_scripts() {
    echo "Stopping metric collection scripts..."

    kill $cpu_pid $cpu_core_pid $io_pid $memory_pid $network_pid

    echo "Metric collection scripts stopped."
    exit 0
}

# Function to logIn to Grafana and display dashboards
open_grafana_dashboards() {
    echo "Logging into Grafana..."

    # Install necessary tools (if xdg-open is not available)
    if ! command -v xdg-open >/dev/null 2>&1; then
        sudo apt-get install -y xdg-utils
    fi

    # # Open the Grafana login page using the default browser
    # echo "Opening Grafana in your browser..."
    # xdg-open "$GRAFANA_URL/login"

    # # Automatically log in and redirect to the dashboard 
    # curl -X POST -H "Content-Type: application/json" \
    # -d '{"user":"admin", "password":"admin"}' \
    # http://localhost:3000/login


    #Logging into Grafana
    login_response=$(curl -s -X POST "$GRAFANA_URL/login" \
    -H "Content-Type: application/json" \
    -d "{\"user\": \"$GRAFANA_USER\", \"password\": \"$GRAFANA_PASS\"}")

    echo "Login Response: $login_response"

    # Error handling for login request
     # Parse JSON to check the message
    if [[ $login_response == *"\"message\":\"Logged in\""* ]]; then
        echo "Logged into Grafana successfully."
    else
        echo "Error: Unable to log into Grafana. Response: $login_response"
        exit 1
    fi

    # Automatically open the desired Grafana dashboard
    echo "Opening Grafana dashboard..."
    xdg-open "$GRAFANA_URL/d/$DASHBOARD_UID" || {
        echo "Error: Unable to open Grafana dashboard in browser."
        exit 1
    }

}

# Function to automate the entire process
run_pipeline() {
    install_requirements
    start_servers
    run_metric_scripts
    open_grafana_dashboards

    echo "Pipeline executing successfully.."

    # Trap Ctrl+C to stop the background processes
    trap stop_metric_scripts SIGINT SIGTERM

    # Wait for all background processes
    wait
}

# Ensure all background processes are killed on script exit (even on error)
trap stop_metric_scripts EXIT


# Run the pipeline
run_pipeline
