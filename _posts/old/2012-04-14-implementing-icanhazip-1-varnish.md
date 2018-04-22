---
category: outdated-blog-posts
title: "Implementing icanhazip #1: Varnish"
---

# Implementing icanhazip #1: Varnish

**NBNB Most of the links in this post are now broken. They worked as described,
but for now you'll just have to use your imagination!**

---

The first in an occasional series of articles on how to implement an
[icanhazip.com](http://icanhazip.com)-style site using different technologies.

Using each technology, I'll give a commented example of how to implement the
basic service, and some additional functionality that might be useful too.

Today: implementing [v.jpcpm.net](http://v.jpcpm.net/) using [Varnish
cache](https://www.varnish-cache.org/). This setup doesn't use Varnish's
awesome caching abilities, nor its reverse-proxy functionality.

Here's a stand-alone config which (apart from the domain name I use) would work
out of the box with a vanilla Varnish 3.0 installation.  Comments are in-line.

    # "vcl_recv" is where we deal with the initial request.

    sub vcl_recv {

    # VHosting in Varnish is still an annoyingly manual if/elseif/elseif/else
    # structure.

      if ( req.http.host == "v.jpcpm.net" ) {

    # In order to deliver content *from* Varnish without touching a backend, we
    # generally need to use the hack of pretending we hit a problem, via the
    # "error" mechanism. We use an unused HTTP response code as a way of
    # communicating our intent to the error handling code. The choice of
    # response code is arbitrary and unimportant - it won't actually be
    # returned to the client

        error 720 "OK";
      }
    }

    # Control is passed to "vcl_error" following our call in "vcl_recv".

    sub vcl_error {

    # If we had more than one type of response originating inside Varnish, we'd
    # be using these pseudo response codes to switch between them.

      if ( obj.status == 720 ) {

    # We don't /really/ want to return a 720. Make it a 200.

        set obj.status = 200;

    # We're implementing a slight extension to the icanhazip functionality: we
    # can also return JSON to ease scripting inside puppet/chef/etc. Initally,
    # let's see if the "json" parameter is set in the request's query-string.

        if ( req.url ~ "[?&]json(?:$|&)" ) {

    # OK, we're returning JSON. We also offer the ability to customise the JSON
    # *key* that's returned, in case we're integrating with software that has a
    # hard-coded idea of how the data will look. Let's check if the "ipkey"
    # query-string parameter is set.

          if ( req.url ~ "[?&]ipkey=[^&]" ) {

    # We'll use the HTTP request header "X" as a temporary variable to hold the
    # key. Varnish doesn't have any concept of variables apart from like this.

            set req.http.X = regsub( req.url, ".*[?&]ipkey=([^&]*)(?:|&.*)$", "\1" );
          } else {
            set req.http.X = "ip_address";
          }

    # Some code out there may have a problem with JSON returned as "text/plain".

          set obj.http.Content-Type = "application/json";

    # "synthetic" is how we originate content inside Varnish. In order to embed
    # newlines and double quotes, we need to use "long" strings, as per
    # https://www.varnish-cache.org/trac/wiki/VCLSyntaxStrings.

          synthetic {"{""} + req.http.X + {"":""} + client.ip + {"" }
    "};
        } else {

    # This is our plaintext response if JSON wasn't requested.

          set obj.http.Content-Type = "text/plain";
          synthetic {""} + client.ip + {"
    "};
        }

    # This pushes the content back to the client without involving any more
    # Varnish logic.

        return(deliver);
      }
    }

This service listens at <http://v.jpcpm.net>. Here are some examples of URIs
that use this service:

-   <http://v.jpcpm.net>
-   <http://v.jpcpm.net?json>
-   [<http://v.jpcpm.net?json&key=ADDRESS>](http://v.jpcpm.net?json&ipkey=ADDRESS)
-   <http://v.jpcpm.net?ipkey=ADDRESS&json>

Next time, we'll look implementing this inside Nginx.
