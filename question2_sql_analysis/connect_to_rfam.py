#!/usr/bin/env python3
"""
Rfam Database Connection Helper
Author: Internship Assignment Solution
Description: Helper script to connect to Rfam public database and execute queries
"""

import mysql.connector
from mysql.connector import Error
import sys


class RfamDatabase:
    """Helper class to interact with Rfam public database"""
    
    # Database configuration (no hard-coding in main logic)
    DB_CONFIG = {
        'host': 'mysql-rfam-public.ebi.ac.uk',
        'port': 4497,
        'database': 'Rfam',
        'user': 'rfamro',
        'password': ''  # No password required for read-only access
    }
    
    def __init__(self):
        """Initialize database connection"""
        self.connection = None
        self.cursor = None
    
    def connect(self):
        """Establish connection to Rfam database"""
        try:
            print(f"Connecting to Rfam database at {self.DB_CONFIG['host']}...")
            self.connection = mysql.connector.connect(**self.DB_CONFIG)
            
            if self.connection.is_connected():
                db_info = self.connection.get_server_info()
                print(f"Successfully connected to MySQL Server version {db_info}")
                self.cursor = self.connection.cursor(dictionary=True)
                
                # Verify database
                self.cursor.execute("SELECT DATABASE();")
                record = self.cursor.fetchone()
                print(f"Connected to database: {record['DATABASE()']}")
                return True
            
        except Error as e:
            print(f"Error connecting to MySQL: {e}", file=sys.stderr)
            return False
    
    def execute_query(self, query, params=None):
        """
        Execute a SELECT query and return results
        
        Args:
            query (str): SQL query to execute
            params (tuple): Optional parameters for parameterized queries
            
        Returns:
            list: List of dictionaries containing query results
        """
        try:
            if params:
                self.cursor.execute(query, params)
            else:
                self.cursor.execute(query)
            
            results = self.cursor.fetchall()
            return results
        
        except Error as e:
            print(f"Error executing query: {e}", file=sys.stderr)
            return None
    
    def print_results(self, results, title="Query Results"):
        """
        Pretty print query results
        
        Args:
            results (list): List of dictionaries from query
            title (str): Title to display
        """
        if not results:
            print("No results found.")
            return
        
        print("\n" + "="*80)
        print(title)
        print("="*80)
        
        # Print column headers
        if results:
            headers = list(results[0].keys())
            header_line = " | ".join(f"{h:20}" for h in headers)
            print(header_line)
            print("-" * len(header_line))
            
            # Print rows
            for row in results:
                row_line = " | ".join(f"{str(row[h])[:20]:20}" for h in headers)
                print(row_line)
        
        print(f"\nTotal rows: {len(results)}")
        print("="*80 + "\n")
    
    def close(self):
        """Close database connection"""
        if self.connection and self.connection.is_connected():
            if self.cursor:
                self.cursor.close()
            self.connection.close()
            print("Database connection closed.")


def run_question_2a(db):
    """Execute queries for Question 2a: Tiger types and Sumatran Tiger"""
    print("\n" + "#"*80)
    print("QUESTION 2a: Tiger Types and Sumatran Tiger NCBI ID")
    print("#"*80)
    
    # Query for all tigers
    query_all_tigers = """
        SELECT 
            ncbi_id,
            species,
            tax_string
        FROM 
            taxonomy
        WHERE 
            tax_string LIKE '%Panthera tigris%'
        ORDER BY 
            species
    """
    
    results = db.execute_query(query_all_tigers)
    db.print_results(results, "All Tiger Types in Taxonomy")
    
    # Query for Sumatran Tiger specifically
    query_sumatran = """
        SELECT 
            ncbi_id,
            species,
            tax_string
        FROM 
            taxonomy
        WHERE 
            species LIKE '%sumatrae%'
            OR tax_string LIKE '%sumatrae%'
    """
    
    results = db.execute_query(query_sumatran)
    db.print_results(results, "Sumatran Tiger (Panthera tigris sumatrae)")


def run_question_2b(db):
    """Execute queries for Question 2b: Find connecting columns"""
    print("\n" + "#"*80)
    print("QUESTION 2b: Columns That Connect Tables")
    print("#"*80)
    
    # Query for foreign key relationships
    query_fk = """
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
            TABLE_NAME, COLUMN_NAME
    """
    
    results = db.execute_query(query_fk)
    db.print_results(results, "Foreign Key Relationships")


def run_question_2c(db):
    """Execute queries for Question 2c: Rice with longest DNA sequence"""
    print("\n" + "#"*80)
    print("QUESTION 2c: Rice Type with Longest DNA Sequence")
    print("#"*80)
    
    query_rice = """
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
        LIMIT 5
    """
    
    results = db.execute_query(query_rice)
    db.print_results(results, "Top 5 Rice Types by DNA Sequence Length")


def run_question_2d(db):
    """Execute queries for Question 2d: Paginated family results"""
    print("\n" + "#"*80)
    print("QUESTION 2d: Page 9 of Family Names (15 per page, length > 1M)")
    print("#"*80)
    
    # First, get total count
    query_count = """
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
        ) AS filtered_families
    """
    
    count_result = db.execute_query(query_count)
    if count_result:
        total = count_result[0]['total_families']
        print(f"Total families with sequence length > 1,000,000: {total}")
        print(f"Total pages (15 per page): {(total + 14) // 15}")
        print(f"Requesting page 9 (rows 121-135)\n")
    
    # Main pagination query
    query_paginated = """
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
        LIMIT 15 OFFSET 120
    """
    
    results = db.execute_query(query_paginated)
    db.print_results(results, "Page 9: Family Names and Max Sequence Lengths")


def main():
    """Main execution function"""
    print("Rfam Database Query Executor")
    print("="*80)
    
    # Create database instance
    db = RfamDatabase()
    
    # Connect to database
    if not db.connect():
        print("Failed to connect to database. Exiting.")
        sys.exit(1)
    
    try:
        # Run all questions
        run_question_2a(db)
        run_question_2b(db)
        run_question_2c(db)
        run_question_2d(db)
        
    except KeyboardInterrupt:
        print("\n\nInterrupted by user.")
    
    except Exception as e:
        print(f"\nError during execution: {e}", file=sys.stderr)
    
    finally:
        # Always close connection
        db.close()
    
    print("\nAll queries completed successfully!")


if __name__ == "__main__":
    main()
