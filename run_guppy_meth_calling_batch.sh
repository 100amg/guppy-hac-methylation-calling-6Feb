#!/bin/bash
set -e


# only does AHEAD right now
FAST5_DIR="/DATA4/amishi/AHEAD_converted_fast5"
BASE_OUTPUT_DIR="/DATA4/amishi/guppy_methcalling_16Feb_correct"
GUPPY_BIN="/DATA4/amishi/ont-guppy/bin/guppy_basecaller"
MODEL="/DATA4/amishi/ont-guppy/data/dna_r10.4.1_e8.2_400bps_5khz_modbases_5hmc_5mc_cg_hac_prom.cfg"
REFERENCE="/DATA4/amishi/reference.fasta"
TEMP_INPUT_DIR="/DATA4/amishi/guppy_methcalling_outputs_16Feb/temp_folder"

mkdir -p "$BASE_OUTPUT_DIR"

for fast5 in "$FAST5_DIR"/*.fast5; do
    [ -e "$fast5" ] || continue

    name=$(basename "$fast5" .fast5)
    OUTPUT_DIR="$BASE_OUTPUT_DIR/$name"

    echo "Processing: $name"

    mkdir -p "$OUTPUT_DIR"
    mkdir -p "$TEMP_INPUT_DIR"

    # Copy FAST5 into temporary folder
    cp "$fast5" "$TEMP_INPUT_DIR/"

    "$GUPPY_BIN" \
        -i "$TEMP_INPUT_DIR" \
        -s "$OUTPUT_DIR" \
        -c "$MODEL" \
        -a "$REFERENCE" \
        --bam_out \
        --move_and_trace \
        --min_qscore 9

    rm -r "$TEMP_INPUT_DIR"

    # Merge guppy BAMs
    samtools merge -@ 4 "$OUTPUT_DIR/${name}_aligned.bam" "$OUTPUT_DIR"/pass/*.bam

    # Sort
    samtools sort -@ 4 -o "$OUTPUT_DIR/${name}_sorted.bam" "$OUTPUT_DIR/${name}_aligned.bam"

    # Index
    samtools index "$OUTPUT_DIR/${name}_sorted.bam"

# Optional cleanup
rm "$OUTPUT_DIR/${name}_aligned.bam"

    echo "✓ Finished: $name"
done

echo "All files processed." 