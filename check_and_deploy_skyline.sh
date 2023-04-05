#!/bin/bash

# Loads Check Point environment variables
source /etc/profile.d/CP.sh

# Checks if the correct arguments were provided
if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <path_to_json_file> <write_endpoint>"
  exit 1
fi

# Path of the JSON file
json_file="$1"

# IP to replace in JSON file
write_endpoint="$2"

# Replace URL in JSON file
sed "s/<PROMETHEUS_WRITE_ENDPOINT>/$write_endpoint/g" $json_file > /tmp/payload-no-tls.json


# Verify operating system version
os_version=$(cat /etc/*release* | awk '{print $4}' | uniq)

# Function to check the Jumbo Hotfix version and execute the necessary actions
check_jumbo_take() {
  local min_take=$1
  local json_file=$2
  jumbo_take=$(cpinfo -y all 2>/dev/null|grep HF_MAIN|grep -v _SC|tail -n1|awk '{print $NF}')
  if [[ $jumbo_take -ge $min_take ]]; then
    #cp "$json_file" /tmp/
    response=$(/opt/CPotelcol/REST.py --set_open_telemetry "$(cat /tmp/payload-no-tls.json)")
    wait_msg='{"message": "Operation has finished successfully"}'
	sleep 15	
    while true; do
      if [[ "$response" == *"$wait_msg"* ]]; then
        echo "Skyline has been successfully deployed"
        break
      fi
      sleep 1
    done
  else
    echo "Unsupported version of Check Point OS"
  fi
}

# Checks the cumulative jumbo hotfix version and calls the function if it is greater than or equal to a specific value
echo "Starting checks..........."
case $os_version in
  "R80.40")
    min_take="190"
	jumbo_take=$(cpinfo -y all 2>/dev/null|grep HF_MAIN|grep -v _SC|tail -n1|awk '{print $NF}')
	echo "Your version is $os_version and you have the JHF $jumbo_take, please wait ..."
    check_jumbo_take $min_take $json_file
    ;;
  "R81")
    min_take="77"
	jumbo_take=$(cpinfo -y all 2>/dev/null|grep HF_MAIN|grep -v _SC|tail -n1|awk '{print $NF}')
	echo "Your version is $os_version and you have the JHF $jumbo_take, please wait ..."
    check_jumbo_take $min_take $json_file
    ;;
  "R81.10")
    min_take="79"
	jumbo_take=$(cpinfo -y all 2>/dev/null|grep HF_MAIN|grep -v _SC|tail -n1|awk '{print $NF}')
	echo "Your version is $os_version and you have the JHF $jumbo_take, please wait ..."
    check_jumbo_take $min_take $json_file
    ;;
  "R81.20")
    min_take="8"
	jumbo_take=$(cpinfo -y all 2>/dev/null|grep HF_MAIN|grep -v _SC|tail -n1|awk '{print $NF}')
	echo "Your version is $os_version and you have the JHF $jumbo_take, please wait ..."
    check_jumbo_take $min_take $json_file
    ;;  
  *)
    echo "Unsupported version of Check Point OS"
    exit 1
    ;;
esac