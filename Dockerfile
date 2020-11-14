# build it with
# docker build . --network=host --tag mertes/drop:latest --tag mertes/drop

# base image
FROM continuumio/miniconda3

# update and setup system
RUN apt-get update -y \
    && apt-get install -y bc less wget vim git \
    && apt-get clean 

# init drop env
RUN conda create -y -c conda-forge -c bioconda -n drop \
        "drop>=1.0.1" \
        "r-base>=4.0.3" \
        "r-devtools" \
        "python>=3.8" \
        "wbuild>=1.8.0" \
        "bioconductor-fraser>=1.2.0" \
    && conda clean --all -y

COPY environment.yml /tmp/
RUN conda env update --prune -f /tmp/environment.yml \
    && conda clean --all -y

# install newest DROP/FRASER/OUTRIDER version
ARG DROP_COMMIT=0470011
SHELL ["conda", "run", "-n", "drop", "/bin/bash", "-c"]
RUN mkdir /tmp/gitrepos \
    && cd /tmp/gitrepos \
    && git clone https://github.com/gagneurlab/drop \
    && cd drop \
    && git checkout $DROP_COMMIT \
    && pip install . \
    && R -e "BiocManager::install(c(\"gagneurlab/OUTRIDER\", \"c-mertes/FRASER\"), update=FALSE)" \
    && cd / \
    && rm -rf /tmp/gitrepos

ARG ASSEMBLY=

# create user
RUN useradd -d /drop -ms /bin/bash drop \
    && chmod -R ugo+rwX /drop \
    && chmod ugo+rwX /opt/conda/envs/drop

# setup bash with conda and locals (language pack)
USER drop:drop
SHELL ["/bin/bash", "-c"]
RUN conda init bash \
    && echo -e "\n# activate drop environemnt\nconda activate drop\n" >> ~/.bashrc \
    && echo -e "\n# read/write for group\numask 002\n" >> ~/.bashrc \
#    && echo -e "\n# add local language support for CLICK\nexport LC_ALL=en_US.utf8\nexport LANG=en_US.utf8\n" >> ~/.bashrc \
    && mkdir /drop/analysis \
    && chmod -R ugo+rwX /drop
WORKDIR /drop/analysis

# set entry point for image
COPY entry_point.sh /usr/local/bin/entry_point.sh
ENTRYPOINT [ "entry_point.sh" ]
CMD [ "bash" ]

