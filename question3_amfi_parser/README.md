# Question 3: AMFI NAV Data Parser

## Overview
Shell scripts to extract Scheme Name and Net Asset Value from AMFI India's NAV data and save in TSV and JSON formats.

## Files
- `parse_nav.sh` - Main script that extracts data to TSV format
- `nav_to_json.sh` - Bonus script that converts data to JSON format

## Data Source
- **URL:** https://www.amfiindia.com/spages/NAVAll.txt
- **Format:** Semicolon-delimited text file
- **Update Frequency:** Daily

## Prerequisites
- Bash shell (Linux, macOS, WSL, Git Bash on Windows)
- `curl` or `wget` (for downloading data)
- `awk` (for parsing)
- `jq` (optional, for JSON validation)

## Usage

### TSV Output
```bash
cd question3_amfi_parser
chmod +x parse_nav.sh
./parse_nav.sh
```

**Output:** `nav_output.tsv` - Tab-separated file with two columns:
- Scheme Name
- Net Asset Value

### JSON Output (Bonus)
```bash
chmod +x nav_to_json.sh
./nav_to_json.sh
```

**Output:** `nav_output.json` - JSON file with structured data including metadata

## Sample Output

### TSV Format (nav_output.tsv)
```
Scheme Name	Net Asset Value
Aditya Birla Sun Life Liquid Fund - Direct Plan - Growth	100.5234
HDFC Equity Fund - Direct Plan - Growth	850.32
ICICI Prudential Balanced Advantage Fund - Growth	45.67
```

### JSON Format (nav_output.json)
```json
{
  "metadata": {
    "source": "AMFI India",
    "url": "https://www.amfiindia.com/spages/NAVAll.txt",
    "generated_at": "2025-12-03T17:15:00Z"
  },
  "schemes": [
    {
      "scheme_code": "119551",
      "scheme_name": "Aditya Birla Sun Life Liquid Fund - Direct Plan - Growth",
      "nav": "100.5234",
      "date": "03-Dec-2025"
    }
  ]
}
```

## Technical Details

### Data Format
The AMFI NAV file uses semicolon (`;`) as delimiter with the following structure:
```
Scheme Code;ISIN Div Payout;ISIN Div Reinvestment;Scheme Name;Net Asset Value;Date
```

### Parsing Approach
1. **Download:** Use `curl` or `wget` to fetch the data
2. **Parse:** Use `awk` to extract columns 4 (Scheme Name) and 5 (NAV)
3. **Filter:** Skip header lines and empty records
4. **Format:** Output as TSV or JSON
5. **Cleanup:** Remove temporary files

### Key Features
- **Modular design:** Separate functions for each task
- **Error handling:** Checks for download failures
- **Fallback support:** Works with both curl and wget
- **Clean output:** Formatted and easy to read
- **Sample display:** Shows first 10 records after processing

## Why JSON?

The question asks: "Ever wondered if this data should not be stored in JSON?"

**Advantages of JSON format:**
- ✅ Structured and hierarchical
- ✅ Easy to parse in modern applications
- ✅ Supports metadata (source, timestamp, etc.)
- ✅ Better for APIs and web applications
- ✅ Type-safe with proper schema validation
- ✅ Widely supported across programming languages

**Advantages of TSV format:**
- ✅ Simpler and more compact
- ✅ Easy to import into spreadsheets
- ✅ Human-readable
- ✅ Lower parsing overhead
- ✅ Better for data analysis tools (R, pandas, etc.)

**Conclusion:** JSON is better for application integration, while TSV is better for data analysis and spreadsheet import. Both formats have their use cases!

## Notes
- The scripts include color-coded output for better readability
- Temporary files are automatically cleaned up
- The JSON script includes validation if `jq` is installed
- Both scripts handle edge cases (missing data, special characters, etc.)
