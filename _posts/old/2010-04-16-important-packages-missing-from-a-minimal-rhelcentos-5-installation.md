---
category: outdated-blog-posts
title: "Important Packages Missing From A Minimal RHEL/CentOS 5 Installation"
---

# Important Packages Missing From A Minimal RHEL/CentOS 5 Installation

During the installation of a RHEL/CentOS 5.x server, you have the choice
of installing the "Base" group of packages. This group is described as
including "a minimal set of packages. Useful for creating small
router/firewall boxes, for example" and contains a number of packages
that you would absolutely expect to find on a system that will ever have
a human using its shell.

Unfortunately, this isn't all that the Base group includes. It actually
pulls in a fair few packages that don't have any place here (e.g.
conman, ccid), some that are actively server-hostile (e.g. bluez-utils)
and some that - amazingly - default to starting a daemon at boot (e.g.
gpm).

Here is a list of packages included in Base which, IMHO, can be safely
installed after a minimal kickstart or manual installation (i.e. *not*
including Base) and whose presence will not surprise *anyone* using the
machine. This list was generated from the definition of Base in CentOS
5.4.

    acl at bc bind-utils bzip2 crontabs irqbalance logrotate lsof man man-pages mlocate psacct rsync sudo telnet traceroute unzip vixie-cron which words zip

I've left the following two packages out of that list as -- regardless
of how useful they may appear -- they're Redhat-specific, and the first
of them pulls in dependencies such as CUPS. Is that *really* mandated by
the LSB?

    redhat-lsb sos
