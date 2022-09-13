# syntax=docker/dockerfile:1
FROM golang:1.18 as builder
ARG VERSION
ARG CGO_CFLAGS
WORKDIR /build
ADD . /build/
RUN --mount=type=cache,target=/root/.cache/go-build CGO_CFLAGS="$CGO_CFLAGS" GOOS=linux go build -ldflags "-X 'github.com/flashbots/mev-boost/config.Version=$VERSION'" -v -o mev-boost .

FROM alpine
RUN apk add --no-cache libstdc++ libc6-compat
WORKDIR /app
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /build/mev-boost /app/mev-boost
EXPOSE 18550
HEALTHCHECK CMD  wget --no-verbose --tries=1 --spider http://localhost:18550/eth/v1/builder/status || exit 1
ENTRYPOINT ["/app/mev-boost"]
