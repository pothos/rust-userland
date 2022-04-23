FROM docker.io/library/debian:11 AS builder
RUN ln -fs /bin/bash /bin/sh
WORKDIR "/"
RUN apt-get update && apt-get -y install curl git gcc g++ musl musl-dev musl-tools
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > ri.sh && chmod +x ri.sh && ./ri.sh -y
RUN source "$HOME/.cargo/env" && rustup target add x86_64-unknown-linux-musl
RUN git clone https://github.com/nuta/nsh && cd nsh && source "$HOME/.cargo/env" && RUSTFLAGS="-C target-feature=+crt-static" cargo build --target x86_64-unknown-linux-musl --release
COPY ripgrep-no-jemalloc.diff /ripgrep-no-jemalloc.diff
RUN git clone https://github.com/BurntSushi/ripgrep rg && cd rg && git apply /ripgrep-no-jemalloc.diff && source "$HOME/.cargo/env" && RUSTFLAGS="-C target-feature=+crt-static" cargo build --target x86_64-unknown-linux-musl --release
RUN git clone https://github.com/uutils/coreutils && cd coreutils && source "$HOME/.cargo/env" && RUSTFLAGS="-C target-feature=+crt-static" cargo build --target x86_64-unknown-linux-musl --release --features feat_os_unix_musl
COPY kiro-no-jemalloc.diff /kiro-no-jemalloc.diff
RUN git clone https://github.com/rhysd/kiro-editor kiro && cd kiro && git apply /kiro-no-jemalloc.diff && source "$HOME/.cargo/env" && cd /kiro && RUSTFLAGS="-C target-feature=+crt-static" cargo build --target x86_64-unknown-linux-musl --release
RUN git clone https://github.com/sharkdp/bat && cd bat && source "$HOME/.cargo/env" && RUSTFLAGS="-C target-feature=+crt-static" cargo build --target x86_64-unknown-linux-musl --release
RUN git clone https://github.com/dalance/procs && cd procs && source "$HOME/.cargo/env" && RUSTFLAGS="-C target-feature=+crt-static" cargo build --target x86_64-unknown-linux-musl --release
RUN git clone https://github.com/ClementTsang/bottom btm && cd btm && source "$HOME/.cargo/env" && RUSTFLAGS="-C target-feature=+crt-static" cargo build --target x86_64-unknown-linux-musl --release
RUN git clone https://github.com/ezrosent/frawk && cd frawk && source "$HOME/.cargo/env" && RUSTFLAGS="-C target-feature=+crt-static" cargo build --target x86_64-unknown-linux-musl --release --no-default-features
RUN git clone https://github.com/chmln/sd && cd sd && source "$HOME/.cargo/env" && RUSTFLAGS="-C target-feature=+crt-static" cargo build --target x86_64-unknown-linux-musl --release
RUN git clone https://github.com/sharkdp/fd && cd fd && source "$HOME/.cargo/env" && RUSTFLAGS="-C target-feature=+crt-static" cargo build --target x86_64-unknown-linux-musl --release
RUN git clone https://github.com/theryangeary/choose && cd choose && source "$HOME/.cargo/env" && RUSTFLAGS="-C target-feature=+crt-static" cargo build --target x86_64-unknown-linux-musl --release
RUN for x in $(ls -d /*/target/x86_64-unknown-linux-musl/release); do y=$(echo "$x" | cut -d / -f 2); strip "$x"/"$y" ; done

FROM scratch
COPY --from=builder /nsh/target/x86_64-unknown-linux-musl/release/nsh /bin/nsh
COPY --from=builder /coreutils/target/x86_64-unknown-linux-musl/release/coreutils /bin/coreutils
COPY --from=builder /rg/target/x86_64-unknown-linux-musl/release/rg /bin/rg
COPY --from=builder /kiro/target/x86_64-unknown-linux-musl/release/kiro /bin/kiro
COPY --from=builder /bat/target/x86_64-unknown-linux-musl/release/bat /bin/bat
COPY --from=builder /procs/target/x86_64-unknown-linux-musl/release/procs /bin/procs
COPY --from=builder /btm/target/x86_64-unknown-linux-musl/release/btm /bin/btm
COPY --from=builder /frawk/target/x86_64-unknown-linux-musl/release/frawk /bin/frawk
COPY --from=builder /sd/target/x86_64-unknown-linux-musl/release/sd /bin/sd
COPY --from=builder /fd/target/x86_64-unknown-linux-musl/release/fd /bin/fd
COPY --from=builder /choose/target/x86_64-unknown-linux-musl/release/choose /bin/choose
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
