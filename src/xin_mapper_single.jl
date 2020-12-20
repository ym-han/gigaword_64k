# SINGLE NODE/CORE VERSION

import Pkg; Pkg.instantiate()

include("/users/yh31/scratch/projects/gigaword_64k/src/gigaword_64k.jl")

const path_xin_dir = "/users/yh31/scratch/datasets/entity_linking/raw_data/gigaword/giga5/data/xin_eng"

const path_intermed_data = "/users/yh31/scratch/datasets/entity_linking/raw_data/gigaword/giga_topk/intermediate_files"
const path_intermed_xin = joinpath(path_intermed_data, "xin")

# const path_of_tree = path_xin_dir
# const path_output = path_intermed_xin
# const n_items = 8

process_part_of_tree(path_xin_dir, path_intermed_xin, 4)