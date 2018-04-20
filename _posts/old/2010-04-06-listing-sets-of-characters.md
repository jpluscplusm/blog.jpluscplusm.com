---
category: outdated-blog-posts
---

# Listing Sets Of Characters

How do you empirically determine a file or stream's alphabet? Here's one
(inelegant) way to do it:

`perl -nle 'foreach $c (split //){$w{$c}++;} }{ print(sort keys %w);'`

Here are some examples:

------------------------------------------------------------------------

`user@host$ seq 1 10 | perl -nle 'foreach $c (split //){$w{$c}++;} }{ print(sort keys %w);'`

-   `0123456789`

------------------------------------------------------------------------

`user@host$ echo 'abaaaaaac123;2ddddd,./' | perl -nle 'foreach $c (split //){$w{$c}++;} }{ print(sort keys %w);'`

`,./123;abcd`

------------------------------------------------------------------------

`user@host$ perl -nle 'foreach $c (split //){$w{$c}++;} }{ print(sort keys %w);' ./test_input_file`

`+,-/0123456789:=ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz`

------------------------------------------------------------------------

That last example is an RSA private key, hence the almost-base64 set of
characters it contains.
