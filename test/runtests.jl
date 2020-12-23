# TO DO: revise in light of how gigaword no longer a module
include(joinpath(@__DIR__, "../src/gigaword_64k.jl"))
using Test, Revise

const path_test_data = joinpath(@__DIR__, "test_data")
const path_test_afp = joinpath(path_test_data,"afp")
const path_test_cna = joinpath(path_test_data,"cna")

const path_mtdoc_with_text_tags = joinpath(path_test_data,"afp/empty_doc_with_empty_text")
const path_empty_file = joinpath(path_test_data, "afp/empty_file")
const path_onedoc = joinpath(path_test_data, "afp/one_doc")
const path_twodocs = joinpath(path_test_data, "afp/two_docs")

const path_big_file = joinpath(path_test_data, "afp/afp_eng_200304")

const path_test_output = joinpath(path_test_data, "test_output")



# ===============
# TESTS FOR UTILS
# ===============
#using gigaword_64k: is_wanted

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

@testset "lzfoldl" begin
    @test lzfoldl((x,y)->x+y, list(1, 2, 3)) == 6

    @test lzfoldl((x,y)->x-y, list(1, 2, 3)) == -4
    # this is a good test case for foldl, since foldr would return -2
end

# ===================
# TESTS FOR MAIN FTNS 
# ===================


@testset "acc_to_df" begin
    # empty case
    mt_acc = counter(String)
    df_from_mt_acc = acc_to_df(mt_acc)
    @test size(df_from_mt_acc) == (0, 2)

    # case with three entries
    acc_t = counter(String)
    acc_t["a"] = 1; acc_t["b"] = 2; acc_t["c"] = 7
    df_at = acc_to_df(acc_t)

    @test df_at[:word] == ["c", "b", "a"]
    @test df_at[:freq] == [7, 2, 1]
end

@testset "df_to_acc" begin
    mt_acc = counter(String)
    df_from_mt_acc = acc_to_df(mt_acc)
    @test df_to_acc(df_from_mt_acc) == mt_acc

    # case with three entries
    acc_t = counter(String)
    acc_t["a"] = 1; acc_t["b"] = 2; acc_t["c"] = 7
    df_at = acc_to_df(acc_t)

    @test df_to_acc(df_at) == acc_t
end



#using gigaword_64k: year_from_fnm
@test year_from_fnm("wpb_eng_201012") == "2010"

#using gigaword_64k: pick_elts
@test pick_elts([1,2], 3) == [1,2]
@test pick_elts([1,2, 3], 3) == [1,2, 3]


# for count_words_from_file

#using gigaword_64k: count_words_from_file, most_common

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
                    ("and" => 2),
                    ("the" => 2),
                    ("japan" => 2),
                    ("on" => 2),
                    ("vaile" => 1),
                    ("eu" => 1),
                    ("global" => 1)]
end



@testset "process_part_of_tree" begin
    path_tmp_test_output = joinpath(path_test_output, "tmp")
    process_part_of_tree(path_test_cna, path_tmp_test_output, 4)

    jdf_cna_97_10 = @_ JDF.load(joinpath(path_tmp_test_output, 
        "cna_eng_199710.jdf")) |> DataFrame
    acc_df_cna_97_10 = read_and_wc(joinpath(path_test_cna, "cna_eng_199710")) |> acc_to_df

    @test jdf_cna_97_10 == acc_df_cna_97_10 


    # to eyeball: case where there's more than 4 files per year
    path_manyfiles = joinpath(path_test_data, "manyfiles")
    process_part_of_tree(path_manyfiles, path_tmp_test_output, 4)
    # note that this will delete everything that was in the tmp test output directory before outputting the stuff

    many_files_dir = FileTree(path_tmp_test_output)
    @test length(files(many_files_dir[glob"*.jdf"])) == 24


    rm(path_tmp_test_output, recursive=true, force=true)
end

#    jdf_to_df(joinpath(path_test_data_reds, "a", "df1") * ".jdf")


