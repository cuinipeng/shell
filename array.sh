#!/bin/bash

ip_array=("192.168.1.1" "192.168.1.2" "192.168.1.3")

for ip in ${ip_array[*]}; do
    echo ${ip}
done
