FROM debian:bookworm-slim AS builder

RUN apt-get update                   \
 && DEBIAN_FRONTEND='noninteractive' \
    apt-get install --yes curl dpkg

ENV VER=3.8.1

RUN curl -#o dart.deb https://storage.googleapis.com/dart-archive/channels/stable/release/latest/linux_packages/dart_$VER-1_amd64.deb \
 && dpkg -i dart.deb

FROM codegolf/lang-base

COPY --from=0 /lib/x86_64-linux-gnu/libc.so.6                          \
              /lib/x86_64-linux-gnu/libdl.so.2                         \
              /lib/x86_64-linux-gnu/libm.so.6                          \
              /lib/x86_64-linux-gnu/libpthread.so.0                    /lib/
COPY --from=0 /lib64/ld-linux-x86-64.so.2                              /lib64/
COPY --from=0 /usr/lib/dart/bin/dart                                   /usr/bin/
COPY --from=0 /usr/lib/dart/bin/snapshots/kernel-service.dart.snapshot /usr/bin/snapshots/
COPY --from=0 /usr/lib/dart/include                                    /usr/include
COPY --from=0 /usr/lib/dart/lib                                        /usr/lib

ENTRYPOINT ["dart"]

CMD ["--version"]
