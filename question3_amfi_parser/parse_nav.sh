#!/bin/bash

################################################################################
# AMFI NAV Data Parser
# Author: Internship Assignment Solution
# Description: Extracts Scheme Name and Net Asset Value from AMFI NAV data
#              and saves them in TSV (Tab-Separated Values) format
################################################################################

# Configuration
URL="https://www.amfiindia.com/spages/NAVAll.txt"
OUTPUT_FILE="nav_output.tsv"
TEMP_FILE="nav_temp.txt"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

################################################################################
# Function: download_data
# Downloads the NAV data from AMFI website
################################################################################
download_data() {
    echo -e "${BLUE}Downloading AMFI NAV data...${NC}"
    
    # Use curl with error handling
    if command -v curl &> /dev/null; then
        curl -s -o "$TEMP_FILE" "$URL"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Download successful${NC}"
            return 0
        else
            echo -e "${RED}✗ Download failed${NC}"
            return 1
        fi
    # Fallback to wget if curl is not available
    elif command -v wget &> /dev/null; then
        wget -q -O "$TEMP_FILE" "$URL"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Download successful${NC}"
            return 0
        else
            echo -e "${RED}✗ Download failed${NC}"
            return 1
        fi
    else
        echo -e "${RED}Error: Neither curl nor wget is available${NC}"
        return 1
    fi
}

################################################################################
# Function: parse_nav_data
# Parses the downloaded data and extracts Scheme Name and NAV
################################################################################
parse_nav_data() {
    echo -e "${BLUE}Parsing NAV data...${NC}"
    
    # Create output file with header
    echo -e "Scheme Name\tNet Asset Value" > "$OUTPUT_FILE"
    
    # Parse the data
    # AMFI NAV file format:
    # - Lines with scheme data have semicolons (;) as delimiters
    # - Format: Scheme Code;ISIN Div Payout;ISIN Div Reinvestment;Scheme Name;Net Asset Value;Date
    # - We need columns 4 (Scheme Name) and 5 (Net Asset Value)
    
    awk -F';' '
        # Skip header lines and empty lines
        /^[0-9]/ {
            # Column 4 is Scheme Name, Column 5 is NAV
            scheme_name = $4
            nav = $5
            
            # Only process if both fields exist and NAV is not empty
            if (scheme_name != "" && nav != "") {
                # Remove leading/trailing whitespace
                gsub(/^[ \t]+|[ \t]+$/, "", scheme_name)
                gsub(/^[ \t]+|[ \t]+$/, "", nav)
                
                # Print in TSV format
                print scheme_name "\t" nav
            }
        }
    ' "$TEMP_FILE" >> "$OUTPUT_FILE"
    
    # Count the number of records processed
    record_count=$(($(wc -l < "$OUTPUT_FILE") - 1))  # Subtract header line
    
    echo -e "${GREEN}✓ Parsing complete${NC}"
    echo -e "${GREEN}✓ Processed $record_count scheme records${NC}"
}

################################################################################
# Function: display_sample
# Displays a sample of the output
################################################################################
display_sample() {
    echo -e "\n${BLUE}Sample output (first 10 records):${NC}"
    echo "----------------------------------------"
    head -n 11 "$OUTPUT_FILE" | column -t -s $'\t'
    echo "----------------------------------------"
}

################################################################################
# Function: cleanup
# Removes temporary files
################################################################################
cleanup() {
    if [ -f "$TEMP_FILE" ]; then
        rm "$TEMP_FILE"
        echo -e "${GREEN}✓ Cleaned up temporary files${NC}"
    fi
}

################################################################################
# Main execution
################################################################################
main() {
    echo "========================================"
    echo "  AMFI NAV Data Parser"
    echo "========================================"
    echo ""
    
    # Download data
    if ! download_data; then
        echo -e "${RED}Failed to download data. Exiting.${NC}"
        exit 1
    fi
    
    # Parse data
    parse_nav_data
    
    # Display sample
    display_sample
    
    # Cleanup
    cleanup
    
    echo ""
    echo -e "${GREEN}✓ Output saved to: $OUTPUT_FILE${NC}"
    echo "========================================"
}

# Run main function
main
