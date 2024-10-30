#!/bin/bash

# Function to display help information
function help() {
    echo "Usage: spark_cluster.sh [command] [options]"
    echo "Commands:"
    echo "    deploy [--no-jupyter] [--scale=<worker>] [--mem=<memory>] [--cores=<cores>]  Deploy the Spark cluster"
    echo "    stop                   Stop the Spark cluster"
    echo "    status                 Check Spark cluster status"
    echo "    run <file>             Run a Spark job from a specified file"
    echo "Options:"
    echo "    --no-jupyter           Disable Jupyter notebook deployment"
    echo "    --scale=<worker>       Number of Spark worker replicas (default: 1)"
    echo "    --mem=<memory>         Set Spark worker memory (default: 1G)"
    echo "    --cores=<cores>        Set Spark worker cores (default: 1)"
    exit 1
}

# Default configurations
JUPYTER_ENABLED=true
SPARK_WORKER_MEMORY="1"
SPARK_WORKER_CORES="1"
WORKER_COUNT=1

# Check if at least one argument is provided
if [ -z "$1" ]; then
    echo "❌ No command provided."
    help
fi

# Parse the command
command="$1"
shift

# Parse options
while [ ! -z "$1" ]; do
    case "$1" in
        --no-jupyter)
            JUPYTER_ENABLED=false
            shift
            ;;
        --scale=*)
            WORKER_COUNT="${1#*=}"  # Extract the worker count after "="
            shift
            ;;
        --mem=*)
            SPARK_WORKER_MEMORY="${1#*=}"  # Extract memory size after "="
            shift
            ;;
        --cores=*)
            SPARK_WORKER_CORES="${1#*=}"  # Extract cores count after "="
            shift
            ;;
        *)
            echo "Invalid option: $1"
            help
            ;;
    esac
done

# Function to deploy the Spark cluster
function deploy() {
    echo "Deploying the Spark cluster..."

    # Creating volume
    docker volume create spark-events

    # Give access to the volume to all users
    docker run --rm -v spark-events:/mnt busybox sh -c "chmod -R 777 /mnt"

    # Add env variables
    export SPARK_WORKER_MEMORY
    export SPARK_WORKER_CORES
    
    # Set WITH_JUPYTER based on JUPYTER_ENABLED
    if [ "$JUPYTER_ENABLED" = true ]; then
        echo "Jupyter notebook will be enabled."
        export WITH_JUPYTER=1
    else
        echo "Jupyter notebook will be disabled."
        export WITH_JUPYTER=0
    fi

    docker-compose up -d --scale spark-worker="$WORKER_COUNT"

    if [ $? -ne 0 ]; then
        echo "❌ Failed to deploy the Spark cluster."
        exit 1
    fi
    echo "✅ Spark cluster successfully deployed!"
}

# Function to stop the Spark cluster
function stop() {
    echo "Stopping the Spark cluster..."
    docker-compose down
    if [ $? -ne 0 ]; then
        echo "❌ Failed to stop the Spark cluster."
        exit 1
    fi
    echo "✅ Spark cluster successfully stopped!"
}

# Function to check the status of the Spark cluster
function status() {
    echo "Checking Spark cluster status..."
    docker-compose ps
}

# Function to run a Spark job
function run() {
    if [ -z "$1" ]; then
        echo "No file specified to run."
        help
    fi

    fileName="$1"
    filePath="./src/$fileName"

    echo "Running Spark job from file: $fileName"
    docker exec -it spark-cluster-spark-master-1 spark-submit "$filePath"

    if [ $? -ne 0 ]; then
        echo "❌ Failed to execute Spark job: $fileName"
        exit 1
    fi
    echo "✅ Successfully executed Spark job: $fileName"
}

# Execute the specified command
case "$command" in
    deploy)
        deploy
        ;;
    stop)
        stop
        ;;
    status)
        status
        ;;
    run)
        run "$@"
        ;;
    *)
        echo "Invalid command: $command"
        help
        ;;
esac
