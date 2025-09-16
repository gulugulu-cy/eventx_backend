FROM node:20 AS builder

WORKDIR /app

# 1. 复制依赖文件并安装
COPY package.json pnpm-lock.yaml ./
RUN npm install -g pnpm
RUN pnpm install

# 2. 复制所有源代码
COPY . .

# 3. 编译 TypeScript（输出到 dist）
RUN pnpm run build

# ======================
# 阶段2：运行阶段
# ======================
FROM node:20-alpine

WORKDIR /app

# 1. 复制编译后的代码（dist目录）
COPY --from=builder /app/dist ./dist

# 2. 显式复制 bootstrap.js（关键修复！）
COPY --from=builder /app/bootstrap.js ./bootstrap.js

# 3. 复制其他必要文件
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/pnpm-lock.yaml ./pnpm-lock.yaml

# 4. 安装生产依赖
RUN npm install -g pnpm && \
    pnpm install --prod

EXPOSE 7001

# 5. 启动命令（使用项目定义的 start 脚本）
CMD ["sh", "-c", "pnpm start"]