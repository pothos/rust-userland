FROM docker.io/library/debian:sid AS builder
RUN ln -fs /bin/bash /bin/sh
WORKDIR "/"
RUN apt-get update && apt-get -y install curl git gcc g++ musl musl-dev musl-tools mold
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > ri.sh && chmod +x ri.sh && ./ri.sh -y
RUN source "$HOME/.cargo/env" && rustup target add x86_64-unknown-linux-musl
COPY build.sh /build.sh
RUN /build.sh https://github.com/nuta/nsh
COPY ripgrep-no-jemalloc.diff /ripgrep-no-jemalloc.diff
RUN BIN=rg PATCH=/ripgrep-no-jemalloc.diff /build.sh https://github.com/BurntSushi/ripgrep
RUN /build.sh https://github.com/uutils/coreutils --features feat_os_unix_musl
COPY kiro-no-jemalloc.diff /kiro-no-jemalloc.diff
RUN BIN=kiro PATCH=/kiro-no-jemalloc.diff /build.sh https://github.com/rhysd/kiro-editor
RUN /build.sh https://github.com/sharkdp/bat
RUN /build.sh https://github.com/dalance/procs
RUN BIN=btm /build.sh https://github.com/ClementTsang/bottom
RUN /build.sh https://github.com/ezrosent/frawk --no-default-features
RUN /build.sh https://github.com/chmln/sd
RUN /build.sh https://github.com/sharkdp/fd
RUN /build.sh https://github.com/theryangeary/choose

FROM scratch
COPY --from=builder /rust-bin /bin
COPY passwd /etc/passwd
COPY shadow /etc/shadow
COPY group /etc/group
COPY gshadow /etc/gshadow
RUN ["/bin/coreutils", "ln", "-s", "/bin/nsh", "/bin/sh"]
RUN ["/bin/coreutils", "mkdir", "-p", "/root", "/bin", "/lib", "/etc", "/tmp", "/dev", "/run", "/var/tmp", "/var/log", "/usr"]
ENV PATH=/bin
RUN for NAME in $(coreutils -h | rg -A 999 "Currently defined functions:" | rg -v "Currently defined functions:" | coreutils tr -d "\n" | coreutils tr -d " " | coreutils tr "," " "); do coreutils ln -s /bin/coreutils "/bin/$NAME" ; done
RUN ln -s /bin/rg /bin/grep
RUN ln -s /bin/frawk /bin/awk
RUN ln -s /bin/nsh /bin/bash
RUN ln -s /bin /sbin && ln -s /bin /usr/bin && ln -s /bin /usr/sbin && ln -s /run /var/run
RUN chmod 0644 /etc/passwd /etc/group && chmod 0640 /etc/shadow /etc/gshadow
ENV EDITOR=/bin/kiro
CMD ["/bin/sh", "-l"]
