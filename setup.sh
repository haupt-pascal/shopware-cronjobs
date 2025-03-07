#!/bin/bash

echo "========================================"
echo "Shopware Cronjobs Setup"
echo "========================================"

# Function to create directories if they don't exist
create_directories() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        echo "Created directory: $1"
    fi
}

# Create local structure
create_directories "templates"
create_directories "config"

# Ask for Shopware version
echo "Which Shopware version are you using?"
select SW_VERSION in "Shopware 5" "Shopware 6"; do
    case $SW_VERSION in
        "Shopware 5")
            SHOPWARE_VERSION=5
            CACHE_CLEAR_COMMAND="sw:cache:clear"
            CACHE_WARM_COMMAND="sw:cache:warm"
            break
            ;;
        "Shopware 6")
            SHOPWARE_VERSION=6
            CACHE_CLEAR_COMMAND="cache:clear --env=prod"
            CACHE_WARM_COMMAND="cache:warmup --env=prod"
            break
            ;;
        *) echo "Invalid option. Please select 1 or 2.";;
    esac
done

echo "Selected Shopware $SHOPWARE_VERSION"

# Ask for PHP path
read -p "Enter the path to your PHP executable (e.g., /usr/local/php8.2/bin/php): " PHP_PATH

# Validate PHP path
if [ ! -f "$PHP_PATH" ]; then
    echo "Error: PHP executable not found at $PHP_PATH"
    exit 1
fi

# Verify PHP version
PHP_VERSION=$("$PHP_PATH" -r 'echo PHP_VERSION;')
echo "PHP version detected: $PHP_VERSION"

# Save PHP path and Shopware version to config file
echo "PHP_PATH=$PHP_PATH" > config/settings.conf
echo "SHOPWARE_VERSION=$SHOPWARE_VERSION" >> config/settings.conf
echo "Configuration saved to config/settings.conf"

# Ask for Shopware installation path
read -p "Enter the path to your Shopware installation: " SHOPWARE_PATH

# Validate Shopware path
if [ ! -d "$SHOPWARE_PATH" ]; then
    echo "Error: Directory not found at $SHOPWARE_PATH"
    exit 1
fi

# Create cronjob directory
CRONJOB_DIR="$SHOPWARE_PATH/cronjob"
create_directories "$CRONJOB_DIR"
echo "Set up cronjob directory at $CRONJOB_DIR"

# Save Shopware path to config
echo "SHOPWARE_PATH=$SHOPWARE_PATH" >> config/settings.conf
echo "CRONJOB_DIR=$CRONJOB_DIR" >> config/settings.conf

# Available cronjobs array
declare -A AVAILABLE_CRONJOBS
AVAILABLE_CRONJOBS[1]="Cache Clear"
AVAILABLE_CRONJOBS[2]="Cache Warm"
# Add more cronjobs as needed
# AVAILABLE_CRONJOBS[3]="Database Backup"
# AVAILABLE_CRONJOBS[4]="Sitemap Generation"

# Display available cronjobs
echo ""
echo "Available cronjobs:"
for i in "${!AVAILABLE_CRONJOBS[@]}"; do
    echo "$i. ${AVAILABLE_CRONJOBS[$i]}"
done
echo ""

read -p "Enter the number(s) of the cronjobs you want to install (e.g., 1,2 or 1,2,3): " SELECTED_JOBS

