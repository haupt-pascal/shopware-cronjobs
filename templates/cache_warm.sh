#!/bin/bash

# Shopware Cache Warm Script
# This is a template file. The actual script will be generated by setup.sh
# with the correct PHP path and Shopware version-specific command.

cd "${SHOPWARE_PATH}"

echo "Starting cache warming at $(date)"

${PHP_PATH} bin/console ${CACHE_WARM_COMMAND}

RESULT=$?
if [ $RESULT -eq 0 ]; then
    echo "Cache Warm completed successfully."
else
    echo "Error: Cache Warm failed with exit code $RESULT"
fi

echo "Cache Warm completed at $(date)"
