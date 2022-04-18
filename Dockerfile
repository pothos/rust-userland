FROM docker.io/library/debian:11 AS builder
RUN apt-get update && apt-get -y install curl git gcc g++ musl musl-dev musl-tools
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > /ri.sh && chmod +x /ri.sh && /ri.sh -y
RUN bash -c 'source "$HOME/.cargo/env" && rustup target add x86_64-unknown-linux-musl'
RUN cd / && git clone https://github.com/nuta/nsh
RUN bash -c 'source "$HOME/.cargo/env" && cd /nsh && RUSTFLAGS="-C target-feature=+crt-static" cargo build --target x86_64-unknown-linux-musl --release'
RUN cd / && git clone https://github.com/BurntSushi/ripgrep
COPY ripgrep-no-jemalloc.diff /ripgrep/ripgrep-no-jemalloc.diff
RUN git -C /ripgrep apply /ripgrep/ripgrep-no-jemalloc.diff
RUN bash -c 'source "$HOME/.cargo/env" && cd /ripgrep && RUSTFLAGS="-C target-feature=+crt-static" cargo build --target x86_64-unknown-linux-musl --release'
RUN cd / && git clone https://github.com/uutils/coreutils
RUN bash -c 'source "$HOME/.cargo/env" && cd /coreutils && RUSTFLAGS="-C target-feature=+crt-static" cargo build --target x86_64-unknown-linux-musl --release --features feat_os_unix_musl'
RUN cd / && git clone https://github.com/rhysd/kiro-editor
COPY kiro-no-jemalloc.diff /kiro-editor/kiro-no-jemalloc.diff
RUN git -C /kiro-editor apply /kiro-editor/kiro-no-jemalloc.diff
RUN bash -c 'source "$HOME/.cargo/env" && cd /kiro-editor && RUSTFLAGS="-C target-feature=+crt-static" cargo build --target x86_64-unknown-linux-musl --release'

FROM scratch
COPY --from=builder /nsh/target/x86_64-unknown-linux-musl/release/nsh /bin/nsh
COPY --from=builder /coreutils/target/x86_64-unknown-linux-musl/release/coreutils /bin/coreutils
COPY --from=builder /ripgrep/target/x86_64-unknown-linux-musl/release/rg /bin/rg
COPY --from=builder /kiro-editor//target/x86_64-unknown-linux-musl/release/kiro /bin/kiro
COPY passwd /etc/passwd
COPY shadow /etc/shadow
COPY group /etc/group
COPY gshadow /etc/gshadow
RUN ["/bin/coreutils", "ln", "-s", "/bin/nsh", "/bin/sh"]
RUN ["/bin/coreutils", "mkdir", "-p", "/root", "/bin", "/lib", "/etc", "/tmp", "/dev", "/run", "/var/tmp", "/var/log", "/usr"]
ENV PATH=/bin
RUN for NAME in $(coreutils -h | rg -A 999 "Currently defined functions:" | rg -v "Currently defined functions:" | coreutils tr -d "\n" | coreutils tr -d " " | coreutils tr "," " "); do coreutils ln -s /bin/coreutils "/bin/$NAME" ; done
RUN ln -s /bin/rg /bin/grep
RUN ln -s /bin/nsh /bin/bash
RUN ln -s /bin /sbin && ln -s /bin /usr/bin && ln -s /bin /usr/sbin && ln -s /run /var/run
RUN chmod 0644 /etc/passwd /etc/group && chmod 0640 /etc/shadow /etc/gshadow
ENV EDITOR=/bin/kiro
CMD ["/bin/sh", "-l"]
