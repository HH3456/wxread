FROM python:3.10-slim

# 设置时区为中国时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 安装 cron
RUN apt-get update && apt-get install -y cron && rm -rf /var/lib/apt/lists/*
ENV PATH="/usr/local/bin:${PATH}"

# 安装 Python 依赖
RUN pip install --no-cache-dir \
    requests>=2.32.3 \
    urllib3>=2.2.3

# ID1------设置工作目录
WORKDIR /app_1

# 复制项目文件
COPY main.py push.py config_1.py ./

# 创建日志目录并设置权限
RUN mkdir -p /app_1/logs && chmod 777 /app/logs

# 创建 cron 任务（每天PM6点执行）
RUN echo "0 18 * * * cd /app_1 && /usr/local/bin/python3 main.py >> /app_1/logs/\$(date +\%Y-\%m-\%d).log 2>&1" > /etc/cron.d/wxread_1-cron
RUN chmod 0644 /etc/cron.d/wxread_1-cron
RUN crontab /etc/cron.d/wxread_1-cron

# ID2------设置工作目录
WORKDIR /app_2

# 复制项目文件
COPY main.py push.py config_2.py ./

# 创建日志目录并设置权限
RUN mkdir -p /app_2/logs && chmod 777 /app/logs

# 创建 cron 任务（每天PM9点执行）
RUN echo "0 21 * * * cd /app_2 && /usr/local/bin/python3 main.py >> /app_2/logs/\$(date +\%Y-\%m-\%d).log 2>&1" > /etc/cron.d/wxread_2-cron
RUN chmod 0644 /etc/cron.d/wxread_2-cron
RUN crontab /etc/cron.d/wxread_2-cron

# 启动命令
CMD ["sh", "-c", "service cron start && tail -f /dev/null"]
