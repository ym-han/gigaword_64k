try
     using ClusterManagers
catch
     import Pkg
     Pkg.add("ClusterManagers")
end

using ClusterManagers
using Distributed

addprocs_slurm(6, exeflags="--project=$(Base.active_project())")

@everywhere begin
    import Pkg; Pkg.instantiate()

    include("gigaword_64k.jl")
    
    const path_afp_dir = "/users/yh31/scratch/datasets/entity_linking/raw_data/gigaword/giga5/data/afp_eng"
    const path_intermed_data = "/users/yh31/scratch/datasets/entity_linking/raw_data/gigaword/giga_topk/intermediate_files"
    const path_intermed_afp = joinpath(path_intermed_data, "afp")
    const path_intermed_cna = joinpath(path_intermed_data, "cna")
    const path_intermed_xin = joinpath(path_intermed_data, "xin")
    const path_intermed_nyt = joinpath(path_intermed_data, "nyt")

end


process_part_of_tree(path_afp_dir, path_intermed_afp, 4)

# if this still doesn't work, next step is to try putting the filetrees stuff in here