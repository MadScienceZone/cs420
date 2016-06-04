# cs420

A simple little text adventure game showcasing a natural
langauge parser as my term project for CS 420.

This is written in the Grace language, using the C minigrace
implementation.

Build and run with:  

```bash
$ minigrace ifiction.grace
```

Once built, just running 

```bash
$ ./ifiction 
```

should suffice.

This program uses ANSI escape codes in its output.  To suppress
that for displays which don't support them, invoke `ifiction`
with a `-a` option.
