function eratosphen(n::Integer)
    is_prime = ones(Bool, n) 
    is_prime[1] = false
    for i in 2:round(Int, sqrt(n)) 
        if is_prime[i]
            for j in (i*i):i:n 
                is_prime[j] = false
            end
        end
    end
    return (1:n)[is_prime] 
end

# В качестве ответа вернем словарь, где ключи - делители, а значения - их степени

function divsAndTheirMultiple(n::Integer)
    primes = eratosphen(n)
    dividers = Dict()
    for d in primes
        if n % d == 0
            dividers[d] = 0
            while n % d == 0
                n /= d
                dividers[d] += 1 
            end
        end
    end
    return dividers
end
