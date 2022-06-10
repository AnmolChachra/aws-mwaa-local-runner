# VERSION 1.10
# AUTHOR: Subash Canapathy
# DESCRIPTION: Amazon MWAA Local Dev Environment
# BUILD: docker build --rm -t amazon/mwaa-local .

FROM public.ecr.aws/amazonlinux/amazonlinux
LABEL maintainer="amazon"

# Airflow
ARG AIRFLOW_VERSION=2.0.2
ARG AIRFLOW_USER_HOME=/usr/local/airflow
ARG AIRFLOW_DEPS=""
ARG PYTHON_DEPS=""
ARG SYSTEM_DEPS=""
ARG INDEX_URL=""
ENV AIRFLOW_HOME=${AIRFLOW_USER_HOME}

COPY script/bootstrap.sh /bootstrap.sh
COPY script/systemlibs.sh /systemlibs.sh
COPY script/generate_key.sh /generate_key.sh
COPY script/bootstrap_jupyter.sh /bootstrap_jupyter.sh
COPY config/constraints.txt /constraints.txt
COPY config/requirements.txt /requirements.txt
COPY static/banner.txt /banner.txt

RUN yum install gcc gcc-g++ gcc-c++ make cmake rpm-build wget -y
#     && yum install zlib-devel bzip2-devel openssl-devel ncurses-devel readline-devel tk-devel -y

RUN cd /opt \
    && wget https://www.sqlite.org/2020/sqlite-autoconf-3310100.tar.gz \
    && tar -xzf sqlite-autoconf-3310100.tar.gz \
    && cd sqlite-autoconf-3310100 \
    && ls \
    && export CFLAGS="-DSQLITE_ENABLE_FTS3 \
    -DSQLITE_ENABLE_FTS3_PARENTHESIS \
    -DSQLITE_ENABLE_FTS4 \
    -DSQLITE_ENABLE_FTS5 \
    -DSQLITE_ENABLE_JSON1 \
    -DSQLITE_ENABLE_LOAD_EXTENSION \
    -DSQLITE_ENABLE_RTREE \
    -DSQLITE_ENABLE_STAT4 \
    -DSQLITE_ENABLE_UPDATE_DELETE_LIMIT \
    -DSQLITE_SOUNDEX \
    -DSQLITE_TEMP_STORE=3 \
    -DSQLITE_USE_URI \
    -O2 \
    -fPIC" \
    && export PREFIX="/usr/local/sqlite" \
    && LIBS="-lm" ./configure --enable-shared --prefix="$PREFIX" \
    && make \
    && make install \
    && echo "LD_LIBRARY_PATH=/usr/local/sqlite/lib" >> ~/.bashrc


RUN mv /usr/lib64/libsqlite3.so.0 /usr/lib64/libsqlite3.so.0.old \
    && mv /usr/lib64/libsqlite3.so.0.8.6 /usr/lib64/libsqlite3.so.0.8.6.old \
    && cp /usr/local/sqlite/lib/libsqlite3.so.0 /usr/lib64/ \
    && cp /usr/local/sqlite/lib/libsqlite3.so.0.8.6 /usr/lib64/

# # Install python manually
# RUN cd /opt \
#     && wget https://www.python.org/ftp/python/3.7.10/Python-3.7.10.tar.xz \
#     && tar -xvf Python-3.7.10.tar.xz \
#     && cd Python-3.7.10 \
#     && ./configure prefix=/usr/local/lib/python3 \
#     && make \
#     && make install \
#     && ln -s /usr/local/lib/python3/bin/python3.7 /bin/python3 \
#     && ln -s /usr/local/lib/python3/bin/pip3 /bin/pip3 \
#     && echo "export PATH=$PATH:/usr/local/lib/python3/bin" >> ~/.bashrc \
#     && echo "export PATH=$PATH:/usr/local/lib/python3/bin" >> /.bashrc

RUN chmod u+x /systemlibs.sh && /systemlibs.sh
RUN chmod u+x /bootstrap.sh && /bootstrap.sh
RUN chmod u+x /generate_key.sh && /generate_key.sh
RUN chmod u+x /bootstrap_jupyter.sh && /bootstrap_jupyter.sh

# Post bootstrap to avoid expensive docker rebuilds
COPY script/entrypoint.sh /entrypoint.sh
COPY config/airflow.cfg ${AIRFLOW_USER_HOME}/airflow.cfg
COPY config/webserver_config.py ${AIRFLOW_USER_HOME}/webserver_config.py

RUN chown -R airflow: ${AIRFLOW_USER_HOME}
RUN chmod +x /entrypoint.sh

EXPOSE 8080 5555 8793 8888

RUN echo "airflow ALL=(ALL) ALL" >> /etc/sudoers

USER airflow
WORKDIR ${AIRFLOW_USER_HOME}

ENTRYPOINT ["/entrypoint.sh"]
CMD ["local-runner"]
