#!/bin/bash
# MishMask: A script for hiding phishing URLs (formerly known as MaskPhish)
# Created by KP, improved by ChatGPT

# Function to show help message
show_help() {
    echo -e "\nUsage: MishMask [options]"
    echo -e "\nOptions:"
    echo -e "  -h, --help            Show this help message."
    echo -e "  -v, --verbose         Enable verbose mode for detailed output."
    echo -e "  -l, --log <file>      Log the generated URLs to a specified file."
    echo -e "  -p, --password <pass> Set a password to run the script."
    echo -e "  -f, --file <file>     Provide a file with phishing URLs for batch processing."
    echo -e "  -d, --domain <domain> Provide a custom domain for masking."
    echo -e "  -s, --shorten <service> Specify a URL shortening service (is.gd, bit.ly, etc.)."
    echo -e "\nExample usage: ./MishMask.sh -f urls.txt -l output.txt"
}

# Function to check if the URL starts with http or https
url_checker() {
    local url=$1
    if [[ ! "$url" =~ ^https?:// ]]; then
        echo -e "\e[31m[!] Invalid URL format. Please use http or https.\e[0m"
        exit 1
    fi
}

# Function to URL-encode the input string
url_encode() {
    local input=$1
    # Using jq to encode special characters to be URL-safe
    echo -n "$input" | jq -sRr @uri
}

# Function to check if the shortened URL already exists
check_existing_url() {
    local url=$1
    # Check if the URL shortening service returns the same URL
    local existing_url=$(curl -s https://is.gd/create.php?format=simple\&url="$url")
    if [ "$existing_url" == "$url" ]; then
        echo -e "\e[31m[!] The URL has already been shortened.\e[0m"
        exit 1
    fi
}

# Function to create the necessary directories and files
create_mish_dir() {
    # Ensure the mish directory exists
    if [ ! -d "./mish" ]; then
        echo -e "\e[32m[+] Creating 'mish' directory to store files...\e[0m"
        mkdir -p ./mish
    fi
}

# Function to validate log file existence
validate_log_file() {
    local log_file=$1
    if [ -e "$log_file" ]; then
        if [ ! -w "$log_file" ]; then
            echo -e "\e[31m[!] Log file '$log_file' is not writable.\e[0m"
            exit 1
        fi
    else
        touch "$log_file" || { echo -e "\e[31m[!] Failed to create log file '$log_file'.\e[0m"; exit 1; }
    fi
}

# Function to validate input file
validate_input_file() {
    local file=$1
    if [ ! -f "$file" ]; then
        echo -e "\e[31m[!] Input file '$file' not found.\e[0m"
        exit 1
    fi
    if [ ! -r "$file" ]; then
        echo -e "\e[31m[!] Input file '$file' is not readable.\e[0m"
        exit 1
    fi
}

# Function to log URLs into the log file
log_to_file() {
    local log_message=$1
    local log_file=$2
    echo "$log_message" >> "$log_file"
}

# Function to process URLs from a file
process_file() {
    local file=$1
    while IFS= read -r phish_url; do
        # For each URL in the file, process the URL (rest of logic follows)
        echo -e "\nProcessing Phishing URL: $phish_url"
        # Add URL processing logic here
    done < "$file"
}

# Main script starts here

# Default variables
verbose=false
log_file="./mish/mishmask_log.txt"
password_required=false
password=""
file_input=""
shorten_service="is.gd"
mask_domain=""
encoded_words=""

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h|--help) show_help; exit 0 ;;
        -v|--verbose) verbose=true ;;
        -l|--log) log_file="$2"; shift ;;
        -p|--password) password_required=true; password="$2"; shift ;;
        -f|--file) file_input="$2"; shift ;;
        -d|--domain) mask_domain="$2"; shift ;;
        -s|--shorten) shorten_service="$2"; shift ;;
        *) echo -e "\e[31m[!] Invalid option '$1'. Use '--help' for usage.\e[0m"; show_help; exit 1 ;;
    esac
    shift
done

# Show password prompt if password protection is enabled
if [[ "$password_required" == true ]]; then
    echo -n "Enter password: "
    read -s input_password
    echo
    if [[ "$input_password" != "$password" ]]; then
        echo -e "\e[31m[!] Incorrect password.\e[0m"
        exit 1
    fi
fi

# Create the mish directory and validate files
create_mish_dir

# Validate log file
validate_log_file "$log_file"

# Process file if provided
if [[ -n "$file_input" ]]; then
    validate_input_file "$file_input"
    process_file "$file_input"
    exit 0
fi

# Main interactive mode if no file is provided
echo -e "\n\e[1;31;42m######┌──────────────────────────┐##### \e[0m"
echo -e "\e[1;31;42m######│▙▗▌      ▌  ▛▀▖▌  ▗    ▌  │##### \e[0m"
echo -e "\e[1;31;42m######│▌▘▌▝▀▖▞▀▘▌▗▘▙▄▘▛▀▖▄ ▞▀▘▛▀▖│##### \e[0m"
echo -e "\e[1;31;42m######│▌ ▌▞▀▌▝▀▖▛▚ ▌  ▌ ▌▐ ▝▀▖▌ ▌│##### \e[0m"
echo -e "\e[1;31;42m######│▘ ▘▝▀▘▀▀ ▘ ▘▘  ▘ ▘▀▘▀▀ ▘ ▘│##### \e[0m"
echo -e "\e[1;31;42m######└──────────────────────────┘##### \e[0m \n"
echo -e "\e[40;38;5;82m Please Visit \e[30;48;5;82m https://www.kalilinux.in \e[0m"
echo -e "\e[30;48;5;82m    Copyright \e[40;38;5;82m   JayKali \e[0m \n\n"
echo -e "\e[1;31;42m ### MishMask ###\e[0m \n"

# Prompt for phishing URL and validate
echo -n "Paste Phishing URL here (with http or https): "
read phish
url_checker "$phish"
sleep 1

# Shorten URL using is.gd or user-defined shortening service
if [[ "$shorten_service" == "bit.ly" ]]; then
    # Example of Bitly API (authentication needed for Bitly)
    short=$(curl -s -X POST -H "Content-Type: application/json" -d '{"long_url": "'"$phish"'"}' https://api-ssl.bitly.com/v4/shorten | jq -r .link)
else
    short=$(curl -s https://is.gd/create.php?format=simple\&url="$phish")
fi

# Check if the shortened URL is valid
check_existing_url "$short"
shorter=${short#https://}

# Prompt for masking domain input
echo -e "\n\e[1;31;42m ### Masking Domain ###\e[0m"
echo 'Domain to mask the Phishing URL (with http or https), e.g., https://google.com:'
echo -en "\e[32m=>\e[0m "
read mask
url_checker "$mask"

# Social engineering words input
echo -e '\nType social engineering words (like free-money, best-pubg-tricks)'
echo -e "\e[31mDon't use space; use '-' between words.\e[0m"
echo -en "\e[32m=>\e[0m "
read words

# Encode social engineering words
encoded_words=$(url_encode "$words")
if [[ -z "$words" ]]; then
    echo -e "\e[31m[!] No words provided.\e[0m"
    final="$mask@$shorter"
    log_to_file "Generated MishMask URL: $final" "$log_file"
    echo -e "Here is the MishMask URL:\e[32m ${final} \e[0m\n"
    exit
fi

# Generate the final MishMask link
echo -e "\nGenerating MishMask Link...\n"
final="$mask-$encoded_words@$shorter"
log_to_file "Generated MishMask URL: $final" "$log_file"
echo -e "Here is the MishMask URL:\e[32m ${final} \e[0m\n"
