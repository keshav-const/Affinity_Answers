# Question 2: SQL Database Analysis - Rfam

## Overview
This folder contains SQL queries and analysis for the Rfam (RNA families) public database, answering questions about taxonomy, table relationships, and DNA sequences.

## Database Connection Details
- **Host:** mysql-rfam-public.ebi.ac.uk
- **Port:** 4497
- **Database:** Rfam
- **User:** rfamro (read-only)
- **Password:** (none required)
- **Documentation:** http://docs.rfam.org/en/latest/database.html

## Files
- `queries.sql` - All SQL queries with detailed comments
- `analysis.md` - Comprehensive answers with explanations
- `connect_to_rfam.py` - Python script to execute queries
- `requirements.txt` - Python dependencies

## Quick Start

### Option 1: Using Python Script (Recommended)
```bash
pip install -r requirements.txt
python connect_to_rfam.py
```

This will execute all queries and display formatted results.

### Option 2: Using MySQL Client
```bash
mysql -h mysql-rfam-public.ebi.ac.uk -P 4497 -u rfamro Rfam
```

Then copy and paste queries from `queries.sql`.

## Questions Answered

### 2a) Tiger Types and Sumatran Tiger NCBI ID
- Counts all tiger subspecies in the taxonomy table
- Finds the specific NCBI ID for Sumatran Tiger (*Panthera tigris sumatrae*)

### 2b) Table Connecting Columns
- Identifies all foreign key relationships
- Lists primary keys in each table
- Finds common column patterns for joining tables

### 2c) Rice with Longest DNA Sequence
- Joins `rfamseq` and `taxonomy` tables
- Filters for genus *Oryza* (rice)
- Returns the rice type with the longest sequence

### 2d) Paginated Family Results
- Families with DNA sequence length > 1,000,000
- Sorted by length (descending)
- Page 9 with 15 results per page
- Returns: family_acc, family_name, max_length

## Sample Output

When you run `connect_to_rfam.py`, you'll see formatted output like:

```
================================================================================
QUESTION 2a: Tiger Types and Sumatran Tiger NCBI ID
================================================================================
All Tiger Types in Taxonomy
================================================================================
ncbi_id              | species              | tax_string           
--------------------------------------------------------------------------------
9693                 | Panthera tigris      | Panthera tigris...
9694                 | Panthera tigris al.. | Panthera tigris al...
9695                 | Panthera tigris su.. | Panthera tigris su...
...
```

## Technical Details

### Approach
- Used INNER JOINs to connect related tables
- Applied WHERE clauses for filtering
- Used GROUP BY with HAVING for aggregations
- Implemented LIMIT and OFFSET for pagination
- Added ORDER BY for consistent results

### Key Tables Used
- `taxonomy` - Species and taxonomic information
- `rfamseq` - RNA sequence data
- `family` - RNA family information
- `INFORMATION_SCHEMA` - Database metadata

### Common Join Patterns
```sql
-- Sequences with taxonomy info
rfamseq JOIN taxonomy ON rfamseq.ncbi_id = taxonomy.ncbi_id

-- Families with sequences
family JOIN rfamseq ON family.rfam_acc = rfamseq.rfam_acc
```

## Notes
- All queries are read-only (SELECT statements)
- Results may vary slightly as the database is updated
- Pagination assumes stable ordering (ORDER BY is crucial)
- Some queries may take time due to large dataset size

## Further Reading
- [Rfam Database Documentation](http://docs.rfam.org/en/latest/database.html)
- [Rfam Database Schema](http://docs.rfam.org/en/latest/database.html#database-schema)
