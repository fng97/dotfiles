#!/usr/bin/env python3

import sys, argparse, subprocess, xml.etree.ElementTree as ET
from concurrent.futures import ThreadPoolExecutor
from urllib.request import Request, urlopen
from urllib.error import URLError
from datetime import datetime, timezone, timedelta
from email.utils import parsedate_to_datetime
from pathlib import Path

parser = argparse.ArgumentParser(
    description="""Fetch latest articles/videos from feeds. Pick an entry via fzf: blogs
    open in the browser, YouTube videos download and play in mpv.""",
)
parser.add_argument(
    "--file",
    type=Path,
    default=Path.home() / ".config/feeds.txt",
    help="path to feed file: one URL per line, # comments supported",
)
parser.add_argument(
    "--months", type=int, default=1, help="filter posts by number of months"
)
args = parser.parse_args()
assert args.file.is_file(), f"not found: {args.file}"
cutoff = datetime.now(timezone.utc) - timedelta(days=args.months * 30)
urls = [
    l.split("#")[0].strip()
    for l in open(args.file)
    if l.strip() and not l.strip().startswith("#")
]


def fetch_feed(url, cutoff):
    try:
        request = Request(url, headers={"User-Agent": "feeds.py/1.0"})
        with urlopen(request, timeout=3) as r:
            raw = r.read()
    except (URLError, OSError) as e:
        print(f"! fetch failed: {url} ({e})", file=sys.stderr)
        return []

    # parse xml
    try:
        root = ET.fromstring(raw)
    except ET.ParseError:
        print(f"! parse failed: {url}", file=sys.stderr)
        return []

    # extract entries — try RSS first, then Atom
    entries = []
    chan_author = (root.findtext(".//channel/title") or "").strip()
    for item in root.iter("item"):
        title = (item.findtext("title") or "").strip()
        author = (
            item.findtext("author")
            or item.findtext("{http://purl.org/dc/elements/1.1/}creator")
            or chan_author
        ).strip()
        if author:
            title = f"[{author}] {title}"
        link = (item.findtext("link") or "").strip()
        raw_date = (item.findtext("pubDate") or "").strip()
        if title and link and raw_date:
            entries.append((title, link, raw_date))

    if not entries:
        ATOM = "{http://www.w3.org/2005/Atom}"
        feed_author = (
            root.findtext(f"{ATOM}author/{ATOM}name")
            or root.findtext(f"{ATOM}title")
            or ""
        ).strip()
        for entry in root.iter(f"{ATOM}entry"):
            title = (entry.findtext(f"{ATOM}title") or "").strip()
            author = (entry.findtext(f"{ATOM}author/{ATOM}name") or feed_author).strip()
            if author:
                title = f"[{author}] {title}"
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
        print(f"! no entries: {url}", file=sys.stderr)
        return []

    # parse dates and filter by cutoff
    results = []
    for title, link, raw_date in entries:
        dt = None
        try:
            dt = parsedate_to_datetime(raw_date)
        except Exception:
            try:
                dt = datetime.fromisoformat(raw_date)
            except ValueError:
                pass
        if dt and not dt.tzinfo:
            dt = dt.replace(tzinfo=timezone.utc)
        if dt and dt >= cutoff:
            results.append((dt, title, link))
    return results


with ThreadPoolExecutor() as pool:
    results = pool.map(lambda url: fetch_feed(url, cutoff), urls)
all_entries = [entry for batch in results for entry in batch]

if not all_entries:
    print(f"No articles in the last {args.months} month(s).")
    sys.exit(0)

all_entries.sort(key=lambda e: e[0], reverse=True)

lines = [
    f"{date:%Y-%m-%d} {'▶' if 'youtube.com/' in url else ' '} {title}\t{url}"
    for date, title, url in all_entries
]

while True:
    result = subprocess.run(
        ["fzf", "--with-nth=1", "--delimiter=\t", "--no-multi"],
        input="\n".join(lines),
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        break
    url = result.stdout.strip().split("\t")[-1]
    title = result.stdout.strip().split("\t")[0].split("  ", 1)[-1]

    if "youtube.com/" in url:
        subprocess.run(["mpv", url])
    else:
        subprocess.run(["open", url])