@testset "reduce_files" begin
    # 1. Make the test data
    path_test_data_reds = joinpath(path_test_data, "test_data_for_reductions")

    a_1 = counter(String)
    a_1["w1"] = 1; a_1["w2"] = 3
    df_a1 = acc_to_df(a_1)

    a_2 = counter(String)
    a_2["w1"] = 1; a_2["w2"] = 2; a_2["w3"] = 7
    df_a2 = acc_to_df(a_2)

    a_3 = counter(String)
    a_3["w1"] = 1
    df_a3 = acc_to_df(a_3)

    function dmapper(dirname)
        for (i, df) in enumerate([df_a1, df_a2, df_a3])
            fname = joinpath(path_test_data_reds, dirname, "df") * string(i) * ".jdf"
            savejdf(fname, df) 
        end
    end
    map(dmapper, ["a", "b", "c"])

    # 2. Reduce the files


    ## Testing reduce_jdfs
    final_to_test = reduce_jdfs(path_test_data_reds)
    correct_final_acc = counter(String)
    correct_final_acc["w1"] = 9; correct_final_acc["w2"] = 15; correct_final_acc["w3"] = 21
    @test final_to_test == correct_final_acc

    ## Testing reduce_jdfs_and_save
    reduce_jdfs_and_save(path_test_data_reds, path_test_data; ns_tuple = (2, 11))

    top2_loaded_to_test = joinpath(path_test_data, "final_df_2.jdf") |> jdf_to_df |> df_to_acc
    top3_loaded_to_test = joinpath(path_test_data, "final_df_3.jdf") |> jdf_to_df |> df_to_acc

    @test acc_to_df(top2_loaded_to_test) == acc_to_df(nlargest(correct_final_acc, 2))
    @test top3_loaded_to_test == correct_final_acc

    rm(path_test_data_reds, recursive=true, force=true)

end



    # dirnames = name.(dirs(testft))
    # jdf_dirs = Set(filter(s->endswith(s, "jdf"), dirnames))
    # jdf_tree = filter(x->name(x) ∈ jdf_dirs, testft, dirs=true)

    # tree_of_dfs = FileTrees.load(testft[glob"*/*.jdf"], dirs = true) do dir   
    #        @_ dir |> string(FileTrees.path(__)) |> JDF.load |> DataFrame
    #     end

    # 3. Test the reduction code
    # function red_inner_dir(subtree)
    #     reducevalues(subtree, init=nothing) do df1, df2
    #         if df1 isa DataFrame && df2 isa DataFrame
    #             @info "first branch"
    #             (acc1, acc2) = df_to_acc.((df1, df2))
    #             merge!(acc1, acc2)
    #             @info acc1
    #             return acc1

    #         elseif df1 isa DataFrame && !isa(df2, DataFrame)
    #             return df_to_acc(df1)

    #         elseif !isa(df1, DataFrame) && isa(df2, DataFrame)
    #             return df_to_acc(df2)

    #         else
    #             @info inputs to reducevalues were not dfs
    #             return nothing
    #         end
    #     end
    # # end
    # reduced_subdirs = mapsubtrees(red_inner_dir, testft, glob"*") 


#= 
Note on the many_files_dir test

julia> many_files_dir[glob"*.jdf"]
/gpfs/scratch/yh31/projects/gigaword_64k/test/test_data/test_output/tmp/
├─ cna_eng_200404.jdf/
│  ├─ freq
│  ├─ metadata.jls
│  └─ word
├─ cna_eng_200406.jdf/
│  ├─ freq
│  ├─ metadata.jls
│  └─ word
├─ cna_eng_200409.jdf/
│  ├─ freq
│  ├─ metadata.jls
│  └─ word
├─ cna_eng_200410.jdf/
│  ├─ freq
│  ├─ metadata.jls
│  └─ word
├─ cna_eng_200507.jdf/
│  ├─ freq
│  ├─ metadata.jls
│  └─ word
├─ cna_eng_200508.jdf/
│  ├─ freq
│  ├─ metadata.jls
│  └─ word
├─ cna_eng_200509.jdf/
│  ├─ freq
│  ├─ metadata.jls
│  └─ word
└─ cna_eng_200510.jdf/
   ├─ freq
   ├─ metadata.jls
   └─ word
=#


#=
jdf_cna_200403 = @_ JDF.load(joinpath(path_tmp_test_output, 
        "cna_eng_199710.jdf")) |> DataFrame(__)
=#


# testing with mt-ish files
#=
tree_of_mts = FileTrees.load(data_tree[glob"empty*"]; lazy = true) do file
    @_ file |> 
    string(FileTrees.path(__)) |> 
    read(__, String) |> 
    parsehtml(__) |> 
    count_words_from_file(__)
end
=#
