MASH tutorial
=============

This tutorial implements Mash pylogroup division as created in `this source <https://doi.org/10.1038%2Fs42003-020-01626-5>`_.

1. Run MASH on files 
`Mash <https://github.com/marbl/Mash>` .. code-block:: python can be installed through anaconda
.. code-block:: bash
   conda install -c bioconda mash

After activating Mash you can run the following snakemake rule to run Mash on all assembly files in a directory

.. code-block:: python
    rule mash_fasta:
    input:
        expand("../Assembly/Shovill/{file}/{file}.fna", file=filtered)
    params:
        out="../MGWAS/Mash/fasta",
        pref="../Assembly/Shovill/"
    conda:
        "envs/mash.yml"
    output:
        "../MGWAS/Mash/fasta.tsv"
    shell:
        """
        mash sketch -s 10000 -o {params.out} {input}
        mash dist {params.out}.msh {params.out}.msh -t > {output}
        """


2. Import MASH into R and cluster and other stuff
