# Bash-isms: 2 Niche 2 Use

This post serves as an explanation for [a bash-ism I tweeted about recently](https://twitter.com/jpluscplusm/status/1158761376644550657). Hopefully, it also acts as a bit of a warning to folks (like my former sysadmin self!) who think that using as many features of a shell as possible is a good thing, as it leads to shorter scripts ...

## The 1-liner

Here's the code:

```
$ [[ "${!name@a}" == *x* ]]
```

As you can see from [the twitter poll](https://twitter.com/jpluscplusm/status/1158761376644550657) alongside that tweet, the large majority of folks looking at this code *don't know what it does*. Only a very small proportion of folks think they're actually pretty sure they *do* know what it does. However, a pub chat with at least one of these respondents showed their confidence was misplaced!

This isn't to geek-shame **anyone**, of course - the *entire point of this post* is to try and demonstrate that only the *author* of this code should've known better :-)

Personally, I wasn't able to work out what this code does without a good read of the bash manpage, and whilst I would have voted in the poll's "I /might/ understand this" category, I would've been wrong!

## The Explanation

### The "easy" bit

The `[[ ... ]]` wrapper is Bash's built-in test command. This allows the use of conditional operators, like the `==` that's used here. The use of `[[ ... ]]` here, as opposed to the similar-but-different `[ ... ]` command means that the `==` operator is a pattern matching operator, not a strict string-equality operator.

In simple terms, when used inside `[[ ... ]]`, `==` matches strings using the same shell globbing rules which one might use interactively in the shell: `*` and `?` match zero-or-more and one character, respectively.

Give that, we can see that the condition that's being tested here is "does the string output of `"${!name@a}"` contain an `x` character?". But what *does* `"${!name@a}"` equal, and how is it evaluated?

### The first bit I had to hunt around in a manpage to decipher

The key to understanding `"${!name@a}"` is to realise that, unlike many `${...}` bash syntax forms, this one permits -- and indeed relies on -- 2 unrelated syntax forms working when combined in the same `${...}` brackets.

The first is **indirect expansion**, and this applies when the character immediately following the `${` is an exclamation mark.

When Bash's variable indirect expansion kicks in, the variable named between the exclamation mark and the next not-permitted-in-a-variable-name character (i.e. anything *except* a-z, A-Z, 0-9 and underscore) is replaced with its value.

Here's an illustration:

```sh
$ FOO=bar
$ bar="some-value"
$ echo ${FOO}
bar
$ echo ${!FOO}
some-value
$ echo ${bar}
some-value
```

So how does that help us decipher `"${!name@a}"`?

Well, what we now know for sure is that, *before* this line is executed, there must have been some code setting up the variable `name`, and the contents of the `name` variable must be **the name of another variable**. Otherwise this indirect expansion fails immediately under Bash v5:

```
$ echo $BASH_VERSION
5.0.7(1)-release
$ unset FOO
$ echo ${!FOO}
bash: FOO: invalid indirect expansion
$ FOO=bar
$ unset bar
$ echo ${!FOO}

```

... but **fails to fail** under Bash v3:

```
$ echo $BASH_VERSION
3.2.57(1)-release
$ unset FOO
$ echo ${!FOO}

$ echo $?
0
$ FOO=bar
$ unset bar
$ echo ${!FOO}

```

This is our first indication that `[[ "${!name@a}" == *x* ]]` might not be nice portable code!

So before the code in question is evaluated, we've set up `name` to contain the name of another variable. Let's assume it's `foo` for now, so the 2 lines of code we're deciphering are actually ...

```
$ name=foo
$ [[ "${!name@a}" == *x* ]]
```

... which, at this point in our journey, we can rewrite by inlining the indirect expansion thusly:

```
$ [[ "${foo@a}" == *x* ]]
```

The detail of what `foo` actually holds will become clearer as we push onwards ...

### The second bit I had to hunt around in a manpage to decipher

The second Bash-ism in use here is, I'll admit, **utterly** new to me! This is mostly because it's not available in Bash v3 (the latest version shipped with OSX), but also because its simply not a feature I've ever hunted down or needed to use ...

On Twitter, several folks thought that the `@` meant that Bash arrays were in play. I did, too, at first, as arrays aren't a feature I use too often and their syntax *does* involve at signs!

But arrays are uninvolved here. This syntax is sufficiently niche that I'll just quote part of the relevant section of the Bash (v5) manpage:

```
${parameter@operator}
  Parameter transformation.  The expansion is either a transformation of the value of parameter or
  information about parameter itself, depending on the value of operator.  Each operator is a sin-
  gle letter:

  Q      The  expansion  is a string that is the value of parameter quoted in a format that can be
         reused as input.
  E      The expansion is a string that is the value of parameter with backslash escape  sequences
         expanded as with the $'...' quoting mechanism.
  P      The expansion is a string that is the result of expanding the value of parameter as if it
         were a prompt string (see PROMPTING below).
  A      The expansion is a string in the form of an assignment statement or declare command that,
         if evaluated, will recreate parameter with its attributes and value.
  a      The  expansion is a string consisting of flag values representing parameter's attributes.
```

There we are - that final operator looks relevant. We get "a string consisting of flag values representing parameter's attributes".

### Putting the pieces together

We're trying to decipher

```
$ name=foo
$ [[ "${!name@a}" == *x* ]]
```

or 

```
$ [[ "${foo@a}" == *x* ]]
```

which asks the question "does the string consisting of flag values representing foo's attributes contain an x".

Hunting through the Bash v5 manpage for "attributes", we're directed to the section detailing the parameters which the built-in `declare` command takes. From there, we can 

