#!/bin/bash

# Get token
output=$(jupyter server list)
urlport="dsmlp-login.ucsd.edu:13075"
token=$(echo "$output" | awk -F'\\?token=' '{print $2}' | awk '{print $1}')

if [ ${#token} -lt 4 ]; then
    echo "Your Jupyter notebook does not seem to be active."
    echo "If you're running on Datahub, please try adding -j to the launch script args."
else
    # Output
    echo "Your Jupyter Notebook is accessible at ${urlport}/user/${USER}/?token=${token}"    
fi

