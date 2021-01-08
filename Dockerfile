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
RUN conda create -y -c anaconda -c conda-forge -c bioconda -c pytorch -n geneprofanalysis \
        "python>=3.8" \
        "numpy" \
        "pytorch" \
        "pandas" 

COPY environment.yml /tmp/
RUN conda env update --prune -f /tmp/environment.yml \
    && conda remove --force -n drop drop bioconductor-bsgenome.hsapiens.ucsc.hg19 r-bh \
    && conda clean --all --yes

RUN conda init bash \
    && conda activate geneprofanalysis \
    && pyensembl install --release 76 99 --species "homo_sapiens"

CMD [ "bash" ]
