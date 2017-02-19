FROM beakernotebook/beaker
MAINTAINER Martin Lambertz <martin@0x4d4c.xyz>

VOLUME ["/data", \
        "/notebooks", \
        "/plots", \
        "/scripts"]

############
# Python 3 #
############
RUN  /home/beaker/py3k/bin/pip install \
        elasticsearch \
        networkx \
        pymongo \
        python-dateutil \
        requests \
        seaborn && \
    rm -rf /var/lib/apt/lists/*

