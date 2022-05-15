# Build Stage
FROM ubuntu:20.04 as builder

##Installing things - using the last project as an example (strings)
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y cmake clang curl
RUN curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
RUN ${HOME}/.cargo/bin/rustup default nightly
RUN ${HOME}/.cargo/bin/cargo install -f cargo-fuzz

ADD . /cpp_demangle
WORKDIR /cpp_demangle
RUN cd fuzz && ${HOME}/.cargo/bin/cargo fuzz build --debug-assertions parse_and_stringify
RUN cd fuzz && ${HOME}/.cargo/bin/cargo fuzz build --debug-assertions cppfilt_differential

FROM ubuntu:20.04

COPY --from=builder nixpkgs-fmt-mayhem/fuzz/target/x86_64-unknown-linux-gnu/release/* /

