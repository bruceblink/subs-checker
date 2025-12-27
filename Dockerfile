# =========================
# Builder stage
# =========================
FROM golang:alpine AS builder
WORKDIR /app

# 提升缓存命中率
COPY go.mod go.sum ./
RUN go mod download

# 复制其余源码
COPY . .

# 构建参数
ARG VERSION
ARG GITHUB_SHA

# 构建 Go 二进制
RUN echo "Building commit: ${GITHUB_SHA:0:7}" && \
    go build \
      -trimpath \
      -ldflags="-s -w \
        -X main.Version=${VERSION} \
        -X main.CurrentCommit=${GITHUB_SHA:0:7}" \
      -o main .

# =========================
# Runtime stage
# =========================
FROM alpine
ENV TZ=Asia/Shanghai

RUN apk add --no-cache ca-certificates tzdata && \
    ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime && \
    echo "${TZ}" > /etc/timezone && \
    rm -rf /var/cache/apk/*

# 只拷贝 Go 可执行文件
COPY --from=builder /app/main /app/main

EXPOSE 8199
CMD ["/app/main"]