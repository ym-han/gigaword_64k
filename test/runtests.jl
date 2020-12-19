using gigaword_64k, Gumbo, DataStructures
using Test

using gigaword_64k: path_afp_dir

const path_test_data = "/gpfs/scratch/yh31/projects/gigaword_64k/test/test_data"
const path_test_afp = joinpath(path_test_data ,"afp")
const path_test_cna = joinpath(path_test_data ,"cna")

const path_mtdoc_with_text_tags = joinpath(path_test_data ,"afp/empty_doc_with_empty_text")
const path_empty_file = joinpath(path_test_data, "afp/empty_file")
const path_onedoc = joinpath(path_test_data, "afp/one_doc")
const path_twodocs = joinpath(path_test_data, "afp/two_docs")

const path_big_file = joinpath(path_test_data, "afp/afp_eng_200304")

const path_test_output = "/gpfs/scratch/yh31/projects/gigaword_64k/test/test_data/test_output"


# ===============
# TESTS FOR UTILS
# ===============
using gigaword_64k: is_wanted

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
using gigaword_64k: year_from_fnm
@test year_from_fnm("wpb_eng_201012") == "2010"

using gigaword_64k: pick_elts
@test pick_elts([1,2], 3) == [1,2]
@test pick_elts([1,2, 3], 3) == [1,2, 3]


# for count_words_from_file
using gigaword_64k: count_words_from_file, most_common

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
    # path_manyfiles = joinpath(path_test_data, "manyfiles")
    # process_part_of_tree(path_manyfiles, path_tmp_test_output, 4)


    rm(path_tmp_test_output, recursive=true, force=true)
end

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
