---
category: outdated-blog-posts
title: "Scrolling through a file at a readable speed"
---

Sometimes you want to tail or read a file at a speed that you can
distinguish content, or at which your brain can at least spot anomalies.
This script can help you with that.

    user@host:~$ cat bin/slow-scroll 
    #!/bin/bash
    [ "${1}" == "-r" ] && {
        MAX=${2:-0.1}
        while read LINE ; do
            echo ${LINE}
            sleep $(echo ${RANDOM} / 32767 \* ${MAX} | bc -ql)s
        done
    } || {
        SLEEP_TIME=${1:-0.08}
        while read LINE ; do
            echo ${LINE}
            sleep ${SLEEP_TIME}s
        done
    }

------------------------------------------------------------------------

`Usage: slow-scroll [ delay ] | -r [ max-delay ]`

The script outputs a line of its input every `<delay>` seconds.
`<delay>` defaults to 0.08 which I have found to work well for spotting
oddities as a logfile passes by. Pause the output with Ctrl-Z and resume
with `fg`.

If the '-r' flag is given, the delay is randomised between 0 and
`<max-delay>` seconds, which defaults to 0.1. I will say nothing more
about this functionality than point you towards [this
comic](http://jaymz.eu/wp-content/uploads/2010/02/whypeopleseemtohavefreetime.png%20%22A%20comic%22)
from <http://jaymz.eu/>.

The script is optimised for the common case (i.e. not using "-r") hence
the seemingly inefficient code duplication. I don't want a sequence of
subshells spawning if I'm using this on a server, which would be
required if one were to roll the logic into one loop without some flag
variables being set and tested each time through the loop. YMMV.
