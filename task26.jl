function newton(f::Function, x; e = 1e-8, max_num_iter = 20)
    num_iter = 0
    f_x = f(x)
    while num_iter < max_num_iter && abs(f_x) > e
        x += f_x
        f_x = f(x)
        num_iter += 1
    end

    if abs(f_x) <= e
        return x
    else
        return NaN
    end
end