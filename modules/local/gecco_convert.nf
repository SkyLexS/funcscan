process GECCO_CONVERT {
    tag "$meta"
    
    container 'quay.io/biocontainers/gecco:0.9.10--pyhdfd78af_0'

    input:
    tuple val(meta), path(gbk, stageAs: "input.gbk")
    
    output:
    tuple val(meta), path("*.gff"), emit: gff, optional: true
    tuple val(meta), path("*.region*.gbk"), emit: bigslice, optional: true
    tuple val(meta), path("*.clusters.tsv"), emit: clusters, optional: true
    tuple val(meta), path("*.features.tsv"), emit: features, optional: true
    tuple val(meta), path("gecco.log"), emit: log
    
    script:
    """
    echo "Starting GECCO run with custom HMM" >> gecco.log
    
        echo "Custom HMM run failed. GECCO run with default HMM" >> gecco.log
        gecco run \\
            --genome input.gbk \\
            --output-dir . \\
            --jobs 1 >> gecco.log 2>&1
    
    echo "Generated files after GECCO run:" >> gecco.log
    ls -la >> gecco.log
    
    if ls *.clusters.tsv 1> /dev/null 2>&1; then
        echo "GECCO clusters file found, converting." >> gecco.log
        echo "Converting to GFF format:" >> gecco.log
        if gecco convert clusters -i . --format gff >> gecco.log 2>&1; then
            echo "GFF conversion successful" >> gecco.log
        else
            echo "GFF conversion failed or not needed" >> gecco.log
        fi
        
        echo "Converting for BiG-SLiCE integration:" >> gecco.log
        if gecco convert gbk -i . --format bigslice >> gecco.log 2>&1; then
            echo "BiG-SLiCE conversion successful" >> gecco.log
        else
            echo "BiG-SLiCE conversion failed." >> gecco.log
        fi
    else
        echo "No clusters file generated, skipping conversions" >> gecco.log
    fi
    
    echo "Process completed. Final files:" >> gecco.log
    ls -la >> gecco.log
    """
}