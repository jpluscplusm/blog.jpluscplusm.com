---
title: Safely transmitting secret material to an iPhone
---

## tl;dr

Use a CLI QR tool to encode a small-ish amount of secret (key?) material on one machine, and then use a simple built-in tool on an iPhone to get the secret into the iPhone's copy/paste buffer.

## The Problem

I **love** [Working Copy](https://workingcopy.app/), the premier git client for my iPhone and iPad. It's honestly one of my daily drivers, and a huge help with my move to git-ops'ing most of my personal projects. It can connect to pretty much any git host, via SSH, but has special support for GitHub and BitBucket.

But ([currently!](https://twitter.com/WorkingCopyApp/status/1270450915372392448)) the app can only generate 4096-bit RSA SSH keys, instead of the Ed25519 standard which [we should all be aiming use where we can](https://blog.g3rt.nl/upgrade-your-ssh-keys.html). Interestingly, though, the app can **import and use** an Ed25519 key, once it's present on the iOS device.

## The Solution

So one day while I was upgrading my SSH keys everywhere, I figured out a way to transmit an Ed25519 private key from a device which can generate them securely (i.e. no random "iPhone keygen" apps!) to my iPhone. This works with both devices being offline which, whilst not a complete guard against malicious apps or actors, is a nice baseline.

### Key generation

Use a modern-ish `ssh-keygen` to create an Ed25519 key pair. Use a decent passphrase, as you'll only have to enter it a single time, once your private key reaches your iPhone - not every time you use the key.

```
~/tmp/new-key$ ssh-keygen -f for-my-iphone -t ed25519 -a 100
Generating public/private ed25519 key pair.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in for-my-iphone.
Your public key has been saved in for-my-iphone.pub.
The key fingerprint is:
SHA256:1fxX/aWlx7ssyk2Lw6K9h8PxDCjHYZIfct0wumbKbXw user@host
The key's randomart image is:
+--[ED25519 256]--+
|                 |
|         o o    .|
|      . o = o   =|
|     + * o . . =+|
|      B S     + =|
|     . O o     o.|
|    . O . B  . . |
|     o +.E.*+.o .|
|      ..oo=+oo.o |
+----[SHA256]-----+
~/tmp/new-key$ ls -l
total 8
-rw------- 1 user user 464 Jun 10 12:12 for-my-iphone
-rw-r--r-- 1 user user  91 Jun 10 12:14 for-my-iphone.pub
```

Notice that, despite the use of the currently recommended 100 rounds (`-a 100`) of key encryption passes, the sizes of the private key and *especially* the public key are pretty damn small. This will help us later, given that the encoding method I'll be describing tops out at about 2800 bytes.

### QR code generation and display

I use a CLI tool called [qrterminal](https://github.com/mdp/qrterminal) to generate a QR code and display it at the command line. I like that it's a single, *relatively* small binary.

On the same machine you generated the SSH key, [download the appropriate binary](https://github.com/mdp/qrterminal/releases/latest) for your operating system and make it executable.

Now is the time to take your machine offline, if that security safeguard feels right for you. Doing so will also prove to you that transmission of the SSH key secret material isn't reliant on internet- or network-based services and that, to a reasonable degree of surety, the tools I'm proposing you use aren't maliciously trying to exfiltrate your data.

Now point the tool at your private key:

```shell
~/tmp/new-key$ qrterminal -l L -- "$(<for-my-iphone)"
[ QR code displayed .... ]
```

You might have to reduce your font size *signficantly* to avoid line wrapping the QR code and display it properly, as a recognisable QR code. As an example, notice how small the qrterminal invocation is at the top of this screenshot from when I ran this:

![A QR code being generated and displayed at the command line](/images/2020-06-10-new-key-qr.png)

### QR code scanning

#### Using the built-in iPhone Camera app

You might know that the iPhone's Camera app, at least with later versions of iOS, has built-in QR code scanning.  Unfortunately, whilst this is true and the contents of the private key are recognised accurately, the only option that iOS gives the user is to search the web for the content it scanned, in Safari.

Now, if you choose this option while making sure the iPhone is in airplane mode, then the key content *does* become available for copying in Safari's address bar. And though the offline mode ensures that the key isn't instantly leaked to whichever search engine you have configured, I personally don't trust that it's not logged somewhere: for iCloud sync'ing; for later retrying when the phone's back online; to populate auto-complete lists; etc.

Also, the process of asking Safari to search for it, then copying it from the address bar removes essential line breaks from the private key, changing it just enough to make it impossible to import into Working Copy. If you're perhaps reusing this method to transmit something other than a private key (maybe a password, or something where line breaks aren't important) then, depending on your security posture, this may be acceptable to you. If so, you can now:

- enable Airplane mode on your iPhone
- point the iOS camera app at the QR code
- choose "Search the Web" when it appears
- select the address bar's contents
- copy it all to the iPhone's copy/paste buffer
- ... and do whatever you need with the secret material.

If not, however, read on.

#### Using the built-in Shortcuts app

Open the built-in app "Shortcuts". [ I'm pretty sure it's built-in. If it's not, it's *definitely* an Apple app, so should be both free and known-not-malicious - install it from the App Store. ]

Create a new Shortcut, and add these 3 steps:

- "Scan QR/Barcode"
- "Get Text from Input"
- "Copy to Clipboard"

Save the Shortcut, and give it a name. Here, I've called it "QR Data Copy":

![An iPhone screenshot of 3 steps in a Shortcut](/images/2020-06-10-new-iphone-shortcut-steps.png)

Enable Airplane mode on your iPhone.

Run the Shortcut, and point the camera at the QR code. If it doesn't recongise the QR code, make sure you've only reduced your terminal's screen size *just* enough so that the QR code fills the screen. Any smaller, and you're increasing the chances of information being missed or mis-scanned.

Once the camera disappears, you have the private key contents in your copy/paste buffer. Remember that this buffer is available to apps, so perhaps don't open any *other*, random apps before finishing this import and clearing the buffer ...

### Importing the private key into Working Copy

Open Working Copy.

Navigate through Settings, to SSH Keys. Hit the + sign to add a key, and select "Import from Clipboard".

Enter the same passphrase you used to protect the key when you created it. You won't ever need to tell Working Copy this passphrase again.

Finally, clear the copy/paste buffer by re-running the Shortcut and pointing your camera at this QR code:

![A QR code with some innocuous contents to clear a copy/paste buffer](/images/2020-06-10-wipe-copy-paste-buffer.png)

And that's it - you're done! You can now teach services like GitHub and BitBucket the public half of the key you generated above, and your Working Copy app can authenticate to them via SSH.

You might consider deleting the private key entirely, as good security practise suggests not to reuse that key anywhere, and to limit it to your iPhone. YMMV.
