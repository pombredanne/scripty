#!/usr/bin/env python

import os
import requests
from BeautifulSoup import BeautifulSoup
import tumblr

url = 'http://www.vivekananda.org'
blog = 'swamiji.tumblr.com'
username = os.environ['TUMBLR_USERNAME']
password = os.environ['TUMBLR_PASSWORD']

html = requests.get(url).read()

soup = BeautifulSoup(html)
# The quote is enclosed in 'p' tag
p = soup.find('p')
quote = p.text
print "Quote = ", quote

api = tumblr.Api(blog, username, password)
api.write_quote(quote=quote, source="Swami Vivekananda")
