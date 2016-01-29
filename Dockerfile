FROM jupyter/all-spark-notebook

USER root

# fetch juptyerhub-singleuser entrypoint
ADD https://raw.githubusercontent.com/jupyter/jupyterhub/master/scripts/jupyterhub-singleuser /usr/local/bin/jupyterhub-singleuser
#ADD https://raw.githubusercontent.com/jupyter/jupyterhub/master/jupyterhub/singleuser.py /usr/local/bin/jupyterhub-singleuser
RUN chmod 755 /usr/local/bin/jupyterhub-singleuser

RUN sed -ri 's!/usr/local!/opt/conda/bin:/usr/local!' /etc/sudoers

ADD systemuser.sh /srv/singleuser/systemuser.sh
CMD ["sh", "/srv/singleuser/systemuser.sh"]

RUN apt-get update && apt-get install -y \
        supervisor
RUN conda update --all
RUN conda install libpng freetype numpy pip scipy
RUN conda install ipykernel jupyter matplotlib conda-build && \
	python -m ipykernel.kernelspec

# Install TensorFlow CPU version.
ENV TENSORFLOW_VERSION 0.6.0
RUN pip --no-cache-dir install \
        https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-${TENSORFLOW_VERSION}-cp34-none-linux_x86_64.whl
# Mecab
RUN apt-get install -y --no-install-recommends \
	mecab libmecab-dev mecab-ipadic-utf8
RUN conda skeleton pypi mecab-python3 && conda build mecab-python3
# gensim
RUN conda install gensim
# skflow
RUN pip install git+git://github.com/google/skflow.git
# Octave
RUN apt-get install -y --no-install-recommends octave
# Octave kernel
RUN pip install octave_kernel
RUN python -m octave_kernel.install
# pyquery
RUN conda install libxml2 libxslt lxml gcc
RUN conda skeleton pypi pyquery && conda build pyquery
# SQL
RUN conda install pymysql
RUN conda install psycopg2
RUN pip install ipython-sql
# clean
RUN apt-get -y autoremove && apt-get clean # && rm -rf /var/lib/apt/lists/*


