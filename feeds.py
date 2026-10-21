#!/usr/bin/env python3

import subprocess
import sys
import webbrowser
import xml.etree.ElementTree as ET
from concurrent.futures import ThreadPoolExecutor
from datetime import datetime, timedelta, timezone
from email.utils import parsedate_to_datetime
from pathlib import Path
from urllib.error import URLError
from urllib.request import Request, urlopen

ATOM = "{http://www.w3.org/2005/Atom}"

FEED_FILE = Path.home() / ".config/feeds.txt"
MONTHS = 1

# Read feeds list file, accounting for `#` comments.
assert FEED_FILE.is_file(), f"not found: {FEED_FILE}"
cutoff = datetime.now(timezone.utc) - timedelta(days=MONTHS * 30)
urls = [
    line.split("#")[0].strip()
    for line in FEED_FILE.read_text().splitlines()
    if line.strip() and not line.strip().startswith("#")
]


def parse_date(raw):
    raw = raw.strip()
    
    try:
        dt = parsedate_to_datetime(raw)
        return dt if dt.tzinfo else dt.replace(tzinfo=timezone.utc)
    except TypeError:
        pass
        
    normalized = raw.replace('Z', '+00:00')
    try:
        dt = datetime.fromisoformat(normalized)
        return dt if dt.tzinfo else dt.replace(tzinfo=timezone.utc)
    except TypeError:
        pass
        
    return None

def fetch_feed(url):
    try:
        request = Request(url, headers={"User-Agent": "feeds.py/1.0"})
        with urlopen(request, timeout=3) as r:
            raw = r.read()
    except (URLError, OSError) as e:
        print(f"! fetch failed: {url} ({e})", file=sys.stderr)
        return []

    try:
        root = ET.fromstring(raw)
    except ET.ParseError:
        print(f"! parse failed: {url}", file=sys.stderr)
        return []

    # Extract entries: try RSS first.
    entries = []
    for item in root.iter("item"):
        title = (item.findtext("title") or "").strip()
        link = (item.findtext("link") or "").strip()
        date = (item.findtext("pubDate") or "").strip()
        author = (
            item.findtext("author")
            or item.findtext("{http://purl.org/dc/elements/1.1/}creator")
            or ""
        ).strip()
        if title and link and date:
            entries.append((author, title, link, date))

    # Extract entries: fall back to Atom.
    if not entries:
        for entry in root.iter(f"{ATOM}entry"):
            title = (entry.findtext(f"{ATOM}title") or "").strip()
            link_el = entry.find(f"{ATOM}link[@rel='alternate']")
            if link_el is None:
                link_el = entry.find(f"{ATOM}link")
            link = (link_el.get("href", "") if link_el is not None else "").strip()
            date = (
                entry.findtext(f"{ATOM}published")
                or entry.findtext(f"{ATOM}updated")
                or ""
            ).strip()
            author = (entry.findtext(f"{ATOM}author/{ATOM}name") or "").strip()
            if title and link and date:
                entries.append((author, title, link, date))

    if not entries:
        print(f"! no entries: {url}", file=sys.stderr)
        return []

    results = []
    for author, title, link, raw_date in entries:
        dt = parse_date(raw_date)
        if not dt:
            print(f"! bad date: {raw_date!r} in {url}", file=sys.stderr)
            continue
        if dt >= cutoff:
            label = f"[{author}] {title}" if author else title
            results.append((dt, label, link))
    return results


# Fetch all feeds.
with ThreadPoolExecutor() as pool:
    results = pool.map(fetch_feed, urls)
all_entries = [entry for batch in results for entry in batch]
if not all_entries:
    print(f"No articles in the last {MONTHS} month(s).")
    sys.exit(0)
all_entries.sort(key=lambda e: e[0], reverse=True)

# Prepare list of feed items for selection in fzf, then open the item. Keep the feed
# open: prompt again for selection in fzf after opening item.
lines = [
    f"{date:%Y-%m-%d} {title}\t{url}"
    for date, title, url in all_entries
]
while True:
    result = subprocess.run(
        ["fzf", "--with-nth=1", "--delimiter=\t", "--no-multi"],
        input="\n".join(lines),
        capture_output=True,
        text=True,
        check=False,
    )
    # If we exit fzf, exit this script.
    if result.returncode != 0:
        break
    url = result.stdout.strip().split("\t")[-1]
    webbrowser.open(url)
