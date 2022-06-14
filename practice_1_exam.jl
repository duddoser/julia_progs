# ---------------- вопрос 1 ---------------------
function bubblesort!(a) # если добавляется параметр by, то применяем функцию: if by(a[i]) > by(a[i+1]); значение по умолчанию by = identity
    n = length(a)
    for k in 1:n-1
        is_sorted = true
        for i in firstindex(a):lastindex(a)-k
            if a[i] > a[i+1]
                a[i], a[i+1] = a[i+1], a[i]
                is_sorted = false
            end
        end
        if is_sorted
            break
        end
    end
    return a
end


function issorted(a)
    n = length(a)
    for i in firstindex(a):lastindex(a)
        if a[i] > a[i+1]
            return false
        end
    end
    return true
end


function bubblesortperm!(a)
    n = length(a)
    indexes = collect(firstindex(a):lastindex(a))
    for k in 1:n-1
        is_sorted = true
        for i in firstindex(a):lastindex(a)-k
            if a[i] > a[i+1]
                a[i], a[i+1] = a[i+1], a[i]
                indexes[i], indexes[i+1] = indexes[i+1], indexes[i]
                is_sorted = false
            end
        end
        if is_sorted
            break
        end
    end
    return indexes
end


bubblesortperm(a) = bubblesortperm!(deepcopy(a))

# Дополнительно

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

# ---------------------- 2 вопрос ------------------------------

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


# ---------------- 3 вопрос -------------------
function slice(A::Matrix, I::Vectot{Int}, J::Vector{Int})
    B=Matrix{eltype(A)}(undef,length(I),length(J))
    for i in I
        for j in J
            B[i,j]=A[I[i],J[j]]
        end
    end
    return B
end

function bubblesort!(A::AbstractMatrix)
    for j in size(A,2)
        bubblesort!(@view A[:,j]) # - осуществляется сортировка j-го столбца с помощью ранее написанной функции
    end
    return A
end

# сортировка копии исходного массива
bubblesort(A::AbstractMatrix{T}) where T <: Union{Real,Char,String} = bubblesort!(deepcopy(A))


function bubblesortperm!(A::AbstractMatrix{T}) where T <: Union{Real,Char,String}
    indexes = Matrix{Int}(undef,size(A)) 
    for j in size(A,2)
        indexes[:,j] = bubblesortperm!(@view A[:,j]) 
    end
    return indexes
end


bubblesortperm(A::AbstractMatrix{T}) where T <: Union{Real,Char,String} = bubblesortperm!(deepcopy(A))


sortkey!(A::AbstractMarix, key_values) = A[:, sortperm!(key_values)]
sortkey!(A, sum(A, dim=1))
