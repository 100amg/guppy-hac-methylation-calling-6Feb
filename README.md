# Guppy HAC Methylation Calling Pipeline Using FAST5 Data

Pipeline for Oxford Nanopore HAC basecalling and direct methylation calling using Guppy modified-base models on FAST5 data.

---

# Overview

This workflow performs Oxford Nanopore methylation calling using Guppy HAC modified-base models on FAST5 files generated from POD5 data.

The workflow performs:

* HAC basecalling
* Direct methylation calling
* Alignment to a reference genome
* Move table and trace generation
* BAM merging
* BAM sorting
* BAM indexing

The workflow produces methylation-tagged BAM files containing:

* aligned reads
* MM methylation tags
* ML methylation probability tags
* 5mC calls
* 5hmC calls

The workflow corresponds specifically to:

| Step | Script                         | Purpose                                      |
| ---- | ------------------------------ | -------------------------------------------- |
| 1    | `run_guppy_meth_calling_batch.sh` | HAC basecalling + direct methylation calling |

`run_guppy_meth_calling_batch.sh` performs Guppy HAC basecalling, native modified-base calling, alignment, move-table generation, BAM merging, BAM sorting, and BAM indexing.

---

# Important Note on FAST5 Generation

This workflow operates on FAST5 files:

```text id="jlwm9t"
AHEAD_converted_fast5/
```

The FAST5 files were generated from original POD5 data prior to running this workflow.

The current workflow assumes:

* FAST5 conversion was completed successfully before methylation calling
* Converted FAST5 files are already present in the input directory

---

# Repository Structure

```text id="jlwm4u"
guppy-hac-methylation-pipeline/
│
├── README.md
│
├── run_guppy_meth_calling_batch.sh
│
├── reference.fasta
│
├── reference.fasta.fai
│
└── .gitignore
```

---

# Required Input Files

The workflow requires:

* `.fast5` files
* Reference FASTA
* FASTA index (`.fai`)
* Guppy HAC modified-base model

Example:

```text id="jlwm1n"
project/
├── AHEAD_converted_fast5/
│   ├── sample1.fast5
│   └── sample2.fast5
├── reference.fasta
├── reference.fasta.fai
├── ont-guppy/
└── run_guppy_hac_methylation.sh
```

---

# Software Requirements

| Software | Purpose                            |
| -------- | ---------------------------------- |
| Guppy    | HAC methylation calling            |
| Samtools | BAM merging, sorting, and indexing |

---

# Guppy HAC Modified-Base Model Used

The workflow uses:

```text id="jlwm6v"
dna_r10.4.1_e8.2_400bps_5khz_modbases_5hmc_5mc_cg_hac_prom.cfg
```

This configuration performs:

* HAC basecalling
* 5mC detection
* 5hmC detection
* Reference alignment
* Methylation tagging

The model corresponds to:

* R10.4.1 chemistry
* E8.2 pores
* 5 kHz sampling rate

---

# Workflow

# Step 1 — Guppy HAC Methylation Calling

Edit the following variables inside:

```text id="jlwm5m"
run_guppy_meth_calling_batch.sh
```

Set:

```bash id="jlwmzz"
FAST5_DIR=
BASE_OUTPUT_DIR=
GUPPY_BIN=
MODEL=
REFERENCE=
TEMP_INPUT_DIR=
```

Run:

```bash id="jlwmol"
chmod +x run_guppy_meth_calling_batch.sh

bash run_guppy_meth_calling_batch.sh
```

---

# Main Guppy Command

```bash id="jlwmz7"
guppy_basecaller \
    -i input_fast5_directory \
    -s output_directory \
    -c dna_r10.4.1_e8.2_400bps_5khz_modbases_5hmc_5mc_cg_hac_prom.cfg \
    -a reference.fasta \
    --bam_out \
    --move_and_trace \
    --min_qscore 9
```

---

# Important Parameters

| Parameter          | Description                             |
| ------------------ | --------------------------------------- |
| `-i`               | Input FAST5 directory                   |
| `-s`               | Output directory                        |
| `-c`               | Guppy HAC modified-base configuration   |
| `-a`               | Reference genome for alignment          |
| `--bam_out`        | Outputs BAM format                      |
| `--move_and_trace` | Stores move table and trace information |
| `--min_qscore 9`   | Filters low-quality reads               |

---

# Temporary FAST5 Input Handling

The workflow processes one FAST5 file at a time by:

* Copying a FAST5 file into a temporary directory
* Running Guppy on that temporary directory
* Removing the temporary directory after processing

This is implemented to isolate per-sample Guppy runs.

Temporary directory used:

```text id="jlwm53"
/DATA4/amishi/guppy_methcalling_outputs_16Feb/temp_folder
```

---

# BAM Post-Processing

After Guppy finishes:

PASS BAM files are merged using:

```bash id="jlwm97"
samtools merge
```

BAMs are sorted using:

```bash id="jlwm0b"
samtools sort
```

BAMs are indexed using:

```bash id="jlwmjf"
samtools index
```

---

# Output Files

Output directory:

```text id="jlwm9r"
guppy_methcalling_16Feb_correct/
```

For each sample:

```text id="jlwmrv"
sample/
├── pass/
├── fail/
├── sequencing_summary.txt
├── sample_aligned.bam
├── sample_sorted.bam
└── sample_sorted.bam.bai
```

Final BAM outputs contain:

* aligned reads
* MM tags
* ML tags
* methylation probabilities
* 5mC calls
* 5hmC calls

---

# Verifying Methylation Calling

Inspect BAM contents:

```bash id="jlwmj5"
samtools view sample_sorted.bam | head
```

Successful methylation calling produces tags such as:

```text id="jlwmvq"
MM:Z:
ML:B:C
```

These confirm successful modified-base calling.

---

# Verifying Outputs

List generated BAM files:

```bash id="jlwmu1"
ls -lh guppy_methcalling_16Feb_correct/
```

Check BAM statistics:

```bash id="jlwm9c"
samtools flagstat sample_sorted.bam
```

Count aligned reads:

```bash id="jlwmu6"
samtools view -c sample_sorted.bam
```

---

# Documentation

# Full Documentation

Detailed workflow documentation is available here:

[Google Docs Documentation](https://docs.google.com/document/d/1Wj-gkxO755uF2FdEJx0VJSViN6hjUYA6_AcrjSxTIXk/edit?tab=t.24k2vchv4y7f)
