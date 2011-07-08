#!/usr/bin/env python

import os
import requests
from BeautifulSoup import BeautifulSoup
from logbook import debug, info, warn, error
from logbook import FileHandler
import tumblr

url = 'http://www.vivekananda.org'
blog = 'swamiji.tumblr.com'
username = os.environ['TUMBLR_USERNAME']
password = os.environ['TUMBLR_PASSWORD']


def start_logging(filename):
    this_file = os.path.basename(filename)
    log_file = '/var/log/' + this_file + '.log'

    log_handler = FileHandler(log_file, bubble=True)
    log_handler.push_application()


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
    debug("Publishing to Tumblr")
    api = tumblr.Api(blog, username, password)
    api.write_quote(quote=quote, source="Swami Vivekananda")


def main():
    quote = fetch_quote()
    post_to_tumblr(quote)


if __name__ == "__main__":
    start_logging(__file__)
    main()
