---
title: "Fixing mistakes in git history"
---

I **love** pairing! It turns what can, at times, be an isolating and
frustrating job into a genuine pleasure to do for 8 hours a day.  It's also a
great opportunity to learn from your pair, both at an architectural, high
level, but also at the "oh, I never knew there was a way to do [that]" level.

This week, I had a great experience of the second of those. I learned a thing
from [my colleague Hector](https://twitter.com/thekeymon) and I thought I'd
write about it to understand it better.

---

How often have you done something like this?

```bash
$ vim sums.txt
$ git add -N sums.txt
$ git diff
diff --git a/sums.txt b/sums.txt
index e69de29..d4a3d29 100644
--- a/sums.txt
+++ b/sums.txt
@@ -0,0 +1,4 @@
+1+1=2
+2+2=4
+4+4=9
+8+8=16
$ git add sums.txt
$ git commit -m "Some basic sums"
[master 75be084] Some basic sums
 1 file changed, 4 insertions(+)
 create mode 100644 sums.txt
$ vim sums.txt
$ git diff
diff --git a/sums.txt b/sums.txt
index d4a3d29..02baf4a 100644
--- a/sums.txt
+++ b/sums.txt
@@ -2,3 +2,6 @@
 2+2=4
 4+4=9
 8+8=16
+16+16=32
+32+32=64
+64+64=128
$ git add sums.txt
$ git commit -m "Some harder sums"
[master 54ef7d6] Some harder sums
 1 file changed, 3 insertions(+)
$ cat sums.txt
1+1=2
2+2=4
4+4=9
8+8=16
16+16=32
32+32=64
64+64=128
$ # AAAAAARRRRRRGGGHHHH I got a sum wrong, right at the start :-(
$ vim sums.txt
$ git diff
diff --git a/sums.txt b/sums.txt
index 02baf4a..3d37ec7 100644
--- a/sums.txt
+++ b/sums.txt
@@ -1,6 +1,6 @@
 1+1=2
 2+2=4
-4+4=9
+4+4=8
 8+8=16
 16+16=32
 32+32=64
$ git add sums.txt
$ git commit -m "Fix one of the basic sums"
[master 74611fb] Fix one of the basic sums
 1 file changed, 1 insertion(+), 1 deletion(-)
$ git log --oneline -3
74611fb (HEAD -> master) Fix one of the basic sums
54ef7d6 Some harder sums
75be084 Some basic sums
```

So, I've introduced **and committed** a mistake, and have moved on **and
committed** my next piece of work before noticing my mistake. My git history is
just that little bit more messy than it needs to be ...

If I'm not happy to leave my git history in this state (and if I've not pushed
this code to a remote branch *which other people are consuming*) then I have a
few options. Most of them involve some non-basic level of git-ism which,
frankly, I can never remember, so I end up having to look it up each time.

Fortunately, there's a better way! Enter `--fixup` and `--autosquash` ...

---

Once I've noticed I made a mistake, if I introduced the mistake **in the last
commit**, then fixing this is easy: [OhShitGit has you
covered](http://ohshitgit.com/#change-last-commit).

But, here, I've already committed again, introducing at least one "good" commit
between my mistake and "now".

Git has 2 complementary options you can give to `git commit` and `git rebase`.
They translate into English as "mark [this] commit as a fix to [this other]
commit" and "merge the 'fix' commit into the commit that it fixes". Here's an
example of me using them in the same scenario as above:

```bash
$ vim sums.txt
$ git add -N sums.txt
$ git diff
diff --git a/sums.txt b/sums.txt
index e69de29..d4a3d29 100644
--- a/sums.txt
+++ b/sums.txt
@@ -0,0 +1,4 @@
+1+1=2
+2+2=4
+4+4=9
+8+8=16
$ git add sums.txt
$ git commit -m "Some basic sums"
[master 220379e] Some basic sums
 1 file changed, 4 insertions(+)
 create mode 100644 sums.txt
$ vim sums.txt
$ git diff
diff --git a/sums.txt b/sums.txt
index d4a3d29..02baf4a 100644
--- a/sums.txt
+++ b/sums.txt
@@ -2,3 +2,6 @@
 2+2=4
 4+4=9
 8+8=16
+16+16=32
+32+32=64
+64+64=128
$ git add sums.txt
$ git commit -m "Some harder sums"
[master 299a605] Some harder sums
 1 file changed, 3 insertions(+)
$ # AAARGHHH I noticed my mistake
$ vim sums.txt                  # I corrected it here, as before
$ git add sums.txt
$ git log --oneline -4
6452cd9 (HEAD -> master) fixup! Some basic sums
299a605 Some harder sums
220379e Some basic sums         # "220379e" contains the mistake
edd2f82 initial commit          # "edd2f82" is my last "known-good" commit
$ git commit --fixup 220379e
[master 6452cd9] fixup! Some basic sums
 1 file changed, 1 insertion(+), 1 deletion(-)
$ git rebase --autosquash -i edd2f82
# the editor shows me this, and I save and quit without changing anything:
#  1 pick 220379e Some basic sums
#  2 fixup 6452cd9 fixup! Some basic sums
#  3 pick 299a605 Some harder sums
Successfully rebased and updated refs/heads/master.
$ git log --oneline
8b81491 (HEAD -> master) Some harder sums
aa978d2 Some basic sums
edd2f82 initial commit
$ cat sums.txt
1+1=2
2+2=4
4+4=8
8+8=16
16+16=32
32+32=64
64+64=128
```

So, as soon as I noticed my mistake, I did the following:

- I fixed the mistake in the file where I'd made it
- I `git add`'ed just that small fix
- I `git commit`'ed that addition, telling git which commit this was fixing with `--fixup [commit]`
- I interactively rebased, telling git about the last commit which I wanted to keep as-is
- I accepted git's rebase ordering suggestion, where it had:
  - moved the fixup commit immediately after the commit it fixes
  - suggested that we "fixup" that commit, which removes it from the log whilst
    merging its *content* into the previous (mistake-introducing) commit

As with any rebase, any commits since (but not including) the commit I told git
about with `git rebase -i [commit]` are liable to be changed. This means you'll
need to force push **iff you'd already git-pushed this history somewhere**, and
you'll annoy your colleagues if any of them are pulling from this branch!

---

I'm *far* from the first person to write about this nice workflow. Here's [a
good write up I found about this fixup/autosquash
feature](https://fle.github.io/git-tip-keep-your-branch-clean-with-fixup-and-autosquash.html).

Using the `git add -N|--intent-to-add` feature is very handy for being able to
see what new content new files are introducing - [I learned about it
here](http://www.nadiaodunayo.com/writing/2018/05/28/tell-git-your-intentions)
from [Nadia](https://twitter.com/nodunayo).

Hector has a git alias for using this workflow which, whilst powerful and
convenient, is a *little* shotgun-esque ... you could definitely shoot your foot
off if you're not careful! It's [here on
github](https://github.com/keymon/dotfiles/blob/master/.gitconfig#L84)

