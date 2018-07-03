FROM laniakeacloud/galaxy:17.05

MAINTAINER ma.tangaro@ibiom.cnr.it

ENV container docker

COPY ["playbook.yaml","/"]

RUN ansible-galaxy install indigo-dc.galaxycloud-tools,devel

RUN echo "localhost" > /etc/ansible/hosts

RUN ansible-playbook /playbook.yaml

# This overwrite docker-galaxy CMD line
# REFDATA_CVMFS_REPOSITORY_NAME is defined in docker-galaxy-full
CMD /bin/mount -t cvmfs ${REFDATA_CVMFS_REPOSITORY_NAME} /cvmfs/${REFDATA_CVMFS_REPOSITORY_NAME}; /usr/local/bin/galaxy-startup; /usr/bin/sleep infinity
