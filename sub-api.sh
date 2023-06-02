#!/bin/bash

# Get subdomains from RapidDNS.io
curl -s "https://rapiddns.io/subdomain/$1?full=1#result" | grep "<td><a" | cut -d '"' -f 2 | grep http | cut -d '/' -f3 | sed 's/#results//g' | sort -u > "$2"

# Get subdomains from BufferOver.run
curl -s "https://dns.bufferover.run/dns?q=.$1" | jq -r .FDNS_A[] | cut -d',' -f2 | sort -u >> "$2"

# Get subdomains from Riddler.io
curl -s "https://riddler.io/search/exportcsv?q=pld:$1" | grep -Po "(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | sort -u >> "$2"

# Get subdomains from VirusTotal
curl -s "https://www.virustotal.com/ui/domains/$1/subdomains?limit=40" | grep -Po "((http|https):\/\/)?(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | sort -u >> "$2"

# Get subdomains with cyberxplore
curl "https://subbuster.cyberxplore.com/api/find?domain=$1" -s | grep -Po "(([\w.-]*)\.([\w]*)\.([A-z]))\w+" >> "$2"

# Get subdomains from CertSpotter
certspotter_output=$(curl -s "https://certspotter.com/api/v1/issuances?domain=$1&include_subdomains=true&expand=dns_names")
if [[ $certspotter_output == *"dns_names"* ]]; then
    echo "$certspotter_output" | jq .[].dns_names | grep -Po "(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | sort -u >> "$2"
fi

# Get subdomains from Archive
curl -s "http://web.archive.org/cdx/search/cdx?url=*.$1/*&output=text&fl=original&collapse=urlkey" | sed -e 's_https*://__' -e "s/\/.*//" | sort -u >> "$2"

# Get subdomains from JLDC
curl -s "https://jldc.me/anubis/subdomains/$1" | grep -Po "((http|https):\/\/)?(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | sort -u >> "$2"

# Get subdomains from securitytrails
curl -s "https://securitytrails.com/list/apex_domain/$1" | grep -Po "((http|https):\/\/)?(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | grep ".$1" | sort -u >> "$2"

# Get subdomains with sonar.omnisint.io
curl --silent "https://sonar.omnisint.io/subdomains/$1" | grep -oE "[a-zA-Z0-9._-]+.$1" | sort -u >> "$2"

# Get subdomains with synapsint.com
curl --silent -X POST "https://synapsint.com/report.php" -d "name=https%3A%2F%2F$1" | grep -oE "[a-zA-Z0-9._-]+.$1" | sort -u >> "$2"

# Get subdomains from crt.sh
curl -s "https://crt.sh/?q=%25.$1&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u >> "$2"

# Sort & tested domains from Recon.dev
curl "https://recon.dev/api/search?key=apikey&domain=$1" | jq -r '.[].rawDomains[]' | sed 's/ //g' | sort -u >> "$2"
