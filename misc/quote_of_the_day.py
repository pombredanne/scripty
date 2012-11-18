#!/usr/bin/env python

import os
import requests
from BeautifulSoup import BeautifulSoup
from logbook import debug, info, warn, error
import cofre
from tumblpy import Tumblpy

url = 'http://www.vivekananda.org'
blog_url = 'swamiji.tumblr.com'

t = Tumblpy(app_key=cofre.get('tumblr_app_key'),
            app_secret=cofre.get('tumblr_app_secret'),
            oauth_token=cofre.get('tumblr_oauth_token'),
            oauth_token_secret=cofre.get('tumblr_oauth_token_secret'))


def fetch_quote():
    debug("Fetching the quote")
    html = requests.get(url).text

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
    t.post('post',
           blog_url=blog_url,
           params=dict(type='quote',
                       quote=quote,
                       source='Swami Vivekananda')
          )


def main():
    debug("="*50)
    quote = fetch_quote()
    post_to_tumblr(quote)


if __name__ == "__main__":
    main()