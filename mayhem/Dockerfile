# syntax=docker/dockerfile:1.7
#
# Commit-image Dockerfile (SMALL form) — pubnub/go is pure Go; install Go + go-fuzz tooling on
# the org base, then build the legacy go-fuzz libFuzzer harness (fuzzPubnub.Fuzz).
#
# Build (from repo root):
#   DOCKER_BUILDKIT=1 docker build -f mayhem/Dockerfile \
#       --build-arg COMMIT=$(git rev-parse HEAD) \
#       -t pubnub-go-commit:test .

FROM ghcr.io/mayhemheroes/base:2026-06

ARG COMMIT
ARG REPO_URL
ARG SOURCE_DATE_EPOCH
ARG SANITIZER_FLAGS
ARG MAYHEM_JOBS=
ARG GO_VERSION=1.25.1

ENV GOROOT=/usr/local/go \
    GOPATH=/root/go \
    GOTOOLCHAIN=local \
    PATH=/usr/local/go/bin:/root/go/bin:/usr/local/bin:/usr/bin:/bin
USER root
RUN repro-sources-list.sh 2>/dev/null || true; \
    apt-get update && apt-get install -yq --no-install-recommends wget ca-certificates git \
    && rm -rf /var/lib/apt/lists/* \
    && wget -q "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" -O /tmp/go.tgz \
    && tar -C /usr/local -xzf /tmp/go.tgz && rm /tmp/go.tgz \
    && go version \
    && go install github.com/dvyukov/go-fuzz/go-fuzz@latest \
    && go install github.com/dvyukov/go-fuzz/go-fuzz-build@latest \
    && ln -sf "$GOPATH/bin/go-fuzz-build" "$GOPATH/bin/go-fuzz-build" \
    && ls -la "$GOPATH/bin" \
    && chmod -R a+rX /usr/local/go "$GOPATH" \
    && go clean -cache 2>/dev/null || true
RUN chmod -R a+rwX /root/go && chmod a+rx /root
USER mayhem

ENV GOFLAGS=-mod=mod \
    GOPATH=/home/mayhem/go \
    GOCACHE=/home/mayhem/.cache/go-build \
    GOMODCACHE=/root/go/pkg/mod

WORKDIR /mayhem
COPY --chown=2000:2000 . /mayhem

RUN bash mayhem/build.sh
RUN if [ -f mayhem/test.sh ]; then bash mayhem/test.sh; else echo "no mayhem/test.sh"; fi

LABEL org.opencontainers.image.source="${REPO_URL}" \
      org.opencontainers.image.revision="${COMMIT}" \
      rlenv.tier="commit" \
      rlenv.source_date_epoch="${SOURCE_DATE_EPOCH}" \
      rlenv.user="mayhem"

USER mayhem
WORKDIR /mayhem
