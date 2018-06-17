---
category: outdated-blog-posts
title: "Auditing MySQL privileges"
---

A quick'n'dirty way of viewing all the privileges that exist on a MySQL
server is to chain two mysql invocations together like this:

    mysql -B -N -e "SELECT user, host FROM user" mysql | sed 's,\t,"@",g;s,^,show grants for ",g;s,$,";,g;' | mysql -B -N | sed 's,$,;,g'

I'm sure some slight variations of this exist, but this produces some useful
information. Note that this form isn't great from an authentication
perspective; you could use the extremely useful --defaults-file flag to correct
this:

    mysql --defaults-file=my.local.cnf -B -N -e "SELECT user, host FROM user" mysql | sed 's,\t,"@",g;s,^,show grants for ",g;s,$,";,g;' | mysql --defaults-file=my.local.cnf -B -N | sed 's,$,;,g'

Remember that `--defaults-file` has to be used as the first parameter to
MySQL binaries - they simply ignore it if it's not $1.
