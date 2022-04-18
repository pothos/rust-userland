# Rust userland container image

A puristic exercise to build a useable Linux container image consisting of
[nuta:nsh](https://github.com/nuta/nsh) as shell (instead of GNU Bash), [uutils:coreutils](https://github.com/uutils/coreutils)
(instead of GNU coreutils), and [BurntSushi:ripgrep](https://github.com/BurntSushi/ripgrep) (instead of GNU grep).
It does not ship a copy of glibc and you are expected to copy static binaries into it.
For convenience a simple text editor is part of the image, currently this is [rhysd:kiro-editor](https://github.com/rhysd/kiro-editor) (but more are possible, please suggest others).

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

- Add more common tools, specially those that are not in coreutils but are expected to usually exist, e.g., `ps`, `sed`, `gzip`, `awk`, `diff`, …
- Maybe also add newer tools written in Rust, such as, `bat`, `cut` and `fd`
- Build for arm64 (currently the Dockerfile has the x86 target hardcoded)
- Try compilation with [relibc](https://gitlab.redox-os.org/redox-os/relibc) or [mustang](https://github.com/sunfishcode/mustang) instead of musl
- Check if the extracted userland also works with [Kerla](https://github.com/nuta/kerla) instead of Linux

PRs welcome ;)

Note: `nsh` is under (re-)development in a new branch but here the default/old branch was used
