---
category: outdated-blog-posts
title: "A Horrible Hack To Install An Architecture-Specific Package Set On RHEL/CentOS"
---

# A Horrible Hack To Install An Architecture-Specific Package Set On RHEL/CentOS

After a two-month absence, here's a disgusting way to install a set of
packages on a RHEL/CentOS machine.

This might be useful where you're concerned that simply installing
`$package` would actually bring in `$package.(x86_64|i386)`. For
example, subversion and curl are packages that display this behaviour.

This not-quite-1-liner isn't suitable for a large package set, or where
there might be problems during install. I'm only using it to get a
standard set of (relatively simple and decoupled) packages onto machines
of variable age (RHEL/CentOS 5.x) that *aren't* under Configuration
Management for one reason or another.

------------------------------------------------------------------------

    PKG="wget ntp openssh-server acl at bc bind-utils bzip2 crontabs curl
    irqbalance jwhois logrotate lsof lynx man man-pages mlocate perl psacct
    rsync subversion sudo telnet traceroute unzip vim-enhanced vixie-cron
    which words zip";

    yum install -y $(echo $PKG | sed -r "s/([-a-zA-Z0-9_+]+)/\1."$(uname \
    -m)"/g") | grep "^No package" | sed -r "s/No package (.+)\."$(uname \
    -m)" available\./\1/" | xargs -r yum --quiet -y install &>/dev/null

    chkconfig gpm off # Damn vim-enhanced ...

------------------------------------------------------------------------

As I said: disgusting. Oh well.
