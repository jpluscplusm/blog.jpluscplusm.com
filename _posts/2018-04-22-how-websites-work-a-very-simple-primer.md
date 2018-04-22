---
category: "words-to-get-started"
title: "How websites work: a very simple primer"
---

This is a lightly edited version of a reply I wrote when a forum post asked
some foundational questions about web development. Specifics they asked
included "**what's a server-side language for?**", "**is it the norm to use
some kind of server like Apache?**", and a variety of other things that
prompted me to answer from quite basic principles. I'm including it here as
something I can point at in the future :-)


---


Web browsers consume [Hypertext Markup
Language](https://en.wikipedia.org/wiki/HTML) (HTML) and render it visually
with styling information written in [Cascading Style
Sheets](https://en.wikipedia.org/wiki/Cascading_Style_Sheets) (CSS). They
provide a sandboxed execution environment in which
[JavaScript](https://en.wikipedia.org/wiki/JavaScript) (JS) can run, and can
modify the displayed HTML and CSS, often by making network requests and
changing the displayed page based on the responses it receives.

The browser needs to get this HTML/CSS/JS from somewhere. Whilst this could
simply be "local files on the disk of my computer", that's pretty useless if
you ever want to show the site to someone not sitting at your keyboard.
Instead, along with some other technologies, we use HTTP and DNS.

[Hypertext Transfer
Protocol](https://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol) (HTTP) is
the language used to distribute a website's HTML/CSS/JS. A program which talks
this language, an HTTP server such as Apache or Nginx, listens on a network
socket for HTTP requests from browsers. The machine that the HTTP server
process runs on is often called a web server, despite the confusion this
sometimes brings!

Some of these requests will be for static assets - that is, the content being
requested can be provided directly from a file on disk without any processing.
The answer to a request is called a "response". Examples of responses are
images (photographs as JPEGs, animations as GIFs, etc), HTML, CSS and JS, and
sometimes data. Data is often formatted as
[JSON](https://en.wikipedia.org/wiki/JSON), as it's easy to work with in JS.

When the response is sufficiently complex or customised that it can't be served
identically to everyone who requests it, the HTTP server might be configured
*not* to serve the response directly from a file, but instead it may know about
another process that it should pass the request on to for a customised response.

These processes are, very broadly, also servers, and are often also called web
servers. They run code written in languages such as
[PHP](https://en.wikipedia.org/wiki/PHP),
[Python](https://en.wikipedia.org/wiki/Python_(programming_language)),
[Ruby](https://en.wikipedia.org/wiki/Ruby_(programming_language)),
[Go](https://en.wikipedia.org/wiki/Go_(programming_language)), JS,
[Java](https://en.wikipedia.org/wiki/Java_(programming_language)) and
[C#](https://en.wikipedia.org/wiki/C_Sharp_(programming_language)) to build the
response and pass it back to the browser.

Different people use different languages, but generally don't mix and match
without good reason, due to software maintenance costs and their own (mental)
context switching costs. As always, different languages have their advocates,
who prioritise different factors such as elegance, performance, safety, and
library support, but generally it's a personal choice. Large projects or
companies often have standard languages they ask their developers to use.

The [Domain Name System](https://en.wikipedia.org/wiki/Domain_Name_System)
(DNS) is the glue which browsers use to translate a website's name
(`my-awesome-website.com`) into the type of numeric network address which
computers can use to communicate. By buying that domain, you've rented the
right (from the people who own `.com`) to tell people who ask about
`my-awesome-website.com` or any subdomain like `www.my-awesome-website.com` any
network address you like.  In other words, you can point people who ask their
browser to show them `www.my-awesome-website.com` towards the web server which
knows how to serve your website: the one we've configured above to respond with
static assets and possibly customised ("dynamic") responses.
