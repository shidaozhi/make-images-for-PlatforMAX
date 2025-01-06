FROM base-image:image-tag

# 设置时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo '$TZ' > /etc/timezone

# 安装必要的软件包（包括 Python 3、pip、vim 和 wget）
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential make cmake \
    vim wget openssh-server software-properties-common \
    python3 python3-pip \
    && pip3 install --no-cache-dir psutil \
    && apt-get autoclean -y \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# 拷贝并安装 mpsclient
COPY mpsclient-5.0.1.tar.gz /opt/
RUN tar xzvf /opt/mpsclient-5.0.1.tar.gz -C /opt/ && \
    cd /opt/mpsclient-5.0.1 && \
    python3 setup.py install && \
    rm -rf /opt/mpsclient-5.0.1 /opt/mpsclient-5.0.1.tar.gz

# 配置 SSH
COPY ssh/sshd_config /etc/ssh/sshd_config
COPY ssh/ssh-start-chpasswd.sh /usr/sbin/ssh-start-chpasswd.sh
RUN chmod 500 /usr/sbin/ssh-start-chpasswd.sh

# 设置 tini
COPY tini /tini
ENTRYPOINT ["/tini", "--"]
RUN mkdir -p /var/run/sshd
EXPOSE 22
