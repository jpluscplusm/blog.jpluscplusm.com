---
category: outdated-blog-posts
---

# Securing Jenkins behind an nginx reverse proxy

Jenkins comes with an embedded HTTP server, which you can reverse proxy with
nginx - but what do you need to lock down and where do you need to do it?

## The Problem

Here's a demonstration of the ports that Jenkins listens on, out of the box:

    $ java -jar jenkins.war &
    [...time passes...]
    $ netstat -npl | grep java | sort | tr -s ' '
    tcp6 0 0 :::37510 :::* LISTEN 22736/java
    tcp6 0 0 :::49635 :::* LISTEN 22736/java
    tcp6 0 0 :::8009  :::* LISTEN 22736/java
    tcp6 0 0 :::8080  :::* LISTEN 22736/java
    udp6 0 0 :::33848 :::* 22736/java
    udp6 0 0 :::5353  :::* 22736/java

And if we kill java and immediately start it up again (bear with me), here's
the result of those same checks:

    $ java -jar jenkins.war &
    [...time passes...]
    $ netstat -npl | grep java | sort | tr -s ' '
    tcp6 0 0 :::21319 :::* LISTEN 22797/java
    tcp6 0 0 :::59271 :::* LISTEN 22797/java
    tcp6 0 0 :::8009  :::* LISTEN 22797/java
    tcp6 0 0 :::8080  :::* LISTEN 22797/java
    udp6 0 0 :::33848 :::* 22797/java
    udp6 0 0 :::5353  :::* 22797/java

So we have 2 ports that seem to change (tcp/37510/21319 &
tcp/49635/59271), along with the following:

    tcp/8009
    tcp/8080
    udp/33848
    udp/5353

## The Solution

I've chosen to try and disable as many of these listeners as possible,
and to leave HTTP traffic as the sole route into the server. This will
probably cause some problems when bringing slave instances online,
later, but it'll do as a single-node setup until then.

### Predicable Ports

#### tcp/8009

This is the AJP port, used by an alternative protocol to HTTP on Java
servers. Disable it with `--ajp13Port=-1`.

#### tcp/8080

This is the default port that Jenkins (or, rather the embedded Winstone
HTTP server) uses for HTTP traffic. There's nothing wrong with that, per
se, but given that we're going to hide Jenkins behind the more robust
nginx, we probably want to tell Jenkins only to listen on localhost, not
0.0.0.0.

We do this with `--httpListenAddress=127.0.0.1`

Additionally, if you don't have 127.0.0.1:8080 available for Jenkins to
use, the port can be changed with (for example) `--httpPort=9005`.

#### udp/33848

This appears to be some sort of well-known slave-related port which,
after receiving traffic, tell anyone connected the value of one of the
*randomly* selected ports we saw, above. To disable this, we're going to
have to be a bit sneaky, because there isn't a way to disable it at the
CLI (or inside Jenkins config) as far as I could tell.

We make the *essential* assumption here that you're *not* running Jenkins/Java
as root. If you are doing this, please take a refesher class at Sysadmin
School.

In order to disable this listener, we merely have to tell Jenkins it should use
a privileged port below 1024, which will then fail to bind as we're not running
as root. I like to use 1023, since it's so close to 1024 that it can't be a
coincidence, which tells the next Sysadmin looking at this something.
Hopefully.

Do this with `-Dhudson.udp=1023`, but make sure it comes *before* the `-jar
jenkins.war` CLI parameter or it won't work.

#### udp/5353

If your first thought on seeing those "53"s was "DNS?", then give yourself a
cookie. It can be disabled with `-Dhudson.DNSMultiCast.disabled=true`, but only
when placed before the `-jar` parameter.

#### HTTPS

Whilst it doesn't appear Jenkins tries to set up an HTTPS listener out of the
box, that behaviour might change, and might be affected by other configuration
settings in your environment. To definitively disable HTTPS, use
`--httpsPort=-1`.

### Non-deterministic ports

That's the end of the predictable ports. Now for the 2 random ports Jenkins
opens.

Unfortunately, they don't appear to be controlled at the command line, but from
config files and settings. That means you need to run Jenkins once, poke it
slightly to cause it to *create* its config files, and then shut it down and
edit them.

Using the command line we've built up thus far, run Jenkins and wait for it to
say "INFO: Jenkins is fully up and running":

    $ java -Dhudson.DNSMultiCast.disabled=true -Dhudson.udp=1023 -jar \
    jenkins.war --httpListenAddress=127.0.0.1 --httpPort=9005 \
    --ajp13Port=-1 --httpsPort=-1

Now hit the Jenkins web UI on whatever address you've told it to listen on.
Then:

-   Go to "Manage Jenkins"
-   Go to "Configure"
-   Hit the "Save" button at the bottom of the page

Wait a couple of seconds to make sure the config gets written to disk.

Back at the server's CLI, hit Ctrl-C and check Jenkins shuts down.

In your $HOME/.jenkins/ directory, edit the file `config.xml` and change the
setting for `<slaveAgentPort>` from 0 to -1.

Finally, put the following contents into
`$HOME/.jenkins/org.jenkinsci.main.modules.sshd.SSHD.xml`:

    <?xml version='1.0' encoding='UTF-8'?>
    <org.jenkinsci.main.modules.sshd.SSHD>
      <port>-1</port>
    </org.jenkinsci.main.modules.sshd.SSHD>

## The Result

Let's start up Jenkins with these changes, and see what's now listening for
network traffic:

    $ java -Dhudson.DNSMultiCast.disabled=true -Dhudson.udp=1023 -jar \
    jenkins.war --httpListenAddress=127.0.0.1 --httpPort=9005 \
    --ajp13Port=-1 --httpsPort=-1 &
    [...time passes...]
    $ sudo netstat -npl | grep java | tr -s ' ' 
    tcp6 0 0 127.0.0.1:9005 :::* LISTEN 23662/java

Only the single HTTP port, on localhost, that we need for reverse proxying.
Success!

Though you should probably think about putting some authorisation on that [at
the nginx layer](http://wiki.nginx.org/HttpAuthBasicModule#auth_basic) now ...

## References

-   <https://issues.jenkins-ci.org/browse/JENKINS-12731>
-   <http://jenkins-le-guide-complet.batmat.cloudbees.net/html/sect-running-hudson-standalone.html>
