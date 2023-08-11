ARG BASE_CONTAINER=vnijs/rsm-msba-intel-jupyterhub:latest

FROM $BASE_CONTAINER

# LABEL maintainer="UC San Diego ITS/ETS <ets-consult@ucsd.edu>"

# Change to root to fix permissions...
USER root

# TODO: Make any directories that are not accessible by default to Datahub user completely globally accessible.
# Additionally, possibly attempt to kill/respawn jupyter?
RUN chmod -R 777 /home/jovyan

# (Temporarily) Make postgresql + dependency dirs global
RUN chmod -R 777 /etc/postgresql/${POSTGRES_VERSION}
#RUN chown -R ${NB_USER}:${NB_USER} /etc/postgresql/${POSTGRES_VERSION}

RUN chmod -R 777 /var/lib/postgresql/
#RUN chown -R ${NB_USER}:${NB_USER} /var/lib/postgresql

USER ${NB_UID}
ENV HOME /home/${NB_USER}
#USER jovyan

