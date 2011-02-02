#!/usr/bin/env python
#

"""Utility to send email via a third-party smtp server
"""

__version__ = "$Revision$"

from email.MIMEMultipart import MIMEMultipart
from email.MIMEBase import MIMEBase
from email.MIMEText import MIMEText
from email.Utils import COMMASPACE, formatdate
from email import Encoders
import os
import sys
import smtplib

def send_mail(server, username, password, send_from, send_to, subject, text, attach_files=[], verbose=0):
    """
    Logs in to smtp server using username/password and sends email.
    """

    if not (server and username and password and send_to):
        raise ValueError('server, username, password and send_to can not be empty')

    assert type(send_to) == list
    assert type(attach_files) == list

    msg = MIMEMultipart()
    msg['From'] = send_from
    msg['To'] = COMMASPACE.join(send_to)
    msg['Date'] = formatdate(localtime=True)
    msg['Subject'] = subject

    msg.attach(MIMEText(text))

    for f in attach_files:
        part = MIMEBase('application', "octet-stream")
        part.set_payload( open(f,"rb").read() )
        Encoders.encode_base64(part)
        part.add_header('Content-Disposition', 'attachment; filename="%s"' % os.path.basename(f))
        msg.attach(part)

    smtp = smtplib.SMTP(server)
    smtp.set_debuglevel(verbose)

    #gmail needs SSL connection
    if 'gmail' in server.lower():
        smtp.ehlo(user_name)
        smtp.starttls()
        smtp.ehlo(user_name)

    smtp.login(user_name, passwd)
    smtp.sendmail(send_from, send_to, msg.as_string())
    smtp.quit()


def process_cmd_line():
    """
    Reads the command-line options and invokes send_email()

    Example 1:
      smtp_server = "smtp.mail.yahoo.co.in:587"
      smtp_user = "abcd"
      smtp_pass = "abcd_password"
      from_addr = "abcd@yahoo.co.in"
      to_addr = ["xyz@gmail.com"]
      subject = "Test Sub"
      msg = "test message"
      files = ["~/Desktop/file.txt", "/tmp/abcd.zip"]

    Example 2:
      smtp_server = "smtp.gmail.com"
      smtp_user = "abcd@gmail.com"
      smtp_pass = "abcd_password"
      from_addr = "abcd@gmail.com"
      to_addr = ["xyz@gmail.com"]
      subject = "Test Sub"
      msg = "test message"
      files = ["~/Desktop/file.txt", "/tmp/abcd.zip"]

    send_mail(smtp_server, smtp_user, smtp_pass, from_addr, to_addr, subject, msg, files)
    """

    import sys
    from optparse import OptionParser

    parser = OptionParser(version = __version__)
    parser.add_option("-r", "--smtp-server",
                        dest = "smtp_server")
    parser.add_option("-u", "--smtp-user",
                        dest = "smtp_user")
    parser.add_option("-i", "--smtp-pass",
                        dest = "smtp_pass")
    parser.add_option("-f", "--from-addr",
                        dest = "from_addr")
    parser.add_option("-t", "--to-addr",
                        dest = "to_addr",
                        action ="append",
                        default = [])
    parser.add_option("-s", "--subject",
                        dest = "subject")
    parser.add_option("-a", "--attach",
                        dest = "files",
                        action ="append",
                        default = [])
    parser.add_option("-m", "--message",
                        dest = "body")
    parser.add_option("-V", "--verbose",
                        action = "store_true",
                        dest = "verbose")


    (options, args) = parser.parse_args()

    if not options.smtp_server:
        parser.error('SMTP server is missing.')
    elif not options.smtp_user:
        parser.error('SMTP userId is missing.')
    elif not options.smtp_pass:
        parser.error('SMTP password is missing.')
    elif not options.to_addr:
        parser.error('To address is missing.')

    send_mail(options.smtp_server,
              options.smtp_user,
              options.smtp_pass,
              options.from_addr,
              options.to_addr,
              options.subject,
              options.body,
              options.files,
              options.verbose)


if __name__ == "__main__":
    sys.exit(process_cmd_line())
