# Это вибофская функция и она выводит все подмножества, но не в лексикографичсеком порядке

function next_indicator!(indicator::AbstractVector{Bool})
    i = findlast(x->(x==0), indicator)
    isnothing(i) && return nothing
    indicator[i] = 1
    indicator[i+1:end] .= 0
    return indicator 
end

n=3; A=1:n
ind = zeros(Bool, n)
while !isnothing(ind)
    global ind
    A[findall(ind)] |> println
    ind = next_indicator!(ind)
end

# 
# Это мой вариант кода и он работаетт точно также, но мне кажется реализация понятнее
# 
function next_repit_plasement!(p::Vector{T}, n::T) where T<:Integer
    i = findlast(x->(x<n-1), p)
    if isnothing(i)
        return nothing
    end
    p[i] += 1
    p[i+1:end] .= 0
    return p
end

n = 3
arr = 1:3
p = zeros(Int,n)
while !isnothing(p)
    indexes = []
    for i in 1:n
        if p[i] == 1
            push!(indexes, i)
        end
    end
    println(arr[indexes])
    global p = next_repit_plasement!(p,2)
end