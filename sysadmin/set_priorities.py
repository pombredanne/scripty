#!/usr/bin/env python

import psutil

prio = {
    'nginx': 'HIGH',
    'mysqld': 'HIGH',
    'supervisord': 'HIGH',
    'uwsgi': 'HIGH',
    'php-cgi': 'HIGH',

    'cron': 'LOW',

    'tor': 'VERY_LOW'
}
nice = dict(HIGH=-10, LOW=15, VERY_LOW=19)  # -20 to 19
ionice = dict(HIGH=0, LOW=5, VERY_LOW=7)    # 0 to 7

processes = [p for p in psutil.process_iter() if p.name in prio]

for p in processes:
    old_nice = p.get_nice()
    old_ionice = p.get_ionice().value
    priority = prio[p.name]
    p.set_nice(nice[priority])
    p.set_ionice(psutil.IOPRIO_CLASS_BE, ionice[priority])

    print "%s \n old_nice=%s, new_nice=%s \n old_ionice=%s, new_ionice=%s" % (
        p,
        old_nice, p.get_nice(),
        old_ionice, p.get_ionice().value)

