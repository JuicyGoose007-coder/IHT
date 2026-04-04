#!/bin/bash
USAGE=$(timeout 3 nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null)
if [ -z "$USAGE" ]; then
    echo '{"text": "󰢮 N/A", "tooltip": "GPU: unavailable"}'
else
    echo "{\"text\": \"󰢮 ${USAGE}%\", \"tooltip\": \"GPU: ${USAGE}%\"}"
fi
