FROM jupyter/all-spark-notebook

USER root

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
        supervisor
RUN conda update --all
RUN conda install libpng freetype numpy pip scipy
RUN conda install ipykernel jupyter matplotlib conda-build && \
	python -m ipykernel.kernelspec
RUN conda install tensorflow chainer

#RUN pip install --upgrade -I setuptools
# Mecab
RUN conda install swig
RUN apt-get install -y --no-install-recommends \
	mecab libmecab-dev mecab-ipadic-utf8
#RUN chown -R root /home/jovyan/.cache
RUN apt-get install -y gcc-multilib g++-multilib
#RUN conda skeleton pypi mecab-python3 && sed -ri 's/mecab:/mecab/' mecab-python3/meta.yaml && \
#	conda build mecab-python3
RUN pip install mecab-python3
# gensim
RUN conda install gensim
# skflow
RUN pip install git+git://github.com/google/skflow.git
# Octave
#RUN apt-get install -y --no-install-recommends octave
# Octave kernel
#RUN pip install octave_kernel
#RUN python -m octave_kernel.install
# pyquery
#RUN conda install libxml2 libxslt lxml gcc
#RUN pip install pyquery
RUN conda install pyquery
#RUN conda skeleton pypi pyquery && conda build pyquery
# SQL
RUN conda install pymysql
RUN conda install psycopg2
RUN conda install ipython-sql
# pyhive
RUN conda install pyhive
# plotly
RUN conda install plotly dash dash-renderer dash-html-components dash-core-components
#RUN conda skeleton pypi cufflinks && conda build cufflinks
RUN pip install cufflinks
# spark2
ENV APACHE_SPARK_VERSION 2.4.4
RUN cd /tmp && \
        wget -q http://ftp.jaist.ac.jp/pub/apache/spark/spark-${APACHE_SPARK_VERSION}/spark-${APACHE_SPARK_VERSION}-bin-hadoop2.7.tgz && \
        tar xzf spark-${APACHE_SPARK_VERSION}-bin-hadoop2.7.tgz -C /usr/local && \
        rm spark-${APACHE_SPARK_VERSION}-bin-hadoop2.7.tgz
RUN cd /usr/local && rm -f spark && ln -s spark-${APACHE_SPARK_VERSION}-bin-hadoop2.7 spark
ENV PYTHONPATH $SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.7-src.zip
ENV PYSPARK_PYTHON /opt/conda/bin/python
# sparkmagic
RUN pip install sparkmagic && jupyter nbextension enable --py --sys-prefix widgetsnbextension
#COPY 507.mod.diff /tmp
#RUN cd /opt/conda/lib/python3.7/site-packages/sparkmagic && patch -t -p3 < /tmp/507.mod.diff
RUN cd /opt/conda/lib/python3.7/site-packages && \
#	jupyter-kernelspec install sparkmagic/kernels/pyspark3kernel && \
	jupyter-kernelspec install sparkmagic/kernels/pysparkkernel && \
        jupyter-kernelspec install sparkmagic/kernels/sparkkernel && \
        jupyter-kernelspec install sparkmagic/kernels/sparkrkernel
RUN mkdir /opt/sparkmagic
COPY config.json /opt/sparkmagic/config.json
ENV SPARKMAGIC_CONF_DIR /opt/sparkmagic
ENV SPARKMAGIC_CONF_FILE config.json
# for NT lab
RUN conda install zc.lockfile
RUN pip install linecache2 && pip install argparse
# clean
RUN apt-get -y autoremove && apt-get clean # && rm -rf /var/lib/apt/lists/*
# smoke test entrypoint
#RUN USER_ID=65000 USER=systemusertest sh /srv/singleuser/systemuser.sh -h && userdel systemusertest

RUN sed -ri 's!/usr/local!/opt/conda/bin:/usr/local!' /etc/sudoers
