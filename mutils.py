#!/usr/bin/env python

"""Misc Utilitis

This is a collection of miscellaneous small utilities which might be useful in day to day scripting.
"""

__version__ = "$Revision$"
# Last Modified on $Date$
# by $Author$
# from $Source$

import logging
import os
import os.path
import sys
import string
import cPickle

tmp = os.getenv('TEMP')
file_name = os.path.basename(sys.argv[0])
pickle_file = os.path.join(tmp, file_name + '.pickle')

def pickle(data):
    with open(pickle_file, 'wb') as f:
        cPickle.dump(data, f)

def unpickle():
    try:
        f = open(pickle_file, 'rb')
        data = cPickle.load(f)
        f.close()
    except IOError:
        data = None

    return data

def internet_available(url='http://www.google.com'):
    """
    Checks whether google.com is reachable.
    Useful for checking internet connectivity.

    >>> internet_available('http://abcdxyzjunk')
    False

    >>> internet_available('file:///dev/null')
    True
    """
    import urllib2

    try:
        urllib2.urlopen(url)
        return True
    except urllib2.URLError:
        return False

def online():
    """Just an alias for internet_available()
    """
    return internet_available()


def fdelete(f):
    """
    Delete a file or directory (even if it is non-empty)
    """

    if os.path.isfile(f):
        log.debug('Deleting File ' + f)
        os.remove(f)

    if os.path.isdir(f):
        log.debug('Deleting Directory ' + f)

        # We can not delete non-empty directories directly. So this ugly code.
        for root, dirs, files in os.walk(f, topdown=False):
            for name in files:
                os.remove(os.path.join(root, name))
            for name in dirs:
                os.rmdir(os.path.join(root, name))
        os.rmdir(f)


def init_logging():
    """
    This function initializes the logging mechanism.

    # Make sure that log object is available
    >>> log #doctest: +ELLIPSIS
    <logging.RootLogger instance at 0x...>
    """

    # argv[0] returns the name of the file that imported this module
    # split removes the .py
    log_filename = string.split(sys.argv[0], '.py')[0] + '.log'

    # Check whether we can write to log file. If not write to stdout.
    try:
        handler = logging.FileHandler(log_filename)
    except IOError:
        handler = logging.StreamHandler(sys.stdout)

    formatter = logging.Formatter('%(asctime)s - '
                                  '%(filename)s:%(lineno)s - '
                                  '%(funcName)s() - '
                                  '%(levelname)s - '
                                  '%(message)s')
    handler.setFormatter(formatter)
    log.addHandler(handler)
    log.setLevel(logging.DEBUG)


if __name__ == '__main__':
    # If invoked as stand-alone script, print this message and exit
    print "Sorry. This is not a stand-alone app. Import this file in your script and call appropriate functions."
else:
    # If invoked by importing in another python script,
    # automatically call init_logging()
    log = logging.getLogger()
    init_logging()
