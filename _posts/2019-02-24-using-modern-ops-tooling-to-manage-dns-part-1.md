---
title: "Using modern Ops tooling to manage DNS: Part 1"
---

## The Problem

I [recently](https://twitter.com/jpluscplusm/status/1099300667926241282) asked
Ops Twitter for some input on a problem I've been putting off solving for a
while: how can I use nice, modern tooling like Terraform to manage multiple
domain's DNS records?

Now, before we get started: I know how to do this!

I can happily manage a Terraform definition file made up of repeated versions
of resources looking like this:

```
resource "aws_route53_record" "www" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "www.example.com"
  type    = "A"
  ttl     = "300"
  records = ["1.2.3.4, 4.5.6.7"]
}
```

But imagine the situation where one has multiple domains, each with a fair few
records ... that's going to get pretty verbose, pretty quickly.

So what I was asking Ops Twitter was slightly more nuanced: how can I use
Terraform (or equivalent) to manage these records - but **without** having to
manage the resource definitions manually?

## The Solution?

A bunch of folks gave me some pointers and opinions:

- [I noted and unfairly ruled
  out](https://twitter.com/jpluscplusm/status/1099302160104329217)
  StackExchange's [dnscontrol](https://github.com/StackExchange/dnscontrol)
- [Chris Short
  thought](https://twitter.com/ChrisShort/status/1099309482004414464) that
  maybe some templating, possibly inside Ansible, could work
- [Chris Little
  said](https://twitter.com/WhatsChrisDoing/status/1099323149781393408) that
  DIYing some scripts worked for them
- [Spencer Krum pointed
  out](https://twitter.com/nibalizer/status/1099349822707040256) something that
  look perfect, modulo its use of Bind zone files to store the underlying record
  data
- [Aquarion mentioned](https://twitter.com/Aquarion/status/1099442060799758340)
  their DIY Ansible setup to do this
- [Brian Christie pointed
  out](https://twitter.com/theBrc007/status/1099605814371905536) an
  IaaS-management library called [Pulumi](https://github.com/pulumi/pulumi),
  which is available in multiple language and looks to handle a **lot** more than
  just DNS
- [I mentioned](https://twitter.com/jpluscplusm/status/1099650481507442689) the
  [UK Goverment Digital Service's tool in this
  space](https://github.com/alphagov/govuk-dns) which (IMHO!) does *some*
  things slightly oddly, but has some good ideas which I might end up stealing!

Over the next couple of weeks I'm going to take a look at the practicalities of
using each of these. Stay tuned for some more posts in this area ...
