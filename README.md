# modern.sh

Modern helpers for shell scripting.

----

I end up using a lot of shell scripting for portability and efficiency reasons.
As designed it is great for glue logic. But shell scripting has a lot of gaps.

`modern.sh` fills some of these gaps by providing such capabilities as:

- Including scripts as libraries - and ensuring they're only loaded once
- Compatibility stubs and wrappers to ease development between Linux and BSD-like environments
- Best-practice application of shell commands and features (like `safe_cd`)
- Copious user feedback and visual indicators that are easy to read to aid debugability

Usage
=====

There is almost no boilerplate for your entry script to reliably find `modern.sh.`

If you have `modern.sh` in your path, you're good to start using it with just:

```shell
source "$(which modern.sh)"
```

If you set it up as a library in a relative path and aren't sure where it might end up, then you'll need to do something like this (where `libpath` is the relative path from your script):

```shell
source "$(dirname "${BASH_SOURCE[0]}")/libpath/modern.bash"
```

Pretty much every function is documented in `doc/help.ansi`, just display it in your terminal or an ansi-capable editor to read more:

```shell
cat doc/help.ansi
```

Plans
=====

I've used a lot of these functions for many years, copied from project to project, but this version was extracted from my `blacklight` programming language [build scripts](https://github.com/acook/blacklight/blob/redlight/build/lib/_shared.bash).

While I mainly use `fish` interactively, `modern.sh` currently heavily depends on bash-isms due to it being readily available on all platforms I have come into contact as well as having a decent set of primitives to build on. While that has been a safe assumption for the last couple of decades, it is no longer the case. Making it `zsh` compatible will not be a stretch. Eventually `modern.sh` will grow a deeper compatibility layer to allow it to run on `dash` and `busybox` or similar.

