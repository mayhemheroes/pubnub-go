FROM golang:1.25 as builder

COPY . /pubnub-go
WORKDIR /pubnub-go/mayhem

RUN go install github.com/dvyukov/go-fuzz/go-fuzz@latest github.com/dvyukov/go-fuzz/go-fuzz-build@latest
RUN go get github.com/dvyukov/go-fuzz/go-fuzz-dep
RUN apt update && apt install -y clang

RUN go-fuzz-build -libfuzzer -o fuzzPubnub.a && \
    clang -fsanitize=fuzzer fuzzPubnub.a -o fuzzPubnub.libfuzzer

FROM debian:trixie-slim
COPY --from=builder /pubnub-go/mayhem/fuzzPubnub.libfuzzer /
