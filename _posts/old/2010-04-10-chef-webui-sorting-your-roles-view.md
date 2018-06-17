---
category: outdated-blog-posts
title: "Chef WebUI: sorting your roles view"
---

It's not rocket science, but [Antiphase](http://twitter.com/antiphase) just
clued me in to how easily your Roles view (<http://your.chef.server/roles>) can
be sorted. It's a huge time saver, as the unsorted view gets very unwieldy,
very quickly:

    [root@cme0 roles]# diff -u /usr/lib/ruby/gems/1.8/gems/chef-server-webui-0.9.8/app/views/roles/index.html.haml{.orig,}
    --- /usr/lib/ruby/gems/1.8/gems/chef-server-webui-0.9.8/app/views/roles/index.html.haml.orig    2010-10-04 17:56:45.000000000 +0100
    +++ /usr/lib/ruby/gems/1.8/gems/chef-server-webui-0.9.8/app/views/roles/index.html.haml 2010-10-04 17:41:09.000000000 +0100
    @@ -11,7 +11,7 @@
                 %th &nbsp;
                 %th.last &nbsp;
               - even = false;
    -          - @role_list.each do |role|
    +          - @role_list.sort.each do |role|
                 %tr{ :class => even ? "even" : "odd" }
                   %td{:colspan => 2}= link_to(role[0], url(:role, role[0]))
                   %td

Then restart chef-server-webui or equivalent.

\[ Update, December 2010 \]: The file's
`/usr/share/chef-server-webui/app/views/roles/index.html.haml` in 0.9.12
installed from Opscode packages.
