#!/usr/bin/env python3
"""
OLX Car Cover Scraper
Author: Internship Assignment Solution
Description: Scrapes car cover listings from OLX and displays results in table format
"""

import requests
from bs4 import BeautifulSoup
from tabulate import tabulate
import time
import sys


class OLXScraper:
    """Scraper for OLX car cover listings"""
    
    def __init__(self):
        self.base_url = "https://www.olx.in/items/q-car-cover"
        self.headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
            'Accept-Language': 'en-US,en;q=0.5',
            'Accept-Encoding': 'gzip, deflate, br',
            'Connection': 'keep-alive',
            'Upgrade-Insecure-Requests': '1'
        }
        self.results = []
    
    def fetch_page(self, url):
        """Fetch page content with error handling"""
        try:
            print(f"Fetching: {url}")
            response = requests.get(url, headers=self.headers, timeout=10)
            response.raise_for_status()
            return response.text
        except requests.RequestException as e:
            print(f"Error fetching page: {e}", file=sys.stderr)
            return None
    
    def parse_listing(self, listing):
        """Extract data from a single listing"""
        try:
            # Extract title
            title_elem = listing.find('span', {'data-aut-id': 'itemTitle'})
            title = title_elem.text.strip() if title_elem else "N/A"
            
            # Extract price
            price_elem = listing.find('span', {'data-aut-id': 'itemPrice'})
            price = price_elem.text.strip() if price_elem else "N/A"
            
            # Extract description (from title or other available text)
            # OLX doesn't always show full description in listings, so we use available info
            desc_elem = listing.find('span', {'data-aut-id': 'itemTitle'})
            description = desc_elem.text.strip() if desc_elem else "N/A"
            
            # Try to get additional details if available
            details = listing.find_all('span', class_='_2tW1I')
            if details and len(details) > 0:
                description = ' | '.join([d.text.strip() for d in details[:2]])
            
            return {
                'title': title,
                'description': description if description != title else "See listing for details",
                'price': price
            }
        except Exception as e:
            print(f"Error parsing listing: {e}", file=sys.stderr)
            return None
    
    def scrape(self, max_results=20):
        """Main scraping function"""
        url = f"{self.base_url}?isSearchCall=true"
        html = self.fetch_page(url)
        
        if not html:
            print("Failed to fetch page. Please check your internet connection.")
            return []
        
        soup = BeautifulSoup(html, 'html.parser')
        
        # Find all listing items
        # OLX uses different class names, we'll try multiple selectors
        listings = soup.find_all('li', {'data-aut-id': 'itemBox'})
        
        if not listings:
            # Try alternative selector
            listings = soup.find_all('div', class_='_1DNjI')
        
        if not listings:
            print("No listings found. The page structure might have changed.")
            print("Attempting alternative parsing method...")
            # Try to find any elements with price indicators
            listings = soup.find_all('div', string=lambda text: text and '₹' in text)
        
        print(f"Found {len(listings)} listings")
        
        for listing in listings[:max_results]:
            data = self.parse_listing(listing)
            if data and data['title'] != "N/A":
                self.results.append(data)
            
            # Be respectful - add small delay
            time.sleep(0.5)
        
        return self.results
    
    def display_results(self):
        """Display results in table format"""
        if not self.results:
            print("\nNo results to display.")
            return
        
        # Prepare data for tabulate
        table_data = []
        for idx, item in enumerate(self.results, 1):
            # Truncate description if too long
            desc = item['description']
            if len(desc) > 60:
                desc = desc[:57] + "..."
            
            table_data.append([
                idx,
                item['title'][:50] + "..." if len(item['title']) > 50 else item['title'],
                desc,
                item['price']
            ])
        
        # Print table
        headers = ["#", "Title", "Description", "Price"]
        print("\n" + "="*100)
        print("OLX CAR COVER SEARCH RESULTS")
        print("="*100)
        print(tabulate(table_data, headers=headers, tablefmt="grid"))
        print(f"\nTotal Results: {len(self.results)}")
        print("="*100)


def main():
    """Main execution function"""
    print("OLX Car Cover Scraper")
    print("-" * 50)
    
    scraper = OLXScraper()
    
    # Scrape listings
    results = scraper.scrape(max_results=20)
    
    # Display results
    scraper.display_results()
    
    # Save to file (optional)
    if results:
        try:
            with open('olx_results.txt', 'w', encoding='utf-8') as f:
                f.write("OLX Car Cover Search Results\n")
                f.write("="*100 + "\n\n")
                for idx, item in enumerate(results, 1):
                    f.write(f"{idx}. {item['title']}\n")
                    f.write(f"   Price: {item['price']}\n")
                    f.write(f"   Description: {item['description']}\n")
                    f.write("-"*100 + "\n")
            print(f"\nResults also saved to: olx_results.txt")
        except Exception as e:
            print(f"Could not save results to file: {e}")


if __name__ == "__main__":
    main()
