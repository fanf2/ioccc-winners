## To build:

``` <!---sh-->
    make
```

**NOTE**: this entry requires the `X11/Xlib.h` header file and the X11 library to
compile.  For more information see the
FAQ on "[X11](../../faq.html#X11)".

To change the dimensions you can use the `WIDTH` and `HEIGHT` variables when
compiling (default 1024 x 800):

``` <!---sh-->
    make clobber WIDTH=640 HEIGHT=480
```

to make the game 640 x 480. Obviously changing it to non numbers or negative
numbers or too large numbers will cause problems.


There is an alternate version that is based on the author's suggestion to change
a value in order to see a bug that they avoided in their entry. See [Alternate
code](#alternate-code) below.


## To use:

``` <!---sh-->
    ./prog
```


## Try:

``` <!---sh-->
    ./prog
```

Press and hold the Left Arrow key until you turn 90-degrees to the left.

When you see a long tunnel, press the function key F2.

Use the Up, Down, Left and Right keys to change your path.

Press function higher numbered function keys (F3, F4, ...) to go faster.

Press F1 to stop.

Turn 90-degrees to one side.

Press F4 to drill into some blocks for a bit.

Press F1 to stop.

Turn 180-degrees to face the way you came.

Press F2 and navigate back down the new hole until you reach the long tunnel
again.

Press F1 to stop.

etc.

Press the ESC key.


## Alternate code:

The author suggested that one change `q` to `0x82000820000000` instead of
`0x820008202625a0` to see a bug that they avoided, writing:

> To see this bug in action change the assignment above to `q=0x82000820000000`,
and look towards the negative direction of the main tunnel.

This alt version does this for you.


### Alternate build:

``` <!---sh-->
    make alt
```


### Alternate use:

Use `prog.alt` as you would `prog` above.


### Alternate try:

Try locating the issue the author suggested exists.


## Judges' remarks:

You are in a twisty maze blocks, almost all alike.

Those blocks are generated by twisty maze of code blocks, almost all different.

Can you find your way around either and understand where you are?

How many function keys does your keyboard have?  Can you generate very high
number function keys such as F30 or F31?  :-)

_Textures? We don't need no stinking textures._


## Author's remarks:

### What is it?

Just run `./prog` with no arguments on an X11-compatible system. The scenery, though
pseudo-randomly generated should be strangely familiar, especially to those still
in their teenage years. You can navigate using the keyboard arrow keys and the
function keys. Your speed is a linear function of `(n-1)` where `Fn` is the last
function key you have pressed, and you always move in the direction you are
looking at. Be aware that you are probably some kind of a Creeper as is obvious
from looking at the program, hence your movement is destructive to the
environment. So after pressing F12 for warp speed, and moving around randomly,
you might find yourself in a 3D maze of twisty little passages, from which there
is only one Esc(ape) key. Note that in theory if you have a specialty keyboard
with 32 function keys you may even press F31 to reach infinite improbability
drive speed, though the author had never tested this feature. However a hidden
comment in `keysymdef.h` suggests the existence of a mythical Sun Keyboard with 35
function keys :)


### Full disclosure:

This entry, though pretty thoroughly obfuscated, is not entirely original, nor
am I Notch. The inspiration for this entry is a demo code written by the Notch
himself, which was released with the following license: "you may use the code
in here for any purpose in any way you want, at your own risk". That version
will henceforth be referred to as the original. Though the original in itself
was quite nice and rather dense piece of code, it was not written in C, nor
entirely and meticulously obfuscated, a state of things I hopefully rectified.


### Some extra features:

Basing it on the original which already had a wonderful simple and concise ray
casting through a generated voxel world rendering, I added a few tweaks of my
own device:

* Two pass optimized rendering. The program first calculates 1/16 of the output
image by ray casting and then, when possible, uses texture interpolation on the
voxel faces. It speeds up the rendering by at least a factor of 4 on most
scenes, but extra care must be taken when passing rays through the leaves voxels
...
* Fixed a small omission in the original. When you looked though a transparent
leaves voxel, you did not see the leaves at voxel faces that were far from you.
In this version the rendering of those (far face leaves) is correct.
* Window rendering size specified in Makefile.
* Added the keyboard controls for navigation (and destruction).


