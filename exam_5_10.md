# Лекция 1
# Билет 5. Быстрый поиск в массиве
НЕ знаю какой конкретно алгоритм быстрого поиска хочет вибоф, но в лекции он рассказывал про бинарный поиск, поэтому я реализую его

```julia
function binary_search(arr::AbstractArray{T,1}, l::T, r::T, x::T) where {T<:Real}
    if (r >= l)
        mid = Int(ceil(l + (r - l) / 2))
        # println(mid)
        if (arr[mid] == x)
            return "Element present at index $mid"
        elseif (arr[mid] > x)
            binary_search(arr, l, mid - 1, x)
        else
            binary_search(arr, mid + 1, r, x)
        end
    else
        return "Element not present in array"
    end
end
```

# Билет 6. 
Вычисление значения многочлена и его производной в точке по схеме Горнера

```julia
function polyval(P, x)
    dQ = 0
    Q = P[1]
    for i in 2:length(P)
        dQ = dQ*x + Q
        Q = Q*x + P[i]
    end
    return Q, dQ
end
```

# Билет 7
Сортировка вставками

```julia
function swap!(array, i, j)
    temp = array[i]
    array[i] = array[j]
    array[j] = temp
end


function insertionSort!(array::AbstractVector)
    for i in 2:length(array)
        for j in i-1:-1:1
            if array[i] < array[j]
                swap!(array, i, j)
            end
        end
    end
end
```

# Билет 8
Циклический сдвиг на k позиций влево и вправо

Пусть, например, k > 0, тогда требуемый результат будет получен, если в массиве сначала перевернуть задом на перед каждую из двух его частей: с 1-го по k-ый элемент, и с k+1-го по последний элемент, а затем перевернуть уже весь массив целиком еще раз.

```julia
function _circshift!(a, k)
    k = length(a) % k
    if k > 0
        reverse!(@view(a[begin:k]))
        reverse!(@view(a[k+1:end]))
        reverse!(a) 
    elseif k < 0
        reverse!(a)
        reverse!(@view(a[begin:-k]))
        reverse!(@view(a[-k+1:end]))
    end
    return a
end
```

# Билет 9
Перестановки индексов, проверка, является ли вектор перестрановкой индексов (ispermute), обратная перестановка элементов массива (invpermute)

Для реализации функции isperm (проверяющую, представляет ли заданный вектор целых чисел некотрую перестановку чисел 1,2,...,N, или нет) достаточно проверить, во-первых, что, все его элементы принадлежат диапазону 1:N (N - длина заданного вектора), и, во-вторых, что все содержащиеся в нем числа различны.
```julia
function _isperm(p)
    n = length(p)
    used = falses(n) # возвращает нулевой BitVector длины n
    for i in p
        (i in 1:n) && (used[i] ⊻= true) || return false # значек ⊻ - обозначает "исключающее или" 
    end
    true
end
```

Функция invpermute!, выполняющая обратную перестановку, реализуется проще чем, функция permute!, выполняющая заданную перестановку индексов p, которая соответствовала бы срезу массива A[p].
```julia
function _invpermute!(A, p)
    for i in p
        if i > 0
            A[i], A[p[i]] = A[p[i]], A[i]
            p[i] = -p[i]
        end
    end
    for i in eachindex(p)
        p[i] = -p[i]
    end
    return A   
end
```

# Билет 10
Прямая перестановка элементов массива (permute)

При реализации функции permute! воспользоваться тем фактом, что любая перестановка индексов представляет собой совокупность циклических перестановок некоторого числа непересекающихся наборов индексов.
```julia
function _permute!(A, p) 
    for i in eachindex(p)
        if p[i] < 0
            continue
        end 
        # i - начало очередной циклической перестановки индексов массива A            
        buff = A[i]
        j_prew, j = i, p[i] # - индекс элемента исходного массива, который требуется переместить на i-ю позицию                  
        p[i] = -p[i]
        while j != i # - пока циклическая перестановка индексов не "замкнулась"               
            A[j_prew] = A[j]
            j_prew, j = j, p[j]            
            p[j_prew] = -p[j_prew]
        end        
        A[j_prew] = buff 
        # перемещения элементов массива A по очередному циклу (по очередной циклической перестановке индексов) полностью завершены
    end
    for i in eachindex(p)
        p[i] = -p[i]
    end        
    return A
end
```

Возможна также следующая реализация функции permute! Однако эта реализация потребовала создания вспомогательного массива, для размещения обратной перестановки индексов inv_p.
```julia
function __permute!(A, p) 
    inv_p = similar(p)
    inv_p[p] .= 1:length(p) 
    _invpermute!(A, inv_p)
end
```
