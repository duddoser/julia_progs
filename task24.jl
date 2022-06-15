function eratosphen(n::Integer)

    # Создаем булевый массив длины n - простое число или нет
    is_prime = ones(Bool, n) 
    is_prime[1] = false # 1 — не является простым числом

    for i in 2:round(Int, sqrt(n)) # Идем до корня, т.к. после корня все непростые числа уже помечены
        if is_prime[i] # Когда находим простое число i, идем в цикле от квадрата этого числа до n с шагом i
            for j in (i*i):i:n 
                is_prime[j] = false
            end
        end
    end
    return (1:n)[is_prime] # Возвращает от диапазона от 1 до n те числа, по индексам которых
                           # в массиве is_prime стоит true - применяем фильтрЫ
end