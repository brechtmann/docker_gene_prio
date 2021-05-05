# build it with
# docker build . --network=host --tag brechtmann/gene_prio:latest --tag brechtmann/gene_prio

# base image
FROM continuumio/miniconda3

# update and setup system
RUN apt-get update -y \
    && apt-get install -y bc less wget vim git \
    && apt-get install -y build-essential \
    && apt-get clean 

# init drop env
RUN conda update -n base -c defaults conda \
    && conda create -y -c anaconda -c conda-forge -c bioconda -c pytorch -n geneprofanalysis \
        "python>=3.8" \
        "numpy" \
        "pytorch" \
        "pandas" \
        "jupyter" \
        "tiledb-py>=0.8.8" \
        "snakemake" \
        "mlflow" \
    && conda clean --all --yes

COPY environment.yml /tmp/
RUN conda env update --prune -f /tmp/environment.yml \
    && conda clean --all --yes
#    && conda remove --force -n geneprofanalysis r-bh \

# use conda env to install ensembl
SHELL ["conda", "run", "-n", "geneprofanalysis", "/bin/bash", "-c"]
RUN pyensembl install --release 76 99 --species "homo_sapiens"

# init conda to be used directly on startup
SHELL ["/bin/bash", "-c"]
RUN conda init bash \
    && echo -e "\n# activate gene prof analysis environemnt\nconda activate geneprofanalysis\n" >> ~/.bashrc

# init command on startup
CMD [ "bash" ]
