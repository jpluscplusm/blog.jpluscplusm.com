---
category: outdated-blog-posts
title: "A VBS Script To Audit Your IIS(6) Host Headers"
---

# A VBS Script To Audit Your IIS(6) Host Headers

Here's a method to discover what website Bindings (i.e. unique
`IP:port:HostHeader` tuples for anyone not IIS-conversant) an IIS6 instance has
configured.

[This script](/files/iis-bindings-audit.vbs) takes 1 optional parameter - the
resolvable name of the host you want to audit, defaulting to `localhost`. It
outputs a colon-seperated record for each unique
`MachineName:Comment:IISObject-Name:IP:Port:HostHeader` tuple.

I've only used it in a Domain-authenticated context hence can't speak for how
it works in a Workgroup/etc environment when auditing remote hosts. It might
not.

Invoke the script like this: cscript iis-bindings-audit.vbs //NoLogo
\[IIS-Server\] &gt;&gt; output.txt .. with your chosen machine as `IIS-Server`.

You might like to wrap it in a [foreach loop](http://ss64.com/nt/for_f.html) to
audit multiple hosts and aggregate the results. The output format is structured
to allow this aggregate result to be unambiguous when analysed later.
