import Pkg; Pkg.instantiate()

# Doing this one manually in interactive session...
# cna and wpb differ from the rest in that we're using all the data from them

include("/users/yh31/scratch/projects/gigaword_64k/src/gigaword_64k.jl")

const path_cna_input = "/users/yh31/scratch/datasets/entity_linking/raw_data/gigaword/giga5/data/cna_eng"

const path_intermed_data = "/users/yh31/scratch/datasets/entity_linking/raw_data/gigaword/giga_topk/intermediate_files"
const path_intermed_cna = joinpath(path_intermed_data, "cna")

#process_part_of_tree(path_afp_dir, path_intermed_afp, 4)

# trying with the filetrees stuff in here...

const path_output = path_intermed_cna
const path_input_dir = path_cna_input

data_tree = FileTree(path_input_dir)

# load it; count words; save it
loaded_tree = FileTrees.load(data_tree; lazy = true) do file   
   @_ file |>
   string(FileTrees.path(__)) |> 
   read_and_wc(__) |>
   df_from_acc(__)
   #    @warn "failed to load $(string(FileTrees.path(file)))"
end

out_tree = FileTrees.rename(loaded_tree, path_output)

FileTrees.save(out_tree) do acc_df
    savejdf(string(FileTrees.path(acc_df)) * ".jdf", FileTrees.get(acc_df))
#       @warn "failed to save $(string(FileTrees.path(acc_df)))"
#   end
end

# IF this works:
# 1. Try the function approach again. Try implmeneting the rleevant changes with the process function, and test it with run tests
# 2. Then try running it again with slurm
# 3. And only then move it outside the function if it doesn't work again

#=
path_testfile = joinpath(path_input_dir, "cna_eng_201001")
testdf = @_ path_testfile |>
   read_and_wc(__) |>
   df_from_acc(__)

savejdf(joinpath(path_tmp_test_output, "test" * ".jdf"), testdf)
=#