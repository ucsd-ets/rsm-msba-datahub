# 1) choose base container
# generally use the most recent tag

# base notebook, contains Jupyter and relevant tools
# See https://github.com/ucsd-ets/datahub-docker-stack/wiki/Stable-Tag 
# for a list of the most current containers we maintain

ARG BASE_CONTAINER=vnijs/rsm-msba-intel-jupyterhub:latest

FROM $BASE_CONTAINER

# LABEL maintainer="UC San Diego ITS/ETS <ets-consult@ucsd.edu>"

# Change to root to fix permissions...
USER root

# TODO: Make any directories that are not accessible by default to Datahub user completely globally accessible.
# Additionally, possibly attempt to kill/respawn jupyter?
CMD chmod -R 777 /home/jovyan

USER ${NB_UID}
ENV HOME /home/${NB_USER}
WORKDIR "${HOME}"

# 3) install packages using notebook user
#USER jovyan

# RUN conda install -y scikit-learn

#RUN pip install --no-cache-dir networkx scipy

# Override command to disable running jupyter notebook at launch
# CMD ["/bin/bash"]

