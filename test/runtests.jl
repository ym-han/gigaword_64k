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


# ===================
# TESTS FOR MAIN FTNS 
# ===================


@testset "df_from_acc" begin
    # empty case
    mt_acc = counter(String)
    df_from_mt_acc = df_from_acc(mt_acc)
    @test size(df_from_mt_acc) == (0, 2)

    # case with three entries
    acc_t = counter(String)
    acc_t["a"] = 1; acc_t["b"] = 2; acc_t["c"] = 7
    df_at = df_from_acc(acc_t)

    @test df_at[:word] == ["c", "b", "a"]
    @test df_at[:freq] == [7, 2, 1]
end

@testset "acc_from_df" begin
    mt_acc = counter(String)
    df_from_mt_acc = df_from_acc(mt_acc)
    @test acc_from_df(df_from_mt_acc) == mt_acc

    # case with three entries
    acc_t = counter(String)
    acc_t["a"] = 1; acc_t["b"] = 2; acc_t["c"] = 7
    df_at = df_from_acc(acc_t)

    @test acc_from_df(df_at) == acc_t
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
        "cna_eng_199710.jdf")) |> DataFrame(__)
    acc_df_cna_97_10 = @_ read_and_wc(joinpath(path_test_cna, "cna_eng_199710")) |> df_from_acc(__)

    @test jdf_cna_97_10 == acc_df_cna_97_10 


    # to eyeball: case where there's more than 4 files per year
    path_manyfiles = joinpath(path_test_data, "manyfiles")
    process_part_of_tree(path_manyfiles, path_tmp_test_output, 4)
    # note that this will delete everything that was in the tmp test output directory before outputting the stuff

    many_files_dir = FileTree(path_tmp_test_output)
    @test length(files(many_files_dir[glob"*.jdf"])) == 24


    rm(path_tmp_test_output, recursive=true, force=true)
end


#= 
Note on that last test:

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
