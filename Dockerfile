FROM laniakeacloud/galaxy:18.05

MAINTAINER ma.tangaro@ibiom.cnr.it

ENV container docker

COPY ["playbook.yaml","/"]

ADD https://raw.githubusercontent.com/Laniakea-elixir-it/Scripts/master/galaxy_tools/install_tools.docker.sh /tmp/install_tools.sh
RUN chmod +x /tmp/install_tools.sh

RUN wget https://raw.githubusercontent.com/indigo-dc/Galaxy-flavors-recipes/master/galaxy-GDC_Somatic_Variant/galaxy-GDC_Somatic_Variant-tool-list-1.yml -O /tmp/tools1.yml
RUN wget https://raw.githubusercontent.com/indigo-dc/Galaxy-flavors-recipes/master/galaxy-GDC_Somatic_Variant/galaxy-GDC_Somatic_Variant-tool-list-2.yml -O /tmp/tools2.yml
RUN wget https://raw.githubusercontent.com/indigo-dc/Galaxy-flavors-recipes/master/galaxy-GDC_Somatic_Variant/galaxy-GDC_Somatic_Variant-tool-list-3.yml -O /tmp/tools3.yml

RUN /tmp/install_tools.sh GALAXY_ADMIN_API_KEY /tmp/tools1.yml && \
    /export/tool_deps/_conda/bin/conda clean --tarballs --yes > /dev/null && \
    /tmp/install_tools.sh GALAXY_ADMIN_API_KEY /tmp/tools2.yml && \
    /export/tool_deps/_conda/bin/conda clean --tarballs --yes > /dev/null && \
    /tmp/install_tools.sh GALAXY_ADMIN_API_KEY /tmp/tools3.yml && \
    /export/tool_deps/_conda/bin/conda clean --tarballs --yes > /dev/null

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
