---
title: "Encoding an ASCII-armored key for use as a JSON value"
---

Often, in my role as a YAML-/JSON-engineer, I have to take a key or
certificate or other such "ASCII armored" piece of text, and communicate it as
a JSON value.

This can be *annoyingly* fiddly to do, so here's a quick and easy way to take a
`.pem` or `.crt` file, and insert the correct newline encodings so it can be
wrapped up as a JSON value. This works on OSX/MacOS and Linux without
modification.

Take the following private key:

```
$ cat key
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAoIU8/NChs7ykDiKjjUI8JkWeBQEoeekL9WgdcsGu/AXPgQdF
azgkLiVu70Q4Aalm1rmHkWCX3ke8ibxBngP0AUqbNMtMRi9cjpULfnlEKVJ5TPGi
HBd9MhZSRWTqdDRi0/UmsNnUS84c6r2rNPfIWXFTVlGFlGEL15yA5m260+WLc7Xf
HnvtvwHxYLBwKs1ZH44D+dR+43HB8dtgaV0zn+nnxdTF9727VywJXw==
-----END RSA PRIVATE KEY-----
```

We'd like to represent this in the following format:

```
{ "private_key": "-----BEGIN RSA PRIVATE KEY-----\nMIIEpAIBAAKCAQEAoIU8/NChs7ykDiKjjUI8JkWeBQEoeekL9WgdcsGu/AXPgQdF\nazgkLiVu70Q4Aalm1rmHkWCX3ke8ibxBngP0AUqbNMtMRi9cjpULfnlEKVJ5TPGi\nHBd9MhZSRWTqdDRi0/UmsNnUS84c6r2rNPfIWXFTVlGFlGEL15yA5m260+WLc7Xf\nHnvtvwHxYLBwKs1ZH44D+dR+43HB8dtgaV0zn+nnxdTF9727VywJXw==\n-----END RSA PRIVATE KEY-----\n" }
```

Here's one way of doing this, using only "standard" CLI tools. That means
*no* `jq` or "proper" languages, because sometimes those aren't available.

```
$ ASCII_KEY_VALUE=$(cat key | awk '{print}' ORS='\\n')
$ echo $ASCII_KEY_VALUE
-----BEGIN RSA PRIVATE KEY-----\nMIIEpAIBAAKCAQEAoIU8/NChs7ykDiKjjUI8JkWeBQEoeekL9WgdcsGu/AXPgQdF\nazgkLiVu70Q4Aalm1rmHkWCX3ke8ibxBngP0AUqbNMtMRi9cjpULfnlEKVJ5TPGi\nHBd9MhZSRWTqdDRi0/UmsNnUS84c6r2rNPfIWXFTVlGFlGEL15yA5m260+WLc7Xf\nHnvtvwHxYLBwKs1ZH44D+dR+43HB8dtgaV0zn+nnxdTF9727VywJXw==\n-----END RSA PRIVATE KEY-----\n
$ echo "{ \"private_key\": \"$ASCII_KEY_VALUE\" }" >key.json
$ cat key.json
{ "private_key": "-----BEGIN RSA PRIVATE KEY-----\nMIIEpAIBAAKCAQEAoIU8/NChs7ykDiKjjUI8JkWeBQEoeekL9WgdcsGu/AXPgQdF\nazgkLiVu70Q4Aalm1rmHkWCX3ke8ibxBngP0AUqbNMtMRi9cjpULfnlEKVJ5TPGi\nHBd9MhZSRWTqdDRi0/UmsNnUS84c6r2rNPfIWXFTVlGFlGEL15yA5m260+WLc7Xf\nHnvtvwHxYLBwKs1ZH44D+dR+43HB8dtgaV0zn+nnxdTF9727VywJXw==\n-----END RSA PRIVATE KEY-----\n" }
```

The interesting work happens on the first line, where we ask `awk` to use the
2-character string `\n`, properly escaped, as its output record separator. The
rest of the snippet simply inserts the value into the `key.json` file, and can
be adapted however you need. The only command you need to remember is this:

```
$ cat key | awk '{print}' ORS='\\n'
```

This can be shortened if you're running out of ink, or you're a fan of code
golf:

```
$ awk 1 ORS='\\n' <key
```

Happy JSON'ing!
