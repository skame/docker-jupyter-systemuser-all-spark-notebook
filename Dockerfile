FROM jupyter/all-spark-notebook

USER root

# fetch juptyerhub-singleuser entrypoint
ADD https://raw.githubusercontent.com/jupyter/jupyterhub/master/jupyterhub/singleuser.py /usr/local/bin/jupyterhub-singleuser
RUN chmod 755 /usr/local/bin/jupyterhub-singleuser

RUN sed -ri 's!/usr/local!/opt/conda/bin:/usr/local!' /etc/sudoers

ADD systemuser.sh /srv/singleuser/systemuser.sh
CMD ["sh", "/srv/singleuser/systemuser.sh"]

# for TensorFlow
RUN apt-get update && apt-get install -y \
#        curl \
        libfreetype6-dev \
        libpng12-dev \
#        libzmq3-dev \
#        pkg-config \
        python-numpy \
        python-pip \
        python-scipy \
        supervisor

RUN curl -k -O https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py && \
    rm get-pip.py

RUN pip --no-cache-dir install \
        ipykernel \
        jupyter \
        matplotlib \
        && \
    python -m ipykernel.kernelspec

# Install TensorFlow CPU version.
ENV TENSORFLOW_VERSION 0.6.0
#RUN pip --no-cache-dir install \
#       https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-${TENSORFLOW_VERSION}-cp27-none-linux_x86_64.whl

RUN pip --no-cache-dir install \
        https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-${TENSORFLOW_VERSION}-cp34-none-linux_x86_64.whl

# Mecab
RUN apt-get install -y --no-install-recommends \
	mecab libmecab-dev mecab-ipadic-utf8
RUN pip install mecab-python3
# gensim
RUN pip install gensim
# skflow
RUN pip install git+git://github.com/google/skflow.git
# Octave
RUN apt-get install -y --no-install-recommends \
	octave
# Octave kernel
RUN pip install octave_kernel
RUN python -m octave_kernel.install

# clean
RUN apt-get -y autoremove && apt-get clean && rm -rf /var/lib/apt/lists/*

