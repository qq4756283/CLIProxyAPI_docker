# 构建阶段：编译 Go 程序
FROM golang:1.26-alpine AS builder

# 配置 Go 代理加速依赖下载
ENV GOPROXY=https://goproxy.cn,direct
ENV GO111MODULE=on

WORKDIR /app

# 复制依赖文件并下载
COPY go.mod go.sum ./
RUN go mod download && go mod verify

# 复制源码
COPY . .

# 构建参数（版本/提交/构建时间）
ARG VERSION=dev
ARG COMMIT=none
ARG BUILD_DATE=unknown

# 编译静态二进制文件
RUN CGO_ENABLED=0 GOOS=linux go build \
    -ldflags="-s -w -trimpath -X 'main.Version=${VERSION}' -X 'main.Commit=${COMMIT}' -X 'main.BuildDate=${BUILD_DATE}'" \
    -o ./CLIProxyAPI ./cmd/server/

# 运行阶段：轻量 Alpine 镜像
FROM alpine:3.22.0

# 安装依赖：tzdata（时区）、curl（拉取配置文件）、yq（可选：环境变量覆盖配置）
RUN apk add --no-cache tzdata curl yq

# 创建非 root 用户（Zeabur 安全最佳实践）
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# 创建应用目录并设置权限
RUN mkdir -p /CLIProxyAPI \
    && chown -R appuser:appgroup /CLIProxyAPI

# 从构建阶段复制编译好的二进制文件
COPY --from=builder /app/CLIProxyAPI /CLIProxyAPI/CLIProxyAPI

# 关键：直接从指定 URL 拉取配置文件（兜底机制：拉取失败则创建空配置，避免启动崩溃）
RUN curl -fSL "https://raw.githubusercontent.com/router-for-me/CLIProxyAPI/refs/heads/main/config.example.yaml" -o /CLIProxyAPI/config.yaml \
    || (echo "拉取配置文件失败，创建默认空配置" && echo "server:\n  port: 8317" > /CLIProxyAPI/config.yaml)

# 设置时区（Asia/Shanghai）
ENV TZ=Asia/Shanghai
RUN cp /usr/share/zoneinfo/${TZ} /etc/localtime && echo "${TZ}" > /etc/timezone

# 暴露端口（Zeabur 自动识别）
EXPOSE 8317

# 切换到非 root 用户
USER appuser

# 工作目录
WORKDIR /CLIProxyAPI

# 启动命令（直接启动程序，配置文件已提前准备好）
CMD ["./CLIProxyAPI"]
