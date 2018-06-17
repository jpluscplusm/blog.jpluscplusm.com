---
category: outdated-blog-posts
title: "Finding which local subversion working copies have uncommitted changes"
---

If you're anything like me, you leave a load of Subversion working
copies around, having checked them out to work on briefly, checked them
back in, then having forgotten to delete then. Sometimes, of course, we
forget to do the checkin too. Perhaps they're working copies on a server
which is having work done directly on it. Either way, wouldn't it be
nice to have an easy way to find those uncommitted files and working
copies?

Uncommitted files in your home directory: **\* find ~ -type d -name .svn
| sed "s/.svn//" | xargs -L 1 svn status | sort | uniq**\* Uncommitted
files across the entire machine: **\* find
$( ls / | sed -r "/^(dev|proc|sys)$/d;s/^(.*)$///" ) -type d -name .svn
| sed "s/.svn//" | xargs -L 1 svn status | sort | uniq*\*\*

There are some obvious inefficiencies here, but it runs in reasonable
time on both servers and laptops here. Refine it at your leisure ...
