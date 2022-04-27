# Rust userland container image

A puristic exercise to build a useable Linux container image consisting of
[nsh](https://github.com/nuta/nsh) as shell (instead of GNU Bash), Rust [coreutils](https://github.com/uutils/coreutils)
(instead of GNU coreutils), [ripgrep](https://github.com/BurntSushi/ripgrep) (instead of GNU grep), and [frawk](https://github.com/ezrosent/frawk) (instead of GNU awk).

As incompatible alternative to `ps` there is [procs](https://github.com/dalance/procs), for `top` there is [bottom](https://github.com/ClementTsang/bottom) (`btm`), for `sed` there is [sd](https://github.com/chmln/sd), for `find` there is [fd](https://github.com/sharkdp/fd). It also ships [bat](https://github.com/sharkdp/bat) as improvement over `cat` and [choose](https://github.com/theryangeary/choose) as improvement over `cut`.
For convenience a text editor is part of the image, currently this is [kiro-editor](https://github.com/rhysd/kiro-editor) (but more are possible, please suggest others).

It does not ship a copy of glibc and you are expected to copy static binaries into it.

## Usage

From the prebuilt image:

```
docker run --rm -it ghcr.io/pothos/rust-userland:main
```

From a locally built image:

```
make
docker run --rm -it rust-userland
```

## TODO

- Add more common tools, specially those that are not in coreutils but are expected to usually exist, e.g., `ps`, `sed`, `gzip`, `diff`, `less`, `find`, `ip` (and others from iproute2), `mount` (and others from util-linux), `curl`, `wget`, … (maybe wrappers around `procs`/`sd`/`fd` could help)
- Add more new tools written in Rust that provide similar/valuable functionality but aren't a drop-in (some already included)
- Try compilation with [relibc](https://gitlab.redox-os.org/redox-os/relibc) or [mustang](https://github.com/sunfishcode/mustang) instead of musl
- Check if the extracted userland also works with [Kerla](https://github.com/nuta/kerla) instead of Linux

PRs welcome ;)

Note: `nsh` is under (re-)development in a new branch but here the default/old branch was used

Note: `frawk` has a different regex format than `awk`
