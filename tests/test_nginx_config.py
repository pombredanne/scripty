#!/usr/bin/env python

""" I will be tweaking Nginx settings frequently. I want to make sure that existing services are not impacted.
"""

import requests
from datetime import datetime

ok = [
    "rmv.ac.in",
    "planet.rmv.ac.in",
    "sis.rmv.ac.in",
    "rkmvucbe.org",
    "shutupandship.com",
    "vivekanandawiki.org",
    "convention.rmv.ac.in/2011",
    "results.rmv.ac.in",
    ]

not_ok = [
    "rmv.ac.in/data/wordpress_rmv.sql",
    "rkmvucbe.org/.hg",
    "planet.rmv.ac.in/.hg",
    ]

assets = [
    "planet.rmv.ac.in/media/css/index.css",
    "shutupandship.com/_static/basic.css",
    "convention.rmv.ac.in/2011/css/reset.css",
    "shutupandship.com/_static/doctools.js",
    "planet.rmv.ac.in/media/js/jquery_lazyload.js",
    ]

ok = ["http://" + link + "/" for link in ok]
not_ok = ["http://" + link  for link in not_ok]
assets = ["http://" + link  for link in assets]


def test_ok():
    for link in ok:
        print "Testing %s" % link
        assert requests.head(link).ok, "%s is not ok" % link


def test_not_ok():
    for link in not_ok:
        print "Testing %s" % link
        assert requests.head(link).status_code == requests.codes.forbidden, "%s is not forbidden" % link


def test_that_www_redirects_to_naked_domain():
    for link in ok:
        www_link = link.replace("http://", "http://www.")
        print "Testing %s" % www_link
        resp = requests.head(www_link)
        assert resp.ok, "%s is not ok" % www_link
        assert link in resp.url, "%s is not %s" % (resp.url, link)
        assert resp.history[0].status_code == requests.codes.moved, "%s is not moved" % www_link


def test_assets():
    # add versioning number to assets
    versioned_assets = []
    global assets
    for link in assets:
        a = link.split(".")
        a.insert(-1, "5454365")
        versioned_link = ".".join(a)
        versioned_assets.append(versioned_link)

    assets = assets + versioned_assets

    for link in assets:
        print "Testing %s" % link
        resp = requests.head(link)
        assert resp.ok, "%s is not ok" % link
        assert resp.headers['content-encoding'] == 'gzip'
        assert resp.headers['content-type'] in ['text/css', 'application/x-javascript']
        assert 'cache-control' in resp.headers
        expires = resp.headers['expires']
        expires = datetime.strptime(expires, "%a, %d %b %Y  %H:%M:%S %Z")
        assert expires.year > 2020, "%s does not have far future expires header" % link



if __name__ == "__main__":
    test_ok()
    test_that_www_redirects_to_naked_domain()
    test_not_ok()
    test_assets()