# Function to create a script file
create_script() {
    local script_path=$1
    local script_name=$2
    local script_description=$3
    local command=$4
    
    echo "#!/bin/bash" > "$script_path"
    echo "" >> "$script_path"
    echo "# Shopware $script_name Script" >> "$script_path"
    echo "# Created on: $(date)" >> "$script_path"
    echo "# Shopware version: $SHOPWARE_VERSION" >> "$script_path"
    echo "" >> "$script_path"
    echo "# Change to the Shopware directory" >> "$script_path"
    echo "cd \"$SHOPWARE_PATH\"" >> "$script_path"
    echo "" >> "$script_path"
    echo "echo \"Starting $script_description at \$(date)\"" >> "$script_path"
    echo "" >> "$script_path"
    echo "$PHP_PATH bin/console $command" >> "$script_path"
    echo "" >> "$script_path"
    echo "RESULT=\$?" >> "$script_path"
    echo "if [ \$RESULT -eq 0 ]; then" >> "$script_path"
    echo "    echo \"$script_name completed successfully.\"" >> "$script_path"
    echo "else" >> "$script_path"
    echo "    echo \"Error: $script_name failed with exit code \$RESULT\"" >> "$script_path"
    echo "fi" >> "$script_path"
    echo "" >> "$script_path"
    echo "echo \"$script_name completed at \$(date)\"" >> "$script_path"
    
    chmod +x "$script_path"
    echo "Created $script_name script: $script_path"
}

# Create an array to store the installed scripts
declare -a INSTALLED_SCRIPTS

# Process selected jobs
if [[ $SELECTED_JOBS == *"1"* ]]; then
    echo "Installing Cache Clear cronjob..."
    
    # Create cache clear script
    CACHE_CLEAR="$CRONJOB_DIR/cache_clear.sh"
    create_script "$CACHE_CLEAR" "Cache Clear" "cache clearing" "$CACHE_CLEAR_COMMAND"
    
    INSTALLED_SCRIPTS+=("$CACHE_CLEAR")
fi

if [[ $SELECTED_JOBS == *"2"* ]]; then
    echo "Installing Cache Warm cronjob..."
    
    # Create cache warm script
    CACHE_WARM="$CRONJOB_DIR/cache_warm.sh"
    create_script "$CACHE_WARM" "Cache Warm" "cache warming" "$CACHE_WARM_COMMAND"
    
    INSTALLED_SCRIPTS+=("$CACHE_WARM")
fi

# Create example crontab entry if any scripts were installed
if [ ${#INSTALLED_SCRIPTS[@]} -gt 0 ]; then
    CRONTAB_FILE="$CRONJOB_DIR/crontab_examples.txt"
    echo "# Add these to your crontab (crontab -e):" > "$CRONTAB_FILE"
    
    # Add entries for each installed script
    if [[ $SELECTED_JOBS == *"1"* ]]; then
        echo "# Clear cache every night at 3 AM" >> "$CRONTAB_FILE"
        echo "0 3 * * * $CACHE_CLEAR > $CRONJOB_DIR/cache_clear_log.txt 2>&1" >> "$CRONTAB_FILE"
    fi
    
    if [[ $SELECTED_JOBS == *"2"* ]]; then
        echo "# Warm cache 5 minutes after clearing" >> "$CRONTAB_FILE"
        echo "5 3 * * * $CACHE_WARM > $CRONJOB_DIR/cache_warm_log.txt 2>&1" >> "$CRONTAB_FILE"
    fi
    
    echo "Example crontab entries written to $CRONTAB_FILE"
fi

# Additional cronjobs can be added here in the future

echo ""
echo "Setup completed!"
echo "Scripts are installed in $CRONJOB_DIR"
echo ""
echo "Installed scripts:"

# Print the paths to all installed scripts
for script in "${INSTALLED_SCRIPTS[@]}"; do
    echo "- $script"
done

echo "========================================"
echo ""
echo "To add these scripts to your crontab:"
echo "1. Run 'crontab -e'"
echo "2. Add the following lines (adjust times as needed):"

# Print example crontab entries directly to console
if [[ $SELECTED_JOBS == *"1"* ]]; then
    echo "0 3 * * * $CACHE_CLEAR > $CRONJOB_DIR/cache_clear_log.txt 2>&1"
fi

if [[ $SELECTED_JOBS == *"2"* ]]; then
    echo "5 3 * * * $CACHE_WARM > $CRONJOB_DIR/cache_warm_log.txt 2>&1"
fi
echo ""
echo "========================================"

echo "If you are using a UI to set up cronjobs, you can use the following script paths:"
for script in "${INSTALLED_SCRIPTS[@]}"; do
    echo "- $script"
done
echo ""
echo "========================================"
echo "Thank you for using the Shopware Cronjobs Setup script!"