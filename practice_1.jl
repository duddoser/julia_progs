# ---------------- пункт 1 ---------------------
function my_findall(a)
    res = Vector{Int}(undef, size(a))
    res[begin] = firstindex(a)
    n = firstindex(res)
    for i in firstindex(a) + 1 : lastindex(a)
        if a[i]
            n += 1
            res[n] = i
        end
    end
    return resize!(res,n)
end

function my_findfirst(a)
    i_first = 0
    for i in firstindex(a) + 1 : lastindex(a)
        if a[i] && i_first == 0
            i_first = i
        end
    end
    return i_first
end

function my_findlast(a)
    i_last = 0
    for i in firstindex(a) + 1 : lastindex(a)
        if a[i]
            i_last = i
        end
    end
    return i_last
end

function my_filter(condition, a)
    res = Vector{Int}(undef, size(a))
    res[begin] = firstindex(a)
    n = firstindex(res)
    for i in firstindex(a) + 1 : lastindex(a)
        if condition(a[i])
            n += 1
            res[n] = a[i]
        end
    end
    return resize!(res, n)
end


# ---------------- пункт 2 ---------------------
function bubblesort(A::Array{Int}, by = identity)
    X = deepcopy(A)
    for i in 1:size(A, 1)
        for j in 1:size(A, 1) - i
            if (by(X[j]) > by(X[j+1]))
                X[j], X[j+1] = X[j+1], X[j]
            end
        end
    end
    return X
end

function bubblesort!(A::Array{Int}, by = identity)
    for i in 1:size(A, 1)
        for j in 1:size(A, 1)-i
            if (by(A[j]) > by(A[j+1]))
                A[j], A[j+1] = A[j+1], A[j]
            end
        end
    end
    return A
end

function bubblesortperm(A::Array{Int}, by = identity)
    indexes=collect(1:size(A, 1))
    for i in 1:size(A, 1)
        for j in 1:size(A, 1)-i
            if (by(A[j]) > by(A[j+1]))
                indexes[j], indexes[j+1] = indexes[j+1], indexes[j]
            end
        end
    end
    return indexes
end

function bubblesortperm!(A::Array{Int}, B::Array{Int}, by = identity)
    if (size(A, 1) == size(B, 1))
        B = collect(1:size(A, 1))
        for i in 1:size(A, 1)
            for j in 1:size(A, 1)-i
                if (by(A[j]) > by(A[j+1]))
                    B[j], B[j+1] = B[j+1], B[j]
                end
            end
        end
        return B
    end
end
