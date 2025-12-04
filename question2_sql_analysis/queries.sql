-- ============================================================================
-- AffinityAnswers Internship Assignment - Question 2: SQL Database Analysis
-- Database: Rfam (RNA families database)
-- Connection: mysql-rfam-public.ebi.ac.uk:4497
-- ============================================================================

-- ============================================================================
-- Question 2a: How many types of tigers can be found in the taxonomy table?
--              What is the "ncbi_id" of the Sumatran Tiger?
-- ============================================================================

-- Find all tiger subspecies in the taxonomy table
-- Tigers belong to genus Panthera, species tigris
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

-- Specific query for Sumatran Tiger
-- Biological name: Panthera tigris sumatrae
SELECT 
    ncbi_id,
    species,
    tax_string
FROM 
    taxonomy
WHERE 
    species LIKE '%Panthera tigris sumatrae%'
    OR tax_string LIKE '%Panthera tigris sumatrae%';

-- Alternative: Search by common name pattern if available
SELECT 
    ncbi_id,
    species,
    tax_string
FROM 
    taxonomy
WHERE 
    species LIKE '%tigris%'
ORDER BY 
    species;


-- ============================================================================
-- Question 2b: Find all the columns that can be used to connect the tables
--              in the given database
-- ============================================================================

-- Method 1: Using INFORMATION_SCHEMA to find foreign key relationships
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

-- Method 2: Find all primary keys in the database
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME
FROM 
    INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE 
    TABLE_SCHEMA = 'Rfam'
    AND CONSTRAINT_NAME = 'PRIMARY'
ORDER BY 
    TABLE_NAME;

-- Method 3: Analyze common column names across tables
-- This helps identify potential join columns even without explicit foreign keys
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE
FROM 
    INFORMATION_SCHEMA.COLUMNS
WHERE 
    TABLE_SCHEMA = 'Rfam'
    AND (
        COLUMN_NAME LIKE '%_id' 
        OR COLUMN_NAME LIKE '%_acc'
        OR COLUMN_NAME = 'rfam_acc'
        OR COLUMN_NAME = 'ncbi_id'
        OR COLUMN_NAME = 'auto_wiki'
    )
ORDER BY 
    COLUMN_NAME, TABLE_NAME;


-- ============================================================================
-- Question 2c: Which type of rice has the longest DNA sequence?
-- ============================================================================

-- Rice belongs to genus Oryza
-- We need to join rfamseq (contains sequence data) with taxonomy (contains species info)
-- The rfamseq table has ncbi_id which links to taxonomy table

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
    OR t.species LIKE '%Oryza%'
ORDER BY 
    r.length DESC
LIMIT 1;

-- Alternative: Get top 5 to see the distribution
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
    OR t.species LIKE '%Oryza%'
ORDER BY 
    r.length DESC
LIMIT 5;


-- ============================================================================
-- Question 2d: Paginate family names and their longest DNA sequence lengths
--              - Only families with sequence length > 1,000,000
--              - Descending order of length
--              - Page 9 with 15 results per page
--              - Return: family_acc, family_name, max_length
-- ============================================================================

-- Calculate offset for page 9 with 15 results per page
-- Page 9 means we skip the first 8 pages: (9-1) * 15 = 120
-- OFFSET = 120, LIMIT = 15

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

-- Verification query: Count total families matching criteria
-- This helps verify that page 9 exists
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

-- Alternative: Show which page range we're in
SELECT 
    f.rfam_acc AS family_accession,
    f.rfam_id AS family_name,
    MAX(r.length) AS max_sequence_length,
    ROW_NUMBER() OVER (ORDER BY MAX(r.length) DESC) AS row_num,
    CEILING(ROW_NUMBER() OVER (ORDER BY MAX(r.length) DESC) / 15.0) AS page_number
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
