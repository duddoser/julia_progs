# Перебираем все числа до корня

function is_prime(number::T)::Bool where T <: Integer
    for i in 2:round(T, sqrt(number))
        if number % i == 0
            return false
        end
    end
    return true
end