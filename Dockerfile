FROM library/debian:jessie
MAINTAINER Martin Lambertz <martin@0x4d4c.xyz>

COPY install-python.sh /usr/local/bin/install-python.sh
COPY requirements /usr/src/requirements
COPY apt/ /etc/apt/
RUN useradd -u 1000 -N -m -s /bin/bash analyst && \
    apt-get -qq update && \
    DEBIAN_FRONTEND=noninteractive apt-get -qy install --no-install-recommends \
        build-essential \
        curl \
        file \
        libblas3 \
        libblas-dev \
        libbz2-dev \
        libexpat1 \
        libexpat1-dev \
        libfreetype6 \
        libfreetype6-dev \
        libgeos-c1 \
        libgeos-dev \
        libgdbm-dev \
        libjpeg-dev \
        libjpeg62-turbo \
        liblapack3 \
        liblapack-dev \
        libncurses5-dev \
        libpq-dev \
        libpq5 \
        libproj-dev \
        libreadline-dev \
        libsnappy1 \
        libsnappy-dev \
        libsqlite3-0 \
        libsqlite3-dev \
        libssl-dev \
        libzmq3 \
        libzmq3-dev \
        openssl \
        pkg-config \
        proj-bin \
        python3-dev \
        python3-pip \
        sqlite3 \
        tk-dev \
        wget && \
    pip3 install \
        jupyterhub \
        notebook && \
    install-python.sh && \
    apt-get -qy --auto-remove purge \
        libblas-dev \
        libbz2-dev \
        libexpat1-dev \
        libfreetype6-dev \
        libgdbm-dev \
        libgeos-dev \
        libjpeg-dev \
        liblapack-dev \
        libncurses5-dev \
        libpq-dev \
        libproj-dev \
        python3-dev \
        libreadline-dev \
        libsnappy-dev \
        libsqlite3-dev \
        libssl-dev \
        libzmq3-dev \
        tk-dev && \
    mkdir -p /notebooks && chown -R analyst:users /notebooks
COPY jupyter_notebook_config.py /home/analyst/.jupyter/jupyter_notebook_config.py
COPY start-notebook.sh /usr/local/bin/start-notebook.sh
RUN chown -R analyst:users /home/analyst/

USER analyst

EXPOSE 8888
VOLUME /notebooks

CMD ["start-notebook.sh"]

