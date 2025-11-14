#!/bin/sh

# Script to collect pod descriptions and logs for one or all namespaces
# Organized into a timestamped main folder with per-namespace subfolders

print_help() {
    echo "Usage: $0 [OPTIONS] [NAMESPACE...]"
    echo
    echo "Collects pod descriptions and logs for some or all namespaces."
    echo "Data is saved in a timestamped main folder with per-namespace subfolders."
    echo
    echo "Options:"
    echo "  -h, --help          Show this help message and exit."
    echo "  [NAMESPACE]         Specify one or more namespaces, separated by space, to collect data from."
    echo "                      If no namespaces are specified, data for all namespaces is gathered."
    echo
    exit 0
}

# Check for help options first
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    print_help
fi

# set -u after option -h/--help in case of $1 is missing
set -eu

# Generate main timestamped folder
main_folder="pod_details_$(date +"%Y%m%d_%H%M%S")"
mkdir -p "$main_folder"

# Determine target namespaces
# If no argument provided: loop on all namespaces
if [ "$#" -eq 0 ]; then
    echo "No namespace provided. Gathering data for all namespaces..."
    namespaces=$(kubectl get ns --no-headers | awk '{print $1}')
else
    # If one or more namespace(s) is/are provided, use it/them
    namespaces="$@"
    echo "Namespaces provided. Gathering data only for namespaces: $namespaces"
fi

# Loop over each namespace
for ns in $namespaces; do
    echo "Checking namespace: $ns"

    # Get pods in the namespace
    pod_list=$(kubectl get pod -n "$ns" --no-headers 2>/dev/null | awk '{print $1}')

    # Skip if no pods found
    if [ -z "$pod_list" ]; then
        echo "  No pods found in namespace: $ns — skipping."
        continue
    fi

    echo "  Pods found in namespace: $ns — collecting logs."

    # Create subfolder for the namespace
    ns_folder="${main_folder}/${ns}"
    mkdir -p "$ns_folder"

    # Save pod list to file and extract pod names
    kubectl get pod -o wide -n "$ns" > "$ns_folder/pods.txt"

    # Loop through pods
    for pod in $pod_list; do
        (
            echo "    Processing pod: $pod"
            kubectl describe pod "$pod" -n "$ns" > "$ns_folder/${pod}_describe.txt"

            log_file="$ns_folder/${pod}_logs.log"
            # remove ANSI color, replace \n with new lines and  and \t with tabs
            kubectl logs "$pod" -n "$ns" --all-containers=true 2>/dev/null \
                | sed 's/\x1b\[[0-9;]*m//g' | sed 's/\\n/\n/g' | sed 's/\\t/\t/g' > "$log_file"

            # Remove the file if it's empty
            if [ ! -s "$log_file" ]; then
                echo "    No logs for pod: $pod"
                rm -f "$log_file"
            fi
        ) &
    done
    wait

    echo "  Finished namespace: $ns"
done

echo "All available pod details and logs saved in: $main_folder"
