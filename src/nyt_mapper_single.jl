# SINGLE NODE/CORE VERSION

import Pkg; Pkg.instantiate()

include("/users/yh31/scratch/projects/gigaword_64k/src/gigaword_64k.jl")

const path_nyt_dir = "/users/yh31/scratch/datasets/entity_linking/raw_data/gigaword/giga5/data/nyt_eng"

const path_intermed_data = "/users/yh31/scratch/datasets/entity_linking/raw_data/gigaword/giga_topk/intermediate_files"
const path_intermed_nyt = joinpath(path_intermed_data, "nyt")



process_part_of_tree(path_nyt_dir, path_intermed_nyt, 4)
