#!/bin/bash

#SBATCH --mail-type=ALL
#SBATCH --mail-user=yongming_han@brown.edu
#SBATCH --job-name="wpb_mapper"
#SBATCH --output="wpb_mapper.%j.%N.out"
#SBATCH --error="wpb_mapper.%j.err"
#SBATCH -n 1
#SBATCH --export=ALL
#SBATCH -c 1
#SBATCH -t 1:30:00 
#SBATCH --mem-per-cpu=12G
#SBATCH --partition=batch

module load julia/1.5.0
cd /users/yh31/scratch/projects/gigaword_64k/
julia --project=@. /users/yh31/scratch/projects/gigaword_64k/src/wpb_mapper.jl