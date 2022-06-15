# Генерация всех размещений с повторениями из n элементов {1,2,...,n} по k

# Эта функция возвращает "следующий" вектор для данного вектора
# Например [1, 3, 1] -> [1, 3, 2] при n >= 3

function next_repit_plasement!(p::Vector{T}, n::T) where T<:Integer
    i = findlast(x->(x<n), p) # индекс последнего элемента меньшего n
    if isnothing(i)
        # p - это самый последний вектор в последовательности, следующего уже нет
        return nothing
    end
    p[i] += 1
    p[i+1:end] .= 1 # - устанавливаются минимально-возможные значения - единицы
    return p
end

# Тест функции и вывод всех размещений
n = 2; k = 3
p = ones(Int,k)
println(p)
while !isnothing(p)
    println(p)
    global p = next_repit_plasement!(p,n)
end