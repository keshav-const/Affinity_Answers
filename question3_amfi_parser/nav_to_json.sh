#!/bin/bash

################################################################################
# AMFI NAV Data to JSON Converter
# Author: Internship Assignment Solution
# Description: Extracts Scheme Name and NAV from AMFI data and converts to JSON
#              This answers the question: "Ever wondered if this data should 
#              not be stored in JSON?"
################################################################################

# Configuration
URL="https://www.amfiindia.com/spages/NAVAll.txt"
OUTPUT_FILE="nav_output.json"
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
    
    if command -v curl &> /dev/null; then
        curl -s -o "$TEMP_FILE" "$URL"
        [ $? -eq 0 ] && echo -e "${GREEN}✓ Download successful${NC}" && return 0
    elif command -v wget &> /dev/null; then
        wget -q -O "$TEMP_FILE" "$URL"
        [ $? -eq 0 ] && echo -e "${GREEN}✓ Download successful${NC}" && return 0
    fi
    
    echo -e "${RED}✗ Download failed${NC}"
    return 1
}

################################################################################
# Function: parse_to_json
# Parses the data and converts to JSON format
################################################################################
parse_to_json() {
    echo -e "${BLUE}Converting to JSON format...${NC}"
    
    # Start JSON array
    echo '{' > "$OUTPUT_FILE"
    echo '  "metadata": {' >> "$OUTPUT_FILE"
    echo '    "source": "AMFI India",' >> "$OUTPUT_FILE"
    echo '    "url": "'"$URL"'",' >> "$OUTPUT_FILE"
    echo '    "generated_at": "'"$(date -u +"%Y-%m-%dT%H:%M:%SZ")"'"' >> "$OUTPUT_FILE"
    echo '  },' >> "$OUTPUT_FILE"
    echo '  "schemes": [' >> "$OUTPUT_FILE"
    
    # Parse and convert to JSON
    awk -F';' '
        BEGIN {
            first = 1
        }
        /^[0-9]/ {
            scheme_code = $1
            scheme_name = $4
            nav = $5
            date = $6
            
            if (scheme_name != "" && nav != "") {
                # Remove leading/trailing whitespace
                gsub(/^[ \t]+|[ \t]+$/, "", scheme_code)
                gsub(/^[ \t]+|[ \t]+$/, "", scheme_name)
                gsub(/^[ \t]+|[ \t]+$/, "", nav)
                gsub(/^[ \t]+|[ \t]+$/, "", date)
                
                # Escape double quotes in scheme name
                gsub(/"/, "\\\"", scheme_name)
                
                # Add comma before all entries except the first
                if (first == 0) {
                    print ","
                }
                first = 0
                
                # Print JSON object (without trailing newline for last entry)
                printf "    {\n"
                printf "      \"scheme_code\": \"%s\",\n", scheme_code
                printf "      \"scheme_name\": \"%s\",\n", scheme_name
                printf "      \"nav\": \"%s\",\n", nav
                printf "      \"date\": \"%s\"\n", date
                printf "    }"
            }
        }
        END {
            # Add final newline
            printf "\n"
        }
    ' "$TEMP_FILE" >> "$OUTPUT_FILE"
    
    # Close JSON array and object
    echo '  ]' >> "$OUTPUT_FILE"
    echo '}' >> "$OUTPUT_FILE"
    
    # Count records
    record_count=$(grep -c '"scheme_code"' "$OUTPUT_FILE")
    
    echo -e "${GREEN}✓ Conversion complete${NC}"
    echo -e "${GREEN}✓ Processed $record_count scheme records${NC}"
}

################################################################################
# Function: validate_json
# Validates the generated JSON (if jq is available)
################################################################################
validate_json() {
    if command -v jq &> /dev/null; then
        echo -e "${BLUE}Validating JSON...${NC}"
        if jq empty "$OUTPUT_FILE" 2>/dev/null; then
            echo -e "${GREEN}✓ JSON is valid${NC}"
        else
            echo -e "${RED}✗ JSON validation failed${NC}"
        fi
    else
        echo -e "${BLUE}Note: Install 'jq' for JSON validation${NC}"
    fi
}

################################################################################
# Function: display_sample
# Displays a sample of the JSON output
################################################################################
display_sample() {
    echo -e "\n${BLUE}Sample JSON output (first 2 schemes):${NC}"
    echo "----------------------------------------"
    
    if command -v jq &> /dev/null; then
        # Pretty print with jq if available
        jq '.schemes[0:2]' "$OUTPUT_FILE"
    else
        # Simple head if jq not available
        head -n 20 "$OUTPUT_FILE"
    fi
    
    echo "----------------------------------------"
}

################################################################################
# Function: cleanup
# Removes temporary files
################################################################################
cleanup() {
    [ -f "$TEMP_FILE" ] && rm "$TEMP_FILE" && echo -e "${GREEN}✓ Cleaned up temporary files${NC}"
}

################################################################################
# Main execution
################################################################################
main() {
    echo "========================================"
    echo "  AMFI NAV to JSON Converter"
    echo "========================================"
    echo ""
    
    # Download data
    if ! download_data; then
        echo -e "${RED}Failed to download data. Exiting.${NC}"
        exit 1
    fi
    
    # Convert to JSON
    parse_to_json
    
    # Validate JSON
    validate_json
    
    # Display sample
    display_sample
    
    # Cleanup
    cleanup
    
    echo ""
    echo -e "${GREEN}✓ JSON output saved to: $OUTPUT_FILE${NC}"
    echo "========================================"
}

# Run main function
main
