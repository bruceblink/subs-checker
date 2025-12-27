# 订阅合并转换检测工具

本项目基于[beck-8/subs-check](https://github.com/beck-8/subs-check/commit/a7439254daed532bb1b1baa95e3cca470881c6f6)做出的独立项目，只保留核心的订阅节点检测，输出有效的节点

> **注意：** 功能添加频繁，请看最新[配置文件](https://github.com/bruceblink/subs-checker/blob/master/config/config.example.yaml)跟进功能

## 预览

![preview](./doc/images/preview.png)
![admin](./doc/images/admin.png)

## 功能

- 检测节点可用性,去除不可用节点
  - 新增参数keep-success-proxies用于持久保存测试成功的节点，可避免上游链接更新导致可用节点丢失，此功能默认关闭
- 检测平台解锁情况（需要手动开启参数 `media-check`）
  - openai
  - youtube
  - netflix
  - disney
  - gemini
  - IP欺诈分数
- 合并多个订阅
- 节点去重
- 节点重命名
- 节点测速（单线程）

## 特点

- 支持多平台
- 支持多线程
- 资源占用低

## TODO

- [x] 适配多种订阅格式
- [ ] 支持更多的保存方式
  - [x] 本地
  - [x] cloudflare r2
  - [ ] 其他
- [x] 已知从clash格式转base64时vmess节点会丢失。因为太麻烦了，我不想处理了。
- [x] 可能在某些平台、某些环境下长时间运行还是会有内存溢出的问题
  - [x] 新增内存限制环境变量，用于限制内存使用，超出会自动重启（docker用户请使用docker的内存限制）
    - [x] 环境变量 `SUB_CHECK_MEM_LIMIT=500M` `SUB_CHECK_MEM_LIMIT=1G`
    - [x] 重启后的进程无法使用`ctrl c`退出，只能关闭终端
  - [x] 彻底解决

## 部署/使用方式

### Docker运行

> **注意：** 如果需要限制内存，请使用docker自带的内存限制参数 `--memory="500m"`
> 可使用环境变量`API_KEY`直接设置Web控制面板的api-key

```bash
# 基础运行
docker run -d \
  --name subs-check \
  -p 8199:8199 \
  -p 8299:8299 \
  -v ./config:/app/config \
  -v ./output:/app/output \
  --restart always \
  ghcr.io/beck-8/subs-check:latest

# 使用代理运行
docker run -d \
  --name subs-check \
  -p 8199:8199 \
  -p 8299:8299 \
  -e HTTP_PROXY=http://192.168.1.1:7890 \
  -e HTTPS_PROXY=http://192.168.1.1:7890 \
  -v ./config:/app/config \
  -v ./output:/app/output \
  --restart always \
  ghcr.io/beck-8/subs-check:latest
```

### Docker-Compose

```yaml
version: "3"
services:
  subs-check:
    image: ghcr.io/beck-8/subs-check:latest
    container_name: subs-check
    # mem_limit: 500m
    volumes:
      - ./config:/app/config
      - ./output:/app/output
    ports:
      - "8199:8199"
      - "8299:8299"
    environment:
      - TZ=Asia/Shanghai
      # 是否使用代理
      # - HTTP_PROXY=http://192.168.1.1:7890
      # - HTTPS_PROXY=http://192.168.1.1:7890
      # 设置 api-key
      # - API_KEY=password
    restart: always
    tty: true
    network_mode: bridge
```

### 源码直接运行

```bash
go run main.go -f /path/to/config.yaml
```

### 二进制文件运行

下载 [releases](https://github.com/bruceblink/subs-checker/releases) 当中的适合自己的版本解压直接运行即可,会在当前目录生成配置文件

## 对外提供服务

> **提示：** 根据客户端的类型自己选择是否需要订阅转换

| 服务地址 | 说明 |
|---------|------|
| `http://127.0.0.1:8199/sub/all.yaml` | 返回yaml格式节点 |
| `http://127.0.0.1:8199/sub/mihomo.yaml` | 返回带分流规则的mihomo订阅 |
| `http://127.0.0.1:8199/sub/base64.txt` | 返回base64格式的订阅 |

## 订阅使用方法



## 免责声明

本工具仅用于学习和研究目的。使用者应自行承担使用风险，并遵守相关法律法规。
