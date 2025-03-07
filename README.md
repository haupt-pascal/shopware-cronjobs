# Shopware Cronjobs

A collection of useful cronjob scripts for Shopware 5 and 6.

## Setup

1. Clone this repository:
   ```
   git clone https://github.com/haupt-pascal/shopware-cronjobs.git
   cd shopware-cronjobs
   ```

2. Run the setup script:
   ```
   chmod +x setup.sh
   ./setup.sh
   ```

3. Follow the prompts to:
   - Configure your PHP path
   - Specify your Shopware installation path
   - Select which cronjobs to install

4. Add the generated crontab entries to your system's crontab.

## Available Cronjobs

### Cache Clear and Warm

These scripts help you maintain optimal performance by regularly clearing and warming up the Shopware cache.

The scripts will be installed in a `cronjob/` directory within your Shopware installation:
- `cronjob/cache_clear.sh` - Clears the Shopware cache
- `cronjob/cache_warm.sh` - Warms up the Shopware cache

Example output:
```
Starting cache clear at Tue Jun 4 14:30:00 CEST 2023
Cache cleared successfully.
Cache clear completed at Tue Jun 4 14:30:05 CEST 2023
```

## How it Works

The setup script automatically:
1. Detects your Shopware version (5 or 6)
2. Creates appropriate shell scripts using your PHP path
3. Sets the correct cache commands based on your Shopware version
4. Generates example crontab entries with logging

You can find template versions of these scripts in the `templates/` directory.

## Compatibility

The scripts automatically detect whether you're using Shopware 5 or Shopware 6 and adjust the commands accordingly:

- **Shopware 6:**
  - Cache clear: `cache:clear --env=prod`
  - Cache warm: `http:cache:warm --env=prod`

- **Shopware 5:**
  - Cache clear: `sw:cache:clear`
  - Cache warm: `sw:warm:http:cache`

## Contributing

Feel free to contribute by adding more useful cronjobs or improving existing ones!

## License

MIT
