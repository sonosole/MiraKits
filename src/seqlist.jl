# 根据字典生成 train/dev/test 等列表
export makelist_with_oov
export makelist_without_oov

"""
    makelist_with_oov(dictfile::String,
                      srclist::Vector{String},
                      dstfile::String;
                      leastwords::Int=1,
                      dlm::String=" ",
                      OOV::Int=2)

将多个列表文件用字典 Dict{String, Int} 标注成一个新的列表文件, e.g.

    /xdir/1.wav 2 2 8 36 2 2 33 2 2 2 2 11 28
    /xdir/2.wav 3 9 31 23 29 2 2
    /xdir/3.wav 2 31 2 2 19 2 2 2 2 20 32
    /xdir/4.wav 2 31 2 2 31 2 15 22 2 2 2 2 2
# Arguments
    dictfile   : 字典文件
    srclist    : 多个列表文件（带序列标注）
    dstfile    : 新的列表文件
    dlm        : 文件路径与标注之间的分割符号
    leastwords : 每个样本最少的集内词字符数

"""
function makelist_with_oov(dictfile::String,
                           srclist::Vector{String},
                           dstfile::String;
                           leastwords::Int=1,
                           dlm::String=" ",
                           OOV::Int=2)

    # 读取字典文件构造 Dict{String, Int}
    count = 0
    dict  = Dict()
    open(dictfile, "r") do io
        for w in eachline(io)
            count += 1
            push!(dict, string(w) => count)
        end
    end

    # 读取多个标注文件，构造常用的 train/test/dev/ 等列表之一
    OOVSTR = string(OOV)
    open(dstfile, "w") do io
        for src in srclist
            for line in eachline(src)
                infos = split(line, dlm)
                fname = infos[1]      # file path like "/data/abc.wav"
                label = infos[2]      # seqlabel  like "gè dì zhèng fǔ", 逗号分割

                tmp = ""
                NUM = 0
                for w in split(label," ")
                    str = string(get(dict, w, OOV))  # 不在字典里就标注为 OOV
                    tmp = tmp * " " * str            # 空格分割、拼接序列标注
                    if str ≠ OOVSTR
                        NUM += 1
                    end
                end
                if NUM ≥ leastwords          # 至少包含 leastwords 个集内词则作为
                    write(io, string(fname)) # 有效样本记录在 dstfile 内
                    write(io, tmp)
                    write(io, "\n")
                end
            end
        end
    end
end



"""
    makelist_without_oov(dictfile::String,
                         srclist::Vector{String},
                         dstfile::String;
                         leastwords::Int=1,
                         dlm::String=" ")

将多个列表文件用字典 Dict{String, Int} 标注成一个新的列表文件, e.g.

    /xdir/1.wav 36 33 11 28
    /xdir/2.wav 3 9 31 23 29
    /xdir/3.wav 31 19 20 32
    /xdir/4.wav 31 31 15 22
# Arguments
    dictfile   : 字典文件
    srclist    : 多个列表文件（带序列标注）
    dstfile    : 新的列表文件
    dlm        : 文件路径与标注之间的分割符号
    leastwords : 每个样本最少的集内词字符数

"""
function makelist_without_oov(dictfile::String,
                              srclist::Vector{String},
                              dstfile::String;
                              leastwords::Int=1,
                              dlm::String=" ")
    # 读取字典文件构造 Dict{String, Int}
    count = 0
    dict  = Dict()
    open(dictfile, "r") do io
        for w in eachline(io)
            count += 1
            push!(dict, string(w) => count)
        end
    end

    # 读取多个标注文件，构造常用的 train/test/dev/ 等列表之一
    OOVSTR = string(OOV)
    open(dstfile, "w") do io
        for src in srclist
            for line in eachline(src)
                infos = split(line, dlm)
                fname = infos[1]      # file path like "/data/abc.wav"
                label = infos[2]      # seqlabel  like "gè dì zhèng fǔ"

                tmp = ""
                NUM = 0
                for w in split(label," ")
                    str = get(dict, w, nothing)
                    if !isnothing(str)
                        NUM += 1
                        tmp *= " " * string(str)
                    end
                end
                if NUM ≥ leastwords
                    write(io, string(fname))
                    write(io, tmp)
                    write(io, "\n")
                end
            end
        end
    end
end
