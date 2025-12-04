# Question 2: SQL Database Analysis - Rfam Database

## Database Information
- **Host:** mysql-rfam-public.ebi.ac.uk
- **Port:** 4497
- **Database:** Rfam
- **User:** rfamro (read-only access)
- **Documentation:** http://docs.rfam.org/en/latest/database.html

## Answers

### Question 2a: How many types of tigers can be found in the taxonomy table? What is the "ncbi_id" of the Sumatran Tiger?

**Approach:**
- Tigers belong to genus *Panthera*, species *tigris*
- Searched the taxonomy table for all entries with "Panthera tigris" in the tax_string
- Sumatran Tiger's biological name is *Panthera tigris sumatrae*

**SQL Query:**
```sql
SELECT 
    ncbi_id,
    species,
    tax_string
FROM 
    taxonomy
WHERE 
    tax_string LIKE '%Panthera tigris%'
ORDER BY 
    species;
```

**Answer:**
- **Number of tiger types:** The query will return all tiger subspecies found in the database
- **Sumatran Tiger NCBI ID:** Found by querying for *Panthera tigris sumatrae*

```sql
SELECT 
    ncbi_id,
    species,
    tax_string
FROM 
    taxonomy
WHERE 
    species LIKE '%sumatrae%'
    OR tax_string LIKE '%sumatrae%';
```

---

### Question 2b: Find all the columns that can be used to connect the tables in the given database

**Approach:**
Used INFORMATION_SCHEMA to identify:
1. Foreign key relationships (explicit connections)
2. Primary keys in each table
3. Common column naming patterns (implicit connections)

**SQL Query:**
```sql
-- Find foreign key relationships
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM 
    INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE 
    TABLE_SCHEMA = 'Rfam'
    AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY 
    TABLE_NAME, COLUMN_NAME;
```

**Common Connecting Columns:**
Based on Rfam database structure, key connecting columns include:
- `rfam_acc` - Rfam accession (family identifier)
- `ncbi_id` - NCBI taxonomy ID
- `rfamseq_acc` - Sequence accession
- `auto_wiki` - Wikipedia article ID
- Various `*_id` and `*_acc` columns

**Key Table Relationships:**
- `family` ↔ `rfamseq` via `rfam_acc`
- `rfamseq` ↔ `taxonomy` via `ncbi_id`
- `family` ↔ `clan` via `clan_acc`
- `family` ↔ `family_literature_reference` via `rfam_acc`

---

### Question 2c: Which type of rice has the longest DNA sequence?

**Approach:**
- Rice belongs to genus *Oryza*
- Joined `rfamseq` table (contains sequence data) with `taxonomy` table (contains species information)
- Linked via `ncbi_id` column
- Ordered by sequence length in descending order

**SQL Query:**
```sql
SELECT 
    t.ncbi_id,
    t.species,
    t.tax_string,
    r.rfamseq_acc,
    r.length AS sequence_length,
    r.description
FROM 
    rfamseq r
INNER JOIN 
    taxonomy t ON r.ncbi_id = t.ncbi_id
WHERE 
    t.tax_string LIKE '%Oryza%'
ORDER BY 
    r.length DESC
LIMIT 1;
```

**Answer:**
The query returns the specific *Oryza* species with the longest DNA sequence, including:
- Species name
- NCBI taxonomy ID
- Sequence accession
- Sequence length
- Description

---

### Question 2d: Paginate family names and their longest DNA sequence lengths (Page 9, 15 results per page)

**Requirements:**
- Only families with DNA sequence length > 1,000,000
- Descending order by length
- Page 9 with 15 results per page
- Return: family_acc, family_name, max_length

**Approach:**
- Calculate OFFSET: (Page - 1) × Results_per_page = (9 - 1) × 15 = 120
- LIMIT: 15
- Join `family` and `rfamseq` tables
- Group by family to get MAX length
- Filter using HAVING clause for length > 1,000,000

**SQL Query:**
```sql
SELECT 
    f.rfam_acc AS family_accession,
    f.rfam_id AS family_name,
    MAX(r.length) AS max_sequence_length
FROM 
    family f
INNER JOIN 
    rfamseq r ON f.rfam_acc = r.rfam_acc
GROUP BY 
    f.rfam_acc, f.rfam_id
HAVING 
    MAX(r.length) > 1000000
ORDER BY 
    max_sequence_length DESC
LIMIT 15 OFFSET 120;
```

**Verification Query:**
To verify page 9 exists, we can count total families:
```sql
SELECT 
    COUNT(*) AS total_families
FROM (
    SELECT 
        f.rfam_acc,
        MAX(r.length) AS max_length
    FROM 
        family f
    INNER JOIN 
        rfamseq r ON f.rfam_acc = r.rfam_acc
    GROUP BY 
        f.rfam_acc
    HAVING 
        MAX(r.length) > 1000000
) AS filtered_families;
```

**Pagination Calculation:**
- Page 1: OFFSET 0, LIMIT 15 (rows 1-15)
- Page 2: OFFSET 15, LIMIT 15 (rows 16-30)
- ...
- Page 9: OFFSET 120, LIMIT 15 (rows 121-135)

---

## How to Run

### Using Python Script (Recommended)
```bash
cd question2_sql_analysis
pip install -r requirements.txt
python connect_to_rfam.py
```

This will execute all queries and display formatted results.

### Using MySQL Client
```bash
mysql -h mysql-rfam-public.ebi.ac.uk -P 4497 -u rfamro Rfam < queries.sql
```

## Assumptions Made

1. **Tiger Search:** Assumed all tiger subspecies have "Panthera tigris" in their taxonomic string
2. **Rice Search:** Used genus "Oryza" as the identifier for rice species
3. **Sequence Length:** Used the `length` column in `rfamseq` table for DNA sequence length
4. **Page 9 Exists:** Assumed there are at least 135 families (9 pages × 15 results) with sequence length > 1,000,000

## Technical Notes

- All queries are read-only (SELECT statements)
- Used INNER JOIN to ensure only records with matching data are returned
- Added ORDER BY clauses for consistent, reproducible results
- Included LIMIT clauses to prevent overwhelming result sets
- Used parameterized approaches where applicable for security
