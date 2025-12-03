# Question 1: OLX Car Cover Scraper

## Overview
This Python script scrapes car cover listings from OLX India and displays the results in a clean table format.

## Features
- Scrapes title, description, and price from OLX listings
- Displays results in a formatted table
- Handles errors gracefully
- Saves results to a text file
- Respects rate limits with delays between requests

## Prerequisites
- Python 3.7 or higher
- Internet connection

## Installation

1. Install required dependencies:
```bash
pip install -r requirements.txt
```

## Usage

Run the scraper:
```bash
python olx_scraper.py
```

The script will:
1. Fetch car cover listings from OLX
2. Extract title, description, and price
3. Display results in a table format
4. Save results to `olx_results.txt`

## Sample Output

```
==================================================================================================
OLX CAR COVER SEARCH RESULTS
==================================================================================================
+----+--------------------------------------------------+-------------------------------+----------+
| #  | Title                                            | Description                   | Price    |
+====+==================================================+===============================+==========+
| 1  | Waterproof Car Body Cover                        | See listing for details       | ₹ 599    |
+----+--------------------------------------------------+-------------------------------+----------+
| 2  | Premium Car Cover for Sedan                      | See listing for details       | ₹ 1,200  |
+----+--------------------------------------------------+-------------------------------+----------+
```

## Technical Details

### Approach
- Uses `requests` library for HTTP requests
- Uses `BeautifulSoup4` for HTML parsing
- Uses `tabulate` for table formatting
- Implements proper user-agent headers to avoid blocking
- Includes error handling for network issues

### Limitations
- OLX may use dynamic content loading (JavaScript), which this script doesn't handle
- If OLX changes their HTML structure, the selectors may need updating
- Rate limiting may apply for too many requests

## Notes
- The script includes a 0.5-second delay between requests to be respectful to OLX servers
- If no results are found, the page structure may have changed and selectors need updating
- Description field may show "See listing for details" as OLX doesn't always include full descriptions in search results
