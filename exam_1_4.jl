# ---------------- вопрос 1 ---------------------
#Сортирвка пузырьком. issorted, sortperm!, sort!. Сортирвка по значению функции.
function bubblesort!(a) # если добавляется параметр by, то применяем функцию и получаем такую строчку:
    n = length(a)  # if by(a[i]) > by(a[i+1]); значение по умолчанию by = identity
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
    
# vibof в билете написал и sort! но в лекциях у него нет, а этот код я нашла в гитхабе джулии; это конкретно если параметр InsertionSortAlg
# и смысл вопроса, наверное, в том, что надо сказать, что эта функция принимает как параметр разные алгоритмы сортировки 
function sort!(v::AbstractVector, lo::Integer, hi::Integer, ::InsertionSortAlg, o::Ordering)
    @inbounds for i = lo+1:hi
        j = i
        x = v[i]
        while j > lo && lt(o, x, v[j-1])
            v[j] = v[j-1]
            j -= 1
        end
        v[j] = x
    end
    return v
end

# Дополнительно (это я стырила у челика, смысла здесь особо не вижу, но на всякий случай показываю)
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
#findall, findfirst, findlast, filter

function findall(a)
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

function findfirst(a)
    i_first = 0
    for i in firstindex(a) + 1 : lastindex(a)
        if a[i] && i_first == 0
            i_first = i
        end
    end
    return i_first
end

function findlast(a)
    i_last = 0
    for i in firstindex(a) + 1 : lastindex(a)
        if a[i]
            i_last = i
        end
    end
    return i_last
end

function filter(condition, a)
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
#Сортирвка столбцов матрицы по ключу. Срезы

# реализация среза матрицы
function slice(A::Matrix, I::Vectot{Int}, J::Vector{Int})
    B=Matrix{eltype(A)}(undef,length(I),length(J))
    for i in I
        for j in J
            B[i,j]=A[I[i],J[j]]
        end
    end
    return B
end


# сортировка пузырьком столбца матрицы (если просят сортировку строки, то нужно транспонировать матрицу)
# и засунуть в этот баблсорт
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

# сортировка матрицы по ключу
sortkey!(A::AbstractMarix, key_values) = A[:, sortperm!(key_values)]
sortkey!(A, sum(A, dim=1))

# -------------------- 4 вопрос ----------------------
#                                          СОРТИРОВКА ПОДСЧЕТОМ
# В случае, если значения элементов сортируемого массива (A), являются элементами некоторого заранее 
# известного относительно небольшого множества (values), то отсортировать такой массив можно за O(n) операций 
# следующим образом. Будем считать, что множество значений values представлено одноименным отсортированным массивом 
# или диапазоном (тут важно только, чтобы выполнялось условие values[i] < values[i+1]). 
# остается только в мвссив a поместить значение values[1] подсчитанное число раз, затем - values[2], и т.д., и, наконец, - values[end].
function calcsort!(a, values)
    num_val = zeros(Int, size(values))
    for v in a
        num_val[indexvalue(v,values)] += 1
    end
    k=1
    for i in eachindex(values)
        for j in 1:num_val[i]
            a[k] = values[i]
            k+=1
        end
    end
    return a
end


# Здесь вспомогательная функция indexvalue(v, values) возвращает индекс значения v в наборе значений values. 
# Реализация этой функции зависит от способа представления набора значений values.

indexvalue(v, values::UnionRange) = v - values[1] + 1 # если values - это диапазон целых чисел
indexvalue(v, values::Vector) = findfirst(v, values) # values - это отсортированный вектор значений

# Если массив А является целочисленным, то множество всехвозможных значений элементов этого массива содержится 
# в диапазоне minimum(A):maximum(A). Поэтому функция, реализующая сортировку целочисленного массива методом подсчета
# (что возможно, если только этот диапазон не является чрезмерно большим) может не иметь второго параметра.
function calcsort!(A::Vector{<:Integer})
    min_val, max_val = extrema(A)
    num_val = zeros(Int, max_val-min_val+1) # если не указать здесь тип Int, то в дальнейшем это привело бы к ошибке (индексы должны быть целыми)
    for val in A
        num_val[val-min_val+1] += 1
    end  
    k = 0
    for (i, num) in enumerate(num_val)
        A[k+1:k+num] = min_val+i-1
        k += num
    end
end
