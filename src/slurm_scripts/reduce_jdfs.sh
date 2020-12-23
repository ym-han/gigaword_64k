#!/bin/bash

#SBATCH --mail-type=ALL
#SBATCH --mail-user=yongming_han@brown.edu
#SBATCH --job-name="reduce_jdfs"
#SBATCH --output="reduce_jdfs.%j.%N.out"
#SBATCH --error="reduce_jdfs.%j.err"
#SBATCH -n 1
#SBATCH --export=ALL
#SBATCH -c 1
#SBATCH -t 20:00:00 
#SBATCH --mem-per-cpu=160G
#SBATCH --partition=batch

module load julia/1.5.0
cd /users/yh31/scratch/projects/gigaword_64k/
julia --project=@. /users/yh31/scratch/projects/gigaword_64k/src/reduce_jdfs.jl