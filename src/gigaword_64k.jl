module gigaword_64k

using Revise, Underscores
using FileTrees, Glob, DataStructures
using Gumbo, WordTokenizers
using AbstractTrees, Test
using JDF, DataFrames
using IterTools, StatsBase

export read_and_wc, process_part_of_tree

# cd /users/yh31/scratch/projects/gigaword_64k
# /users/yh31/scratch/datasets/entity_linking/raw_data/gigaword/giga5/data


# 8/5 * 4.9 * 1000 
# ok it'll probably take one computer ~130h just to process about 5gb of data / the afp_eng dir

# [yh31@node1323 data]$ du -shc ./*                          
# 4.9G    ./afp_eng
# 7.8G    ./apw_eng
# 263M    ./cna_eng
# 1.7G    ./ltw_eng
# 8.8G    ./nyt_eng
# 112M    ./wpb_eng
# 2.5G    ./xin_eng
# 26G     total

# there's about 12 files per year in afp_eng



# ==========
# CONSTANTS
# ========== 


const path_afp_dir = "/users/yh31/scratch/datasets/entity_linking/raw_data/gigaword/giga5/data/afp_eng"

# for testing
const path_test_data = "/gpfs/scratch/yh31/projects/gigaword_64k/test/test_data"
const path_test_afp = joinpath(path_test_data ,"afp")
const path_test_cna = joinpath(path_test_data ,"cna")


const path_mtdoc_with_text_tags = joinpath(path_test_data ,"afp/empty_doc_with_empty_text")
const path_empty_file = joinpath(path_test_data, "afp/empty_file")
const path_onedoc = joinpath(path_test_data, "afp/one_doc")
const path_twodocs = joinpath(path_test_data, "afp/two_docs")

const path_big_file = joinpath(path_test_data, "afp/afp_eng_200304")

const path_test_output = "/gpfs/scratch/yh31/projects/gigaword_64k/test/test_data/test_output"

# =====
# UTILS
# =====

showall(x) = show(stdout, "text/plain", x) 

is_wanted(s::String) = length(s) >= 7 || all(isletter.(collect(s)))
# A reason to be more stringent here: would allow us to have smaller dictionaries!
# imo it's OK to be stringent about how much to filter at this stage, because ultimately what we're doing is filtering out stuff from other copora based on what's in the exclusion list that were making. Being stringent here just means that we'd have a smaller exclusion list than we'd otherwise have. And we can always apply more filters later.

# naive implementation of most common things
#most_common(c::Accumulator) = most_common(c, length(c))
#most_common(c::Accumulator, k) = sort(collect(c), by=kv->kv[2], rev=true)[1:k] 



# ==================================
# MAIN functions (including helpers)
# ==================================

"Returns a df that consists of pairs in `acc`"
function df_from_acc(acc :: Accumulator)
    df = DataFrame([String, Int], [:word, :freq])

    for pair in acc
        push!(df, pair)
    end
    return df
end


"""
Tokenizes doc and returns word counts for all words ∈ doc
"""
function count_words_from_file(doc :: HTMLDocument)
    doc_counter = counter(String)

    "Helper function"
    function inc_counter_with_doc()
        for elt in PreOrderDFS(doc.root) 
            if isa(elt, HTMLText)
                #= 
                1. tokenize the text 
                    (note: each use of tokenize returns a 1-dim array of strings)
                2. increment counter with lowercase repn of each word
                =#
                @_ tokenize(elt.text) |>
                filter(is_wanted, __) |> 
                foldl((lst, str) -> inc!(doc_counter, lowercase(str)), __; init = []) 
            end 
        end
    end

    inc_counter_with_doc()
    return doc_counter
end

"Composes file reading and count_words_from_file"
read_and_wc(filepath::String) = @_ read(filepath, String) |> 
                 parsehtml(__) |> 
                 count_words_from_file(__)


"Returns year from filename in gigaword corpus"
year_from_fnm(fnm :: String) = split(fnm, "_")[3][1:4]

"Picks min(`k`, size of array) elements from array"
pick_elts(arr, k :: Integer) = length(arr) <= k ? arr : sample(arr, k, replace=false) 

"Given FileTree for dir, return FileTree with __only__ the files we want to sample from"
function process_part_of_tree(path_of_tree :: String, path_output :: String, n_items :: Integer)
    # `n_items` is number of items we want to get per year

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
        read_and_wc(__)
    end

    out_tree = FileTrees.rename(loaded_tree, path_output)

    FileTrees.save(out_tree) do acc
        acc_df = @_ acc |> FileTrees.get(__) |> df_from_acc(__)
        savejdf(string(FileTrees.path(acc)) * ".jdf", acc_df)
    end
end



end


#= Notes for future 

# Re FileTrees.jl

## Not sure quid difference between `filtered_tree` and `data_tree[filtered_tree]`
typeof(filtered_tree) # FileTree
typeof(data_tree[filtered_tree]) # FileTree

filtered_tree == data_tree[filtered_tree]
# false, hmm, not sure why
files(filtered_tree) == files(data_tree[filtered_tree])
# this is true

# for testing
filtered_filenames = name.(files(filtered_tree))
Set(filtered_filenames) == chosen_files



* EzXML won't work with SGML.
* Transducers.jl didn't seem to be any faster than base foldl and filter, though that might change in the future

using Transducers

function test_no_transducer(doc)
    for elt in PreOrderDFS(doc.root) 
        if isa(elt, HTMLText)

             
            1. tokenize the text
                (note: each use of tokenize returns a 1-dim array of strings)
            2. filter out punctuation, numbers, etc
            3. increment counter accordingly
            
            @_ tokenize(elt.text) |>
            filter(is_wanted, __) |> 
            foldl((lst, str) -> inc!(doc_counter, str), __; init = []) 
        end 
    end
end

function test_transducer(doc)
    for elt in PreOrderDFS(doc.root) 
        if isa(elt, HTMLText)
            tokenize(elt.text) |>
            Filter(is_wanted) |> 
            foldxl((lst, str) -> inc!(doc_counter, str); init = [])
            # to do: figure out why we don't need underscores for this!
        end 
    end
end


@time test_no_transducer(doc)
# 200308: 9.063 s
# 200304: 82.035s
# reduce version: 82.059720 seconds (211.31 M allocations: 13.842 GiB, 4.55% gc time)
# re-doing it again with foldl
#  77.735108 seconds (212.57 M allocations: 13.857 GiB, 4.71% gc time)

@time test_transducer(doc)
# 200308: 9.11s!
# 200304: 75.447160 seconds (211.13 M allocations: 13.748 GiB, 3.60% gc time)
=#



