---
category: outdated-blog-posts
title: "Hosting A Chef WebUI and API Behind The Same IP, Port And SSL Certificate"
---

# Hosting A Chef WebUI and API Behind The Same IP, Port And SSL Certificate

[Miguel Cabeç](http://twitter.com/miguelcabeca) emailed the Chef mailing list
describing a great method to host a
[Chef](http://wiki.opscode.com/display/chef/Home) server's API and Web UI
behind the same IP, port and SSL certificate.

With a couple of small changes to Miguel's method, I've found it enables me to
host both services on the same machine and to allow access to both on
<https://chef.example.com/> with automatic detection of which service is being
requested.

Here's the relevant Apache VHost:

------------------------------------------------------------------------

    <VirtualHost 192.168.54.23:443>
     ServerName chef.example.com

     DocumentRoot /var/www/html

     LogLevel warn
     ErrorLog logs/chef.example.com-error.log
     CustomLog logs/chef.example.com-access.log combined

     SSLEngine On
     SSLCertificateFile /etc/pki/tls/certs/chef.example.com/chef.example.com
     SSLCertificateKeyFile /etc/pki/tls/private/chef.example.com/chef.example.com.key
     <Location />
      SSLRequireSSL
     </Location>

     ProxyRequests Off
     <Proxy *>
      Order deny,allow
      Allow from all
     </Proxy>

     RequestHeader set X_FORWARDED_PROTO 'https'

     RewriteEngine On
     # Are we making an API request?
     RewriteCond %{HTTP:X-Ops-Timestamp} .
     RewriteRule ^/(.*) http://localhost:4000/$1 [P,L]
     # No, it's a WebUI request
     RewriteRule ^/(.*) http://localhost:4040/$1 [P,L]

    </VirtualHost>

------------------------------------------------------------------------

This method relies on certain HTTP headers being present in API requests but
not in UI requests. Being X- headers, these *may* change over time as Opscode
find necessary, but I would expect such changes to be flagged up reasonably
clearly as they would break existing API client compatibility.

Don't forget that the Chef server listens on 0.0.0.0:4000 by default, so using
this method doesn't actually *block* unencrypted access.

I'm trying to figure out how to allow this VHost to enable (authenticated)
access to the backend CouchDB instance, but I'm not there yet. Any suggestions
gratefully received!

Update, December 2010: Warwick Poole has translated this config to NginX. IMHO
it's a much lighter-weight to *just* serve API+WebUI than Apache - consider
using it: [Chef WebUI and API Behind The Same IP, Port and SSL Certificate with
NginX](http://warwickp.com/2010/10/hosting-chef-server-behind-nginx-proxy)
