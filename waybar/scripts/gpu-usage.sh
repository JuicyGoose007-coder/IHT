#!/bin/bash
USAGE=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null)
echo "{\"text\": \"󰢮 ${USAGE}%\", \"tooltip\": \"GPU: ${USAGE}%\"}"
