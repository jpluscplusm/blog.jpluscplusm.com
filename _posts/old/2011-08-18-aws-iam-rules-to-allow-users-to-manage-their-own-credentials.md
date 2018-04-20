---
category: outdated-blog-posts
title: "AWS IAM Rules To Allow Users To Manage Their Own Credentials"
---

# AWS IAM Rules To Allow Users To Manage Their Own Credentials

Amazon's [Identity and Access Management](http://aws.amazon.com/iam/)
(IAM) not only has a funky acronym relating to what it achieves, it's
also pretty handy for controlling access in a
multi-admin/multi-developer context.

I couldn't see an obvious way of allowing a user to control their own
access credentials, however, which is important since I don't want to
have to create, download and distribute what *should* be private data
for each user. I just don't trust myself, as it should be.

It turns out that, whilst there isn't a IAM policy to express "Every
user should be able to manage their own credentials", you can express it
at the individual user level. Sub-optimal, to be sure, but at least it's
possible.

Here's the IAM policy. Apply it with per-user customisations to each
user you want to allow to self-manage. The customisation shouldn't be
too tricky, given that it's an inherently API-driven and scriptable
service. If you're just administrating your IAM policies via the
management console for any decent number of users, you're doing it
wrong!

    { 
      "Statement": [
        { 
          "Action": [
            "iam:CreateAccessKey",
            "iam:DeleteAccessKey",
            "iam:DeleteSigningCertificate",
            "iam:ListAccessKeys",
            "iam:ListGroupsForUser",
            "iam:ListSigningCertificates",
            "iam:UpdateAccessKey",
            "iam:UpdateLoginProfile",
            "iam:UpdateSigningCertificate",
            "iam:UploadSigningCertificate"
          ],
          "Effect": "Allow",
          "Resource": "arn:aws:iam::_ACCOUNTID_:user/_USERID_"
        }
      ]
    }

Just replace `_ACCOUNTID_` and `_USERID_` as appropriate and apply to
each user.
