---
title: Securing secrets in git using gocryptfs
date: 2020-08-04
---

This article describes how to use [the encrypted overlay filesystem called gocryptfs](https://nuetzlich.net/gocryptfs/) on top of a git repository, in order to secure access to the contents of that git repository. This works by storing only the filesystem's encrypted contents in the repository.

This can be useful when combined with an untrusted or public git host (such as [GitHub](https://github.com/), [Bitbucket](https://bitbucket.org/), [GitLab](gitlab.com) and [gitern](https://gitern.com/)), or when the rules of your organsation, industry or team need you to be able to say "yes, our secrets are encrypted at rest, and they're useless to anyone who manages to get a copy of our repository".

## What this article covers

After an [introduction to gocryptfs](#gocryptfs-and-some-of-its-features) and some of its features, we'll look at [the out-of-the-box experience when using gocryptfs on top of git](#using-gocryptfs-on-git-with-no-customisation). For certain circumstances and users, this *might* be all you need to implement.

Then we'll evolve that experience, highlighting [the specific problems we're solving](#problems-we-can-solve) along the way towards the best setup we can achieve today. We'll highlight which of the individual problem-solving techniques can be used by themselves, and which have dependencies which require them to be built on top of each other. We'll also look at some [problems that aren't currently solveable](#problems-we-cant-solve).

Finally, we'll return to the out-of-the-box experience, and [review the overall improvements](#comparing-our-best-case-solution-to-the-initial-experience) we've made.

### This article does **not** cover:

(click a heading to display the rationale for the omission)

<details>
<summary><strong>Using git on top of an overlay filesystem</strong></summary>
This article doesn't discuss using git inside an overlay filesystem (such as gocryptfs); a setup we'll call "overlay-then-git". This article *does* use those same components, but in the opposite order: with gocryptfs sitting on top of git; a setup we'll refer to as "git-then-overlay". The "overlay-then-git" concept can be part of a solution to the problem of your laptop being stolen and how to make sure the thief can't access your data. "Git-then-overlay" helps to solve this article's headline problem of protecting your repository contents against the git host itself, or against someone who attacks the git host directly.
</details>
&nbsp;  

<details>
<summary><strong>Encrypting only certain files in your repository</strong></summary>
This article results in a repository which has its entire contents encrypted, so is best suited to a setup involving a dedicated "secrets" repository. However, there's nothing fundamental that stops the use of the method described herein with any repository, including those containing no secrets at all.
</details>
&nbsp;  

<details>
<summary><strong>Giving certain people access to certain encrypted files, and other people access to other files</strong></summary>
To access a Gocryptfs-encrypted filesystem a user requires a key, and a password to unlock that key. From the moment a Gocryptfs filesystem is created, there exists only one key that grants access to the unencrypted contents. There may exist multiple encodings of that key, stored in configuration files locked by different passwords. Every configuration file and password combination that exists (for a given filesystem) ultimately produces the same key, and therefore grants access to the same, complete set of files. A configuration file and password must be shared with every individual or machine that needs to access the contents of the filesystem; Gocryptfs does not offer any mechanism to distinguish access, except for denying access to people not ultimately in possession of the filesystem's key.

There are ways to layer a Gocryptfs filesystem inside another Gocryptfs filesytem, which could could introduce a concept of priviledge separation and escalation, but they are not discussed here. If you are faced with a situation where this limitation affects you, you might find it sufficient to create multiple *non-overlapping* encrypted fileystems (i.e. *not* layered on top of each other), each with a different key and password. This could be achieved by implenting the mechanisms described in this article multiple times across different repositories.
</details>
&nbsp;  

<details>
<summary><strong>Auditing access to secrets</strong></summary>
Once a user has access to an encrypted Gocryptfs filesystem, a configuration file containing the key that unencrypts the filesystem, and a password which unlocks that key, then their access to those secrets is unrestricted and not auditable *by the tools described in this article*. It is possible to build such audit capability on top of these tools, but doing so is not simple, and is out of scope here. NB This does not mean that it's impossible to track who *changes* those secrets: tracking the contents of the encrypted filesystem, and potentially who modified the contents, is pretty much the entire *reason* behind this article!
</details>
&nbsp;  

<details>
<summary><strong>Providing cross-platform access to encrypted files</strong></summary>
Both macOS and Windows have ways to access Gocryptfs filesystems. MacOS access is via [FUSE for macOS](https://osxfuse.github.io/) and Windows is via [cppcryptfs](https://github.com/bailey27/cppcryptfs). Neither has been tested for this article, with or without the git integration described here. If success or failures of the mechanisms described here are reported, this article will be updated to reflect them - please do feel free to test on either OS and [get in touch with the author](https://twitter.com/jpluscplusm) to let them know. Of particular interest are the interoperability concerns of accessing filesystems stored in git (the purpose of this article) on both Linux and another OS, sequentially.
</details>
&nbsp;  

<details>
<summary><strong>Providing simultaneous multi-user access to a single point of truth</strong></summary>
This article doesn't cover a single encrypted filesystem being accessed by multiple people at once. There's nothing to stop this working, but the number of different scenarios involved when safely storing and modifying the filesystem in git is prohibitative to describe.
</details>
&nbsp;  
 
## Gocryptfs and some of its features

## Using Gocryptfs on git with no customisation

Here's 

## Problems we can solve

## Problems we can't solve

### Key rotation versus password rotation

###

## Comparing our best-case solution to the initial experience

### Our complete setup



