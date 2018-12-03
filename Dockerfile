FROM laniakeacloud/galaxy:18.05

MAINTAINER ma.tangaro@ibiom.cnr.it

ENV container docker

COPY ["playbook.yaml","/"]

RUN ansible-galaxy install indigo-dc.galaxycloud-tools
RUN ansible-galaxy install indigo-dc.galaxycloud-tooldeps
RUN ansible-galaxy install indigo-dc.cvmfs-client
RUN ansible-galaxy install indigo-dc.galaxycloud-refdata

# Download refdata configuration file
ADD https://raw.githubusercontent.com/indigo-dc/Reference-data-galaxycloud-repository/master/cvmfs_server_keys/elixir-italy.galaxy.refdata.pub /tmp/elixir-italy.galaxy.refdata.pub
ADD https://raw.githubusercontent.com/indigo-dc/Reference-data-galaxycloud-repository/master/cvmfs_server_config_files/elixir-italy.galaxy.refdata.conf /tmp/elixir-italy.galaxy.refdata.conf

RUN echo "localhost" > /etc/ansible/hosts

# Install tools and configure cvmfs reference data
RUN ansible-playbook /playbook.yaml

# This overwrite docker-galaxy CMD line
# Mount cvmfs and start galaxy
CMD /bin/mount -t cvmfs elixir-italy.galaxy.refdata /cvmfs/elixir-italy.galaxy.refdata; /usr/local/bin/galaxy-startup; /usr/bin/sleep infinity