### Portability issues:

This entry is rather portable I think on modern platforms. It assumes of course
basic X-windows availability. There are several other salient assumptions
though:

* The entry assumes `sizeof(int)==4`. This seems to cover pretty much everything
that supports X-windows so would be broken only on quite ancient machines,
embedded processors, or some big iron 64 bit system where `sizeof(int)=8`.
* The entry assumes the default visual has 24 bit depth (RGB). This seems to be
the case on most X Servers these days.
* The entry, does a thing which is an absolute No-No for X-windows program, i.e.
assuming it knows some numeric values for keysyms defined in `keysymdef.h`. I
have searched far and wide the lord Google's domain, yet was unable to find a
version of the file where those assumptions were broken. This enables the
important support of up to 32 function keys keyboards without spilling over the
size limit, and allows us to use such fun expression for arrow view control as
the following:

``` <!---c-->
    *(a&1?&C:&B)-=(.05 -a/2%2*.1)*!(a-1&4092^3920)
```

### Precision issues:

The entry, on purpose (see the section about SIMD below), does not use enough
bits of precision, so sometimes the ray will miss the intersection of two voxel
faces and push on through. That's why you may notice some noise along close up
voxel edges. Fixing this issue would have taken the entry over the size limit
regrettably.


### Obfuscations:

Well, of course you have all the usual suspects, used for extreme compression,
and such a nice layout: not very informative identifiers, which are being reused
all over the place, some rather gruesome looking expressions, a whole load of
magic constants with apparently no rhyme or reason (including a Lagrange
polynomial), and a message from our friendly Cetaceans. However it also includes
some clever and not so obvious though instructive techniques, to subtly make the
code more magical and efficient, at the same time.

Those techniques are about the use of 64 bit integers in order to do SIMD work,
in a portable way without ever using any SSE/AVX or other non-portable compiler
inline functions! The irony though, is that when compiling the program on modern
X86 architectures indeed SSE/AVX is used for the long longs.  Following is some
obfuscation information, So if you want to play tough, stop reading at this point.


### NOTICE to those who wish for a greater challenge:

**If you want a greater challenge, don't read any further**:
just try to understand the program via the source.

If you get stuck, come back and read below for additional hints and information.


### Portable SIMD programming:

So how is this done? Quite simply by using the whole `long long` arithmetic's
capability. I think the C99 standard assures us that `long long` has at least 64
bits. Most of those bits are unused in normal programs, however here we use them
more wisely. For example, in the inner loop of the program you have the innocent
looking expression `i+=d`. What it does in fact, is a SIMD addition of two
vectors, each with three signed fixed point coordinates, advancing our ray in 3D
space!

To spell it out, the macro producing such vectors is `P`, and the assignment
`q=0x820008202625a0` sets our creeper original position to about `(32.5, 32.5019,
2441.406)`.

Evidently when doing such arithmetics, care must me taken to avoid overflow from
one component to the other, but since our voxel world is a torus of size 64 in
each dimension this hardly matters. A subtle issue, is how to deal with signed
quantities. In the `i+=d` expression above `i` has 3 positive components, but
`d` has arbitrary signed components, as our ray may face in any direction. It
seems things should not work, specially as we defined both `i` and `d` as
`unsigned`!  However notice that the `T` (and `P`) macros convert `float` to
`signed long long`s.

Once sign is extended from a least component into higher bits, it seems at first
to be recipe for disaster, however everything works beautifully, and you get
precise component results when the final accumulation components in `i` are
positive. This only gets broken a bit when the final accumulation has a least
significant negative component. To see this bug in action change the assignment
above to `q=0x82000820000000`, and look towards the negative direction of the main
tunnel.

Similar technique is used on the RGB components so their brightness can be
adjusted simultaneously by the expression: `o=o*b>>8`. Of course some spare bits
are needed between the components, so they are spread in the `long long` and
reordered as RBG.

<!--

    Copyright © 1984-2024 by Landon Curt Noll. All Rights Reserved.

    You are free to share and adapt this file under the terms of this license:

        Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)

    For more information, see:

        https://creativecommons.org/licenses/by-sa/4.0/

-->