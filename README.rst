
This package contains scripts to automate various day to day tasks.

Guidelines for Developers
=================================

* Always keep the firstline of the script as
    #!/usr/bin/env python
    or
    #!/usr/bin/env bash

* Put these three lines in every script
    # Version = $Revision$
    # Last Modified on $Date$
    # By $Author$
    # $Source$

* For Bash scripts, get the log file name as
    LOG="/var/log/`basename $0`.log"

* To redirect all stdout and stderr to LOG
    exec >> $LOG 2>&1


