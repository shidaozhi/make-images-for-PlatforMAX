FROM base-image:image-tag

# 设置时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo '$TZ' > /etc/timezone

# 使用阿里云源（如果需要）
# COPY sources.list /etc/apt/sources.list

# 安装基本依赖、Python 库和配置
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential make cmake \
    vim wget openssh-server software-properties-common \
    python3 python3-pip g++ libboost-all-dev \
    && pip3 install --no-cache-dir psutil \
    && pip3 install --no-cache-dir opencv-python matplotlib pandas graphviz \
                pyyaml scikit-learn dlib requests argparse \
                cython scipy seaborn Plotly Bokeh \
                Statsmodels NetworkX jupyter jupyterlab -i https://mirrors.aliyun.com/pypi/simple/ \
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

# 配置 Jupyter
COPY config-jupyter.sh /config-jupyter.sh
COPY jupyter_server_config.py /root/.jupyter/jupyter_server_config.py
COPY jupyter_notebook_config.py /root/.jupyter/jupyter_notebook_config.py
COPY custom.js /root/.jupyter/custom/custom.js
RUN /config-jupyter.sh && rm /config-jupyter.sh

# 设置 tini
COPY tini /tini
ENTRYPOINT ["/tini", "--"]
RUN mkdir -p /var/run/sshd && chmod 777 /tini
EXPOSE 22
