function newton(z, root, ε,nmaxiter)
    n=length(root)
    for k in 1:nmaxiter
        z -= (z - 1/z^(n-1))/n
        root_index = findfirst(r->abs(r-z) <= ε, root)
        if !isnothing(root_index)
            return root_index
        end
    end
    return nothing
end