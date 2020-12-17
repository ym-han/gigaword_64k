module gigaword_64k

using Revise, Underscores
using FileTrees, Glob, DataStructures
using Gumbo, WordTokenizers
using AbstractTrees, Test
using Transducers
import EzXML


# /users/yh31/scratch/datasets/entity_linking/raw_data

# ok i shouldn't be lazy; i should make a proper env coz i'll need it to parallelize the thing


# function text(cur_doc::HTMLDocument)
#     string_parts = []

#     for elt in PreOrderDFS(aaa.root) 
#         isa(elt, HTMLText) || continue
#         push!(string_parts, Gumbo.text(elt))
#     end

#     return join(string_parts, " ")
# end


#==========
# CONSTANTS
#========== 

const f_mtdoc = 

const f_onedoc = "/Users/ymh/Documents/Git_repos/NLP/sr_neural/data/test_data/giga_related/afp/one_doc"
const f_twodocs = "/Users/ymh/Documents/Git_repos/NLP/sr_neural/data/test_data/giga_related/afp/two_docs"



# =====
# UTILS
# =====


showall(x) = show(stdout, "text/plain", x) 

is_wanted(s::String) = a prev version: length(s) >= 3 || all(isletter.(collect(s)))
# I'm tempted right now to not filter out numbers, punctuation etc when going through the individual files. 
# Just get the most common for the WHOLE gigaword corpus, and see how many of them actually are punctuation etc
# And only filter out punctuation out at _that_ stage

# naive implementation of most common things
most_common(c::Accumulator) = most_common(c, length(c))
most_common(c::Accumulator, k) = sort(collect(c), by=kv->kv[2], rev=true)[1:k] 

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




"""
Returns counter consisting of words from file.
"""
function count_words_from_file(f :: String)


end

# TO DO: Make a few een simpler examples of these SGML files...


# draft case
f_onedoc = "/Users/ymh/Documents/Git_repos/NLP/sr_neural/data/test_data/giga_related/afp/one_doc"
doc = parsehtml(read(f_onedoc, String))
doc.root






f_bigger = "/Users/ymh/Documents/Git_repos/NLP/sr_neural/data/test_data/giga_related/afp/afp_eng_200304"
doc = parsehtml(read(f_bigger, String))

typeof(doc)
top_k =  most_common(doc_counter)[1:500]
showall(top_k)


showall(doc_counter)


"""
Tokenizes doc and returns word counts for all words ∈ doc
"""
function counter_from_doc(doc :: HTMLDocument)
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


# ===================
# TESTS FOR MAIN FTNS
# ===================


# for counter_from_doc

# TO DO make test for empty doc....
@testset "counter_from_doc: simple" begin
    doc = parsehtml(read(f_onedoc, String))
    top_8 = most_common(counter_from_doc(doc), 8) 
    @test top_8 == [("trade" => 4),
                    (")" => 3), 
                    ("(" => 3),  
                    ("and" => 2),
                    ("on" => 2),
                    ("japan" => 2),
                    ("the" => 2),
                    ("organization" => 1)]
end





tc = counter_from_doc(doc)
most_common(tc, 8)
most_common(tc, 3)[1]


## e.g.: /users/yh31/scratch/datasets/entity_linking/raw_data/gigaword/giga5/data/nyt_eng/nyt_eng_201012

## 2. figure out how best to get text from there

## 3. tokenize the text; don't add if punctuation

## II. do the map reduce thing with filetrees.jl

## 


#= Notes for future 
* EzXML won't work with SGML.
* Transducers.jl didn't seem to be any faster than base foldl and filter, though that might change in the future


function test_no_transducer(doc)
    for elt in PreOrderDFS(doc.root) 
        if isa(elt, HTMLText)

            #= 
            1. tokenize the text
                (note: each use of tokenize returns a 1-dim array of strings)
            2. filter out punctuation, numbers, etc
            3. increment counter accordingly
            =#
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
