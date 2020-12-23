# SINGLE NODE/CORE VERSION

import Pkg; Pkg.instantiate()

include("/users/yh31/scratch/projects/gigaword_64k/src/gigaword_64k.jl")

const path_intermed_data = "/users/yh31/scratch/datasets/entity_linking/raw_data/gigaword/giga_topk/intermediate_files"

const output_dir = "/users/yh31/scratch/datasets/entity_linking/raw_data/gigaword/giga_topk/reductions"

reduce_jdfs_and_save(path_intermed_data, output_dir, ns_tuple = (70_000, 64_000))