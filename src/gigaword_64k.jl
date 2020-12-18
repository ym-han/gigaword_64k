module gigaword_64k

using Revise, Underscores
using FileTrees, Glob, DataStructures
using Gumbo, WordTokenizers
using AbstractTrees, Test
#using JLD

# /users/yh31/scratch/projects/gigaword_64k

# /users/yh31/scratch/datasets/entity_linking/raw_data/gigaword/giga5/data


# ok i shouldn't be lazy; i should make a proper env coz i'll need it to parallelize the thing

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



#==========
# CONSTANTS
#========== 


const path_afp_dir = "/users/yh31/scratch/datasets/entity_linking/raw_data/gigaword/giga5/data/afp_eng"


# for testing
const path_mtdoc_with_text_tags = "../test/test_data/afp/empty_doc_with_empty_text"
const path_empty_file = "../test/test_data/afp/empty_file"
const path_onedoc = "../test/test_data/afp/empty_doc_with_empty_text/one_doc"
const path_twodocs = "../test/test_data/afp/two_docs"

const path_big_file = "../test/test_data/afp/afp_eng_200304"


# =====
# UTILS
# =====

showall(x) = show(stdout, "text/plain", x) 

is_wanted(s::String) = length(s) >= 5 || all(isletter.(collect(s)))
# I'm tempted right now to not filter out numbers, punctuation etc when going through the individual files. 
# Just get the most common for the WHOLE gigaword corpus, and see how many of them actually are punctuation etc
# And only filter out punctuation out at _that_ stage

# naive implementation of most common things
most_common(c::Accumulator) = most_common(c, length(c))
most_common(c::Accumulator, k) = sort(collect(c), by=kv->kv[2], rev=true)[1:k] 
# TO DO: might be fun to code up a better version


# ===============
# TESTS FOR UTILS
# ===============
@testset "is_wanted" begin
    @test is_wanted("abc") == true
    @test is_wanted("aBc") == true

    # Filters out punctuation
    @test is_wanted("!") == false

    # Filters out stuff that's just fancy numbers and not v long
    @test is_wanted("3.77") == false

    # note
    @test is_wanted("") == true # but won't usually happen
end





# I: Figure out how to get the list of word tokens for each file, and then for each of the nyt_eng afp_eng etc directories






# doc = parsehtml(read(f_bigger, String))

# typeof(doc)
# top_k =  most_common(doc_counter)[1:500]
# showall(top_k)

#showall(doc_counter)


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
                #filter(is_wanted, __) |> 
                foldl((lst, str) -> inc!(doc_counter, lowercase(str)), __; init = []) 
            end 
        end
    end

    inc_counter_with_doc()
    return doc_counter
end


#/users/yh31/scratch/projects/gigaword_64k
data_tree = FileTree(path_afp_dir)




# ===================
# TESTS FOR MAIN FTNS
# ===================


# for count_words_from_file
@testset "count_words_from_file: empty docs" begin
    empty_f = parsehtml(read(path_empty_file, String))
    @test count_words_from_file(empty_f) == counter(String)
    @test_throws BoundsError most_common(count_words_from_file(empty_f), 1) 

    empty_f_with_txt_tags = parsehtml(read(path_mtdoc_with_text_tags, String))
    @test count_words_from_file(empty_f_with_txt_tags) == counter(String)
    @test_throws BoundsError most_common(count_words_from_file(empty_f_with_txt_tags), 1) 
end


@testset "count_words_from_file: simple" begin
    doc = parsehtml(read(path_onedoc, String))
    top_8 = most_common(count_words_from_file(doc), 8) 
    @test top_8 == [("trade" => 4),
                    (")" => 3), 
                    ("(" => 3),  
                    ("and" => 2),
                    ("on" => 2),
                    ("japan" => 2),
                    ("the" => 2),
                    ("organization" => 1)]
end


tc = count_words_from_file(doc)
JLD.save("test_tc.jld", "tc", tc)


# How long would it take for one computer to go throguh all of the files in, e.g., the afp directory?





## e.g.: /users/yh31/scratch/datasets/entity_linking/raw_data/gigaword/giga5/data/nyt_eng/nyt_eng_201012

## 2. figure out how best to get text from there

## 3. tokenize the text; don't add if punctuation

## II. do the map reduce thing with filetrees.jl

## 


#= Notes for future 
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


end
