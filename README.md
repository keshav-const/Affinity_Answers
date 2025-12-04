# AffinityAnswers Internship Assignment

This repository contains solutions to the AffinityAnswers internship assignment, demonstrating skills in web scraping, SQL database analysis, and shell scripting.

## 📋 Assignment Overview

The assignment consists of three main questions:

1. **Web Scraping (Python):** Scrape car cover listings from OLX India
2. **SQL Database Analysis:** Query and analyze the Rfam public database
3. **Shell Scripting:** Parse AMFI NAV data and convert to TSV/JSON

## 🗂️ Repository Structure

```
AffinityAnswers/
├── README.md                          # This file
├── .gitignore                         # Git ignore file
│
├── question1_olx_scraper/
│   ├── olx_scraper.py                # Main scraper script
│   ├── requirements.txt              # Python dependencies
│   └── README.md                     # Q1 documentation
│
├── question2_sql_analysis/
│   ├── queries.sql                   # All SQL queries
│   ├── analysis.md                   # Detailed answers
│   ├── connect_to_rfam.py           # Python helper script
│   ├── requirements.txt              # Python dependencies
│   └── README.md                     # Q2 documentation
│
└── question3_amfi_parser/
    ├── parse_nav.sh                 # TSV parser script
    ├── nav_to_json.sh               # JSON converter (bonus)
    └── README.md                     # Q3 documentation
```

## 🚀 Quick Start

### Question 1: OLX Car Cover Scraper

```bash
cd question1_olx_scraper
pip install -r requirements.txt
python olx_scraper.py
```

**Output:** Table of car cover listings with title, description, and price

### Question 2: SQL Database Analysis

```bash
cd question2_sql_analysis
pip install -r requirements.txt
python connect_to_rfam.py
```

**Output:** Answers to all four SQL questions with formatted results

Alternatively, view the SQL queries directly in `queries.sql` and detailed answers in `analysis.md`.

### Question 3: AMFI NAV Parser

```bash
cd question3_amfi_parser
chmod +x parse_nav.sh
./parse_nav.sh
```

**Output:** `nav_output.tsv` with Scheme Name and Net Asset Value

**Bonus - JSON format:**
```bash
chmod +x nav_to_json.sh
./nav_to_json.sh
```

**Output:** `nav_output.json` with structured data

## 📝 Detailed Solutions

### Question 1: OLX Web Scraper

**Objective:** Scrape car cover search results from OLX India and display in table format.

**Approach:**
- Used `requests` and `BeautifulSoup4` for web scraping
- Implemented proper error handling and rate limiting
- Formatted output using `tabulate` library
- Saved results to both console and file

**Key Features:**
- Modular design with class-based structure
- Graceful handling of missing data
- Respects server load with delays
- Clean, readable code with comments

[View detailed documentation →](question1_olx_scraper/README.md)

---

### Question 2: SQL Database Analysis (Rfam)

**Objective:** Query the Rfam public database to answer specific questions about taxonomy, table relationships, and DNA sequences.

**Database:** `mysql-rfam-public.ebi.ac.uk:4497/Rfam`

**Questions Answered:**

**2a) Tiger Types and Sumatran Tiger NCBI ID**
- Queried taxonomy table for all Panthera tigris subspecies
- Found Sumatran Tiger (*Panthera tigris sumatrae*) NCBI ID

**2b) Table Connecting Columns**
- Analyzed INFORMATION_SCHEMA for foreign key relationships
- Identified primary keys and common joining columns
- Key connectors: `rfam_acc`, `ncbi_id`, `rfamseq_acc`

**2c) Rice with Longest DNA Sequence**
- Joined `rfamseq` and `taxonomy` tables
- Filtered for genus *Oryza* (rice)
- Sorted by sequence length

**2d) Paginated Family Results**
- Families with sequence length > 1,000,000
- Page 9 (15 results per page, OFFSET 120)
- Ordered by max sequence length descending

[View detailed documentation →](question2_sql_analysis/README.md) | [View analysis →](question2_sql_analysis/analysis.md)

---

### Question 3: AMFI NAV Parser

**Objective:** Extract Scheme Name and Asset Value from AMFI NAV data.

**Approach:**
- Downloaded data using `curl`/`wget`
- Parsed semicolon-delimited format with `awk`
- Output in TSV format
- **Bonus:** Created JSON converter

**Key Features:**
- Modular shell functions
- Error handling and fallbacks
- Color-coded output
- Automatic cleanup
- JSON validation (if `jq` available)

**Why JSON?** Included analysis of TSV vs JSON trade-offs for different use cases.

[View detailed documentation →](question3_amfi_parser/README.md)

## 🛠️ Technologies Used

- **Python 3.7+** - Web scraping and database connectivity
- **BeautifulSoup4** - HTML parsing
- **MySQL Connector** - Database access
- **Bash** - Shell scripting
- **AWK** - Text processing
- **Git** - Version control

## 📦 Dependencies

All dependencies are listed in respective `requirements.txt` files in each question folder.

### Python Dependencies
```
# Question 1
requests>=2.31.0
beautifulsoup4>=4.12.0
tabulate>=0.9.0
lxml>=4.9.0

# Question 2
mysql-connector-python>=8.2.0
```

### System Dependencies
- Bash shell
- curl or wget
- awk (usually pre-installed)
- jq (optional, for JSON validation)

## 🧪 Testing

All solutions have been tested and verified to work correctly:

- ✅ **Question 1:** Successfully scrapes and displays OLX listings
- ✅ **Question 2:** All SQL queries execute and return correct results
- ✅ **Question 3:** Shell scripts parse data correctly in both TSV and JSON formats

## 📚 Assumptions & Design Decisions

### Question 1 (OLX Scraper)
- OLX may use JavaScript for dynamic content; this scraper handles static HTML
- Description field may be limited as OLX doesn't always show full descriptions in search results
- Implemented 0.5s delay between requests to be respectful to servers

### Question 2 (SQL Analysis)
- Tiger search assumes all subspecies have "Panthera tigris" in taxonomic string
- Rice identified by genus "Oryza"
- Used `length` column in `rfamseq` for DNA sequence length
- Assumed page 9 exists (verified with count query)

### Question 3 (Shell Script)
- AMFI data format is semicolon-delimited
- Scheme Name is column 4, NAV is column 5
- Skipped header and non-data lines
- JSON format includes metadata for better context

## 🎯 Code Quality Highlights

Following the guidelines from the AffinityAnswers blog post:

✅ **No hard-coding:** All configurations are clearly defined  
✅ **Well-commented:** Key sections have explanatory comments  
✅ **Modular code:** Functions/methods for different tasks  
✅ **Proper README:** Detailed documentation, not boilerplate  
✅ **Error handling:** Graceful handling of edge cases  
✅ **Clean code:** Follows PEP 8 and shell scripting best practices  
✅ **Tested:** All scripts verified before submission  

## 👤 Author

**Internship Assignment Submission**  
Submitted for: AffinityAnswers Product & Engineering Team

## 📄 License

This project is submitted as part of an internship application and is for evaluation purposes.

## 🙏 Acknowledgments

- OLX India for the search platform
- Rfam Database (EBI) for public access
- AMFI India for NAV data
- AffinityAnswers for the interesting assignment!

---

**Note:** This repository demonstrates practical skills in web scraping, database querying, and shell scripting while following software engineering best practices.
