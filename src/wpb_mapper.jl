import Pkg; Pkg.instantiate()

include("/users/yh31/scratch/projects/gigaword_64k/src/gigaword_64k.jl")

const path_wpb_dir = "/users/yh31/scratch/datasets/entity_linking/raw_data/gigaword/giga5/data/wpb_eng"

const path_intermed_data = "/users/yh31/scratch/datasets/entity_linking/raw_data/gigaword/giga_topk/intermediate_files"
const path_intermed_wpb = joinpath(path_intermed_data, "wpb")

#process_part_of_tree(path_afp_dir, path_intermed_afp, 4)

# trying with the filetrees stuff in here...

const path_output = path_intermed_wpb
const path_input_dir = path_wpb_dir

data_tree = FileTree(path_input_dir)

# load it; count words; save it
loaded_tree = FileTrees.load(data_tree; lazy = true) do file
   try
       @_ file |>
       string(FileTrees.path(__)) |> 
       read_and_wc(__) |>
       FileTrees.get(__) |>
       df_from_acc(__)
   catch
       @warn "failed to load $(string(FileTrees.path(file)))"
   end
end

out_tree = FileTrees.rename(loaded_tree, path_output)

FileTrees.save(out_tree) do acc_df
   try
       savejdf(string(FileTrees.path(acc_df)) * ".jdf", acc_df)
   catch
       @warn "failed to save $(string(FileTrees.path(acc_df)))"
   end
end
