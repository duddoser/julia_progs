function next_split!(s::AbstractVector{Integer}, k)
    k == 1 && return nothing
    i = k - 1
    while i > 1 && s[i-1] == s[i]
        i -= 1
    end
    s[i] += 1
    r = sum(@view s[i+1:k])
    k = i + r - 1
    s[i+1:n-k] .= 1
    return s, k
end