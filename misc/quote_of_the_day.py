#!/usr/bin/env python

import os
import requests
from BeautifulSoup import BeautifulSoup
from logbook import debug, info, warn, error
import tumblr
import cofre

url = 'http://www.vivekananda.org'
blog = 'swamiji.tumblr.com'

username = cofre.get('tumblr_username')
password = cofre.get('tumblr_password')


def fetch_quote():
    debug("Fetching the quote")
    html = requests.get(url).read()

    soup = BeautifulSoup(html)
    # The quote is enclosed in 'p' tag
    p = soup.find('p')
    quote = p.text

    debug("Quote = %s" % quote)
    return quote


def post_to_tumblr(quote):
    if 'Microsoft' in quote:
        return
    debug("Publishing to Tumblr")
    api = tumblr.Api(blog, username, password)
    api.write_quote(quote=quote, source="Swami Vivekananda")


def main():
    debug("="*50)
    quote = fetch_quote()
    post_to_tumblr(quote)


if __name__ == "__main__":
    main()
