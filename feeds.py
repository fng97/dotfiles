#!/usr/bin/env python3

import sys, asyncio, argparse, xml.etree.ElementTree as ET
from urllib.request import Request, urlopen
from urllib.error import URLError
from datetime import datetime, timezone, timedelta
from email.utils import parsedate_to_datetime
from pathlib import Path

BOLD, CYAN, YELLOW, DIM, RESET = (
    "\033[1m",
    "\033[36m",
    "\033[33m",
    "\033[90m",
    "\033[0m",
)
ATOM = "{http://www.w3.org/2005/Atom}"
DATE_FMTS = (
    "%Y-%m-%dT%H:%M:%S%z",
    "%Y-%m-%dT%H:%M:%SZ",
    "%Y-%m-%dT%H:%M:%S.%f%z",
    "%Y-%m-%dT%H:%M:%S.%fZ",
    "%Y-%m-%d %H:%M:%S",
    "%Y-%m-%d",
)

parser = argparse.ArgumentParser(description="Fetch latest posts from RSS/Atom feeds.")
parser.add_argument(
    "--file",
    type=Path,
    default=Path.home() / ".config/feeds.txt",
    help="path to feed file: one URL per line, lines starting with # are ignored",
)
parser.add_argument(
    "--months", type=int, default=1, help="filter posts by number of months back"
)
args = parser.parse_args()

assert args.file.is_file(), f"not found: {args.file}"

cutoff = datetime.now(timezone.utc) - timedelta(days=args.months * 30)
urls = [
    l.strip() for l in open(args.file) if l.strip() and not l.strip().startswith("#")
]

def _fetch(url):
    req = Request(
        url, headers={"User-Agent": "feeds.py/1.0", "Accept-Encoding": "identity"}
    )
    with urlopen(req, timeout=3) as r:
        return r.read()


async def fetch_feed(url, cutoff):
    loop = asyncio.get_running_loop()

    # fetch
    try:
        raw = await loop.run_in_executor(None, _fetch, url)
    except (URLError, OSError) as e:
        print(f"{YELLOW}! fetch failed: {url} ({e}){RESET}", file=sys.stderr)
        return []

    # parse xml
    try:
        root = ET.fromstring(raw)
    except ET.ParseError:
        print(f"{YELLOW}! parse failed: {url}{RESET}", file=sys.stderr)
        return []

    # extract entries — try RSS first, then Atom
    entries = []
    for item in root.iter("item"):
        title = (item.findtext("title") or "").strip()
        link = (item.findtext("link") or "").strip()
        raw_date = (item.findtext("pubDate") or "").strip()
        if title and link and raw_date:
            entries.append((title, link, raw_date))

    if not entries:
        for entry in root.iter(f"{ATOM}entry"):
            title = (entry.findtext(f"{ATOM}title") or "").strip()
            link_el = entry.find(f"{ATOM}link[@rel='alternate']")
            if link_el is None:
                link_el = entry.find(f"{ATOM}link")
            link = (link_el.get("href", "") if link_el is not None else "").strip()
            raw_date = (
                entry.findtext(f"{ATOM}published")
                or entry.findtext(f"{ATOM}updated")
                or ""
            ).strip()
            if title and link and raw_date:
                entries.append((title, link, raw_date))

    if not entries:
        print(f"{YELLOW}! no entries: {url}{RESET}", file=sys.stderr)
        return []

    # parse dates and filter by cutoff
    results = []
    for title, link, raw_date in entries:
        dt = None
        try:
            dt = parsedate_to_datetime(raw_date)
        except Exception:
            for fmt in DATE_FMTS:
                try:
                    s = (
                        raw_date.replace("Z", "+00:00")
                        if "Z" in raw_date and "%z" in fmt
                        else raw_date
                    )
                    dt = datetime.strptime(s, fmt)
                    if not dt.tzinfo:
                        dt = dt.replace(tzinfo=timezone.utc)
                    break
                except ValueError:
                    continue
        if dt and dt >= cutoff:
            results.append((dt, title, link))
    return results


async def main():
    results = await asyncio.gather(*(fetch_feed(url, cutoff) for url in urls))
    all_entries = [entry for batch in results for entry in batch]

    if not all_entries:
        print(f"No articles in the last {args.months} month(s).")
        sys.exit(0)

    all_entries.sort(key=lambda e: e[0], reverse=True)
    print(
        f"{BOLD}{len(all_entries)} articles from the last {args.months} month(s):{RESET}\n"
    )
    for date, title, link in all_entries:
        print(f"{CYAN}{date:%Y-%m-%d}{RESET} {BOLD}{title}{RESET}")
        print(f"{DIM}  {link}{RESET}")


asyncio.run(main())
