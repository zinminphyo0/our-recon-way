#!/bin/bash

subdomains_file=$1

# Get the current directory
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Change to the script directory
cd "$script_dir"

# Create the output directory if it doesn't exist
mkdir -p output

# Loop through each subdomain in the file
while IFS= read -r subdomain; do
    # Crawl subdomains using ParamSpider
    python3 "$HOME/ParamSpider/paramspider.py" --domain "$subdomain" --exclude "jpg,jpeg,png,gif,svg,css,ico,pdf,js,woff,ttf,eot,svg,woff2" -o "output/$subdomain-output.txt"

    # Extract parameters from crawled URLs
    cat "output/$subdomain-output.txt" | grep -oE '(\?|&)([^=]+)=' | cut -d'=' -f1 | sort -u > "output/$subdomain-params.txt"
done < "$subdomains_file"

## chmod +x param-spider.sh
## ./param-spider.sh
