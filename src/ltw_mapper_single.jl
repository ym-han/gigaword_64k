# SINGLE NODE/CORE VERSION
# Filtering out less than in ltw, since this corpus small

import Pkg; Pkg.instantiate()

include("/users/yh31/scratch/projects/gigaword_64k/src/gigaword_64k.jl")

const path_ltw_dir = "/users/yh31/scratch/datasets/entity_linking/raw_data/gigaword/giga5/data/ltw_eng"

const path_intermed_data = "/users/yh31/scratch/datasets/entity_linking/raw_data/gigaword/giga_topk/intermediate_files"
const path_intermed_ltw = joinpath(path_intermed_data, "ltw")

# const path_of_tree = path_ltw_dir
# const path_output = path_intermed_ltw
# const n_items = 8

process_part_of_tree(path_ltw_dir, path_intermed_ltw, 6)
# Sat 6pm: OK, calling the process_part_of_tree function didn't work, even though I had used an include and one less worker than i'd requested from slurm. one of the workers became uncommunicative for some reason


# So let's try putting the filetrees stuff in here...

#=
data_tree = FileTree(path_of_tree)

# 1. Get the list of names of files in tree
filenames = name.(files(data_tree))

# 2. For each year that's represented, randomly choose min(array_size, n_items) of the files in that year

pick_elts_from_arr(arr) = pick_elts(arr, n_items)

chosen_files = @_ filenames |> 
       collect(IterTools.groupby(year_from_fnm, __)) |> 
       map(pick_elts_from_arr, __) |> 
       vcat(__...) |> Set(__)

# 3. Get the resulting tree with `filter`
filtered_tree = filter(x->x.name ∈ chosen_files, data_tree, dirs=false)

# 4. load it; count words; save it
loaded_tree = FileTrees.load(filtered_tree; lazy = true) do file   
                  @_ file |>
                  string(FileTrees.path(__)) |> 
                  read_and_wc(__) |>
                  df_from_acc(__)
             end

out_tree = FileTrees.rename(loaded_tree, path_output)

FileTrees.save(out_tree) do acc_df
   savejdf(string(FileTrees.path(acc_df)) * ".jdf", FileTrees.get(acc_df))
end

#       @warn "failed to save $(string(FileTrees.path(acc_df)))"
#   end
=#