# Galaxy - GDC Somatic Variant

FROM bgruening/galaxy-stable:19.01

MAINTAINER Tangaro Marco Antonio, ma.tangaro@ibiom.cnr.it

ENV GALAXY_CONFIG_BRAND="GDC Somatic Variant"

WORKDIR /galaxy-central

RUN add-tool-shed --url 'http://testtoolshed.g2.bx.psu.edu/' --name 'Test Tool Shed'

RUN wget https://raw.githubusercontent.com/indigo-dc/Galaxy-flavors-recipes/master/galaxy-GDC_Somatic_Variant/galaxy-GDC_Somatic_Variant-tool-list-1.yml -O $GALAXY_ROOT/tools1.yaml
RUN wget https://raw.githubusercontent.com/indigo-dc/Galaxy-flavors-recipes/master/galaxy-GDC_Somatic_Variant/galaxy-GDC_Somatic_Variant-tool-list-2.yml -O $GALAXY_ROOT/tools2.yaml
RUN wget https://raw.githubusercontent.com/indigo-dc/Galaxy-flavors-recipes/master/galaxy-GDC_Somatic_Variant/galaxy-GDC_Somatic_Variant-tool-list-3.yml -O $GALAXY_ROOT/tools3.yaml

RUN install-tools $GALAXY_ROOT/tools1.yaml && \
    /tool_deps/_conda/bin/conda clean --tarballs --yes > /dev/null && \
    rm /export/galaxy-central/ -rf

RUN install-tools $GALAXY_ROOT/tools2.yaml && \
    /tool_deps/_conda/bin/conda clean --tarballs --yes > /dev/null && \
    rm /export/galaxy-central/ -rf

RUN install-tools $GALAXY_ROOT/tools3.yaml && \
    /tool_deps/_conda/bin/conda clean --tarballs --yes > /dev/null && \
    rm /export/galaxy-central/ -rf

#download GDC_tool_data_table_conf 
RUN wget https://raw.githubusercontent.com/indigo-dc/Reference-data-galaxycloud-repository/master/data.galaxyproject.org/location/gdc_tool_data_table_conf.xml -O /etc/galaxy/gdc_tool_data_table_conf.xml

# Install workflows
RUN mkdir -p $GALAXY_HOME/workflows

RUN wget https://raw.githubusercontent.com/indigo-dc/Galaxy-flavors-recipes/master/galaxy-GDC_Somatic_Variant/galaxy-GDC_Somatic_Variant-workflows/Galaxy-Workflow-GDC_WF.ga -O $GALAXY_HOME/workflows/Galaxy-Workflow-GDC_WF.ga

RUN startup_lite && \
    galaxy-wait && \
    workflow-install --workflow_path $GALAXY_HOME/workflows/ -g http://localhost:8080 -u $GALAXY_DEFAULT_ADMIN_USER -p $GALAXY_DEFAULT_ADMIN_PASSWORD

#TODO
#set tool_data_tables_conf for GDC wf
ENV GALAXY_CONFIG_TOOL_DATA_TABLE_CONFIG_PATH=/cvmfs/data.galaxyproject.org/byhand/location/tool_data_table_conf.xml,/etc/galaxy/gdc_tool_data_table_conf.xml

# Mark folders as imported from the host.
VOLUME ["/export/", "/data/", "/var/lib/docker"]

# Expose port 80 (webserver), 21 (FTP server), 8800 (Proxy)
EXPOSE :80
EXPOSE :21
EXPOSE :8800

# Autostart script that is invoked during container start
CMD ["/usr/bin/startup"]
