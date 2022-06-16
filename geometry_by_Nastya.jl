using LinearAlgebra
using Plots
Vector2D{T<:Real} = NamedTuple{(:x, :y), Tuple{T,T}} # Точка (вектор)

Segment2D{T<:Real} = NamedTuple{(:A, :B), Tuple{Vector2D{T},Vector2D{T}}} # Отрезок

"""Абстрактный тип многоугольника"""
abstract type AbstractPolygon{T<:Real} end

"""
Polygon{T} <: AbstractPolygon{T}
- обычный (неопределенный) многоугольник
"""
struct Polygon{T} <: AbstractPolygon{T} 
    vertices::Vector{Vector2D{T}}
end

"""
ConvexPolygon{T} <: AbstractPolygon{T}
- выпуклый многоугольник
"""
struct ConvexPolygon{T} <: AbstractPolygon{T}
    vertices::Vector{Vector2D{T}}
end

"""
number_of_vertices(polygon::AbstractPolygon)

Возвращает кол-во вершин в многоугольнике.
- дублирование начальной вершины отслеживается
"""
number_of_vertices(polygon::AbstractPolygon) = polygon.vertices[begin] != polygon.vertices[end] ? length(polygon.vertices) : length(polygon.vertices)-1  


"""Модуль вектора"""
LinearAlgebra.norm(A::Vector2D) = norm(Tuple(A))

"""Проверка принадлежности точки к отрезку"""
isinner(P::Vector2D, s::Segment2D) = (s.A.x <= P.x <= s.B.x || s.A.x >= P.x >= s.B.x) && 
                                     (s.A.y <= P.y <= s.B.y || s.A.y >= P.y >= s.B.y)


"""
Поиск точки пересечения отрезков
- !!!! Если матрица A - вырожденная, то произойдет ошибка времени выполнения
"""
function intersect(s1::Segment2D{T},s2::Segment2D{T}) where T
    A = [s1.B[2]-s1.A[2]  s1.A[1]-s1.B[1]
         s2.B[2]-s2.A[2]  s2.A[1]-s2.B[1]]

    b = [s1.A[2]*(s1.A[1]-s1.B[1]) + s1.A[1]*(s1.B[2]-s1.A[2])
         s2.A[2]*(s2.A[1]-s2.B[1]) + s2.A[1]*(s2.B[2]-s2.A[2])]

    x,y = A\b

    if isinner((;x, y), s1)==false || isinner((;x, y), s2)==false
        return false
    end

    return (;x, y)
end

# Стандартные бинарные операции для двух векторов
Base. +(a::Vector2D{T},b::Vector2D{T}) where T = Vector2D{T}(Tuple(a) .+ Tuple(b))
Base. -(a::Vector2D{T}, b::Vector2D{T}) where T = Vector2D{T}(Tuple(a) .- Tuple(b))
Base. *(α::T, a::Vector2D{T}) where T = Vector2D{T}(α .* Tuple(a))

"""Скалярное произв-ие веторов"""
LinearAlgebra.dot(A::Vector2D{T}, B::Vector2D{T}) where T = dot(Tuple(A), Tuple(B))

"""косое произв-ие векторов"""
xdot(A::Vector2D{T}, B::Vector2D{T}) where T = A.x*B.y-A.y*B.x

"""Косинус угла между двумя векторами"""
cos_angle(A::Vector2D{T}, B::Vector2D{T}) where T = dot(A, B) / (norm(A) * norm(B))

"""Синус угла между векторами"""
sin_angle(A::Vector2D{T}, B::Vector2D{T}) where T = xdot(A, B) / (norm(A) * norm(B))

"""Преобразование отрезка в вектор"""
segment_to_vector(s::Segment2D{T}) where T = Vector2D{T}((s.B.x-s.A.x), (s.B.y-s.A.y))

"""Угол между прямыми по направ-им веторам"""
angle(q1::Vector2D{T}, q2::Vector2D{T}) where T = atan(sin_angle(q1, q2), cos_angle(q1, q2))

"""Знак синуса между веторами"""
Base.sign(a::Vector2D{T}, b::Vector2D{T}) where T = sign(sin_angle(a,b))



"""Лежат ли заданные точки по одну сторону от заданной неявной функцией границы области"""
is_on_other_side(F::Function, A::Vector2D{T}, B::Vector2D{T}) where T = ((F(A.x, A.y)*F(B.x, B.y)) < 0)


"""
isinner(A::Vector2D{T}, polygon::AbstractPolygon{T})

Проверка принадлежности точки внутренности многоугольника (не обязательно выпуклого)
- A - точка
- polygon - многоугольник
"""
function isinner(A::Vector2D{T}, polygon::AbstractPolygon{T})::Bool where T
    flag = double_ended!(polygon)
    sum_angles = 0.0

    for i in firstindex(polygon.vertices):lastindex(polygon.vertices)-1
        sum_angles += angle(polygon[i+1]-A, polygon[i]-A)
    end

    if flag == true
        single_ended!(polygon)
    end

    if sum_angles < pi # фактически равно 0
        return true # точка внутри многоугольника
    else
        return false # точка снаружи
    end
end


"""
isinner(A::Vector2D{T}, polygon::ConvexPolygon{T})

Проверка принадлежности точки внутренности ВЫПУКЛОГО многоугольника.
"""
function isinner(A::Vector2D{T}, polygon::ConvexPolygon{T})::Bool where T
    flag = double_ended!(polygon)
    sign_prev = sign(polygon[begin+1]-A, polygon[begin]-A)
    for i in firstindex(polygon.vertices)+1:lastindex(polygon.vertices)-1
        sign_cur += sign(polygon[i+1]-A, polygon[i]-A)
        if sign_prev * sign_cur < 0
            return false
        end 
    end

    if flag == true
        single_ended!(polygon)
    end

    return true
end


"""
isconvex(plygon::AbstractPolygon)

Является ли заданный многоугольник выпуклым
"""
function is_convex(polygon::AbstractPolygon)
    prev_v = polygon.vertices[2]
    prev_v.x -= polygon.vertices[1].x
    prev_v.y -= polygon.vertices[1].y
    status = 0

    l = length(polygon.vertices)
    for i in 3:l
        cur_v = polygon.vertices[i % l]
        cur_v.x -= polygon.vertices[i-1].x
        cur_v.y -= polygon.vertices[i-1].y

        s = sin_angle(prev_v, cur_v)
        if s*status < 0
            return false
        end

        prev_v = cur_v
        status = s
    end

    cur_v = polygon.vertices[1]
    cur_v.x -= polygon.vertices[l].x
    cur_v.y -= polygon.vertices[l].y
    
    s = sin_angle(prev_v, cur_v)
    if s*status < 0
        return false
    end


    return true
end

"""
double_ended!(polygon::AbstractPolygon)

Дублирует в конце вектора его первый элемент, если изначально этого дублирования не было.
- true == входной вектор изменён
- false == входной вектор не изменён 
"""
function double_ended!(polygon::AbstractPolygon)::Bool
    if polygon[begin] != polygon[end]
        push!(polygon, polygon[begin])
        return true
    end
    return false
end

"""
single_ended!(polygon::AbstractPolygon)::Bool

Удаляет из конца вектора элемент, дублирующий первый, если такой лемент был.
- true == входной вектор изменён
- false == входной вектор не изменён 
"""
function single_ended!(polygon::AbstractPolygon)::Bool
    if polygon[begin] == polygon[end]
        pop!(polygon)
        return true
    end
    return false
end


"""
jarvis(points::Vector{Vector2D{T}})

Алгоритм Джарвиса построения выпуклой оболочки заданных точек плоскости
- points - набор точек
"""
function jarvis(points::Vector{Vector2D{T}})::ConvexPolygon{T} where T<:Real
    @assert length(points) > 1 # иначе операция в строке 9 будет не возможна
    
    yyy = [points[i][2] for i in 1:length(points)]
    _, i_start = findmin(yyy) # индекс самой нижней точки
    convex_shell = [i_start]
    ort_base = Vector2D{Int}((1,0)) # - этот вектор задает начальное базовое направление (горизонтално вправо)
    print(typeof(ort_base))
    while next!(convex_shell, points, ort_base) != i_start
        ort_base = convex_shell[end] - convex_shell[end-1]  # - не нулевой вектор, задающий очередное базовое направление
    end
    
    return convex_shell # В конце и в начале массива convex_shell дважды содержится значение i_start 
end

"""
next!(convex_shell::Vector{Int64}, points::Vector{Vector2D{T}}, ort_base::Vector2D{T})

Ищет следующую точку по удаленности
- convex_shell - нумерация точек (оболочка)
- points - набор точек
- ort_base - вектор, от которого мы "отталкиваемся"
"""
function next!(convex_shell::Vector{Int64}, points::Vector{Vector2D{T}}, ort_base::Vector2D{T}) where T<:Real
    cos_max = typemin(T)
    i_base = convex_shell[end]
    resize!(convex_shell, length(convex_shell)+1)
    
    for i in eachindex(points)
        if points[i] == points[i_base]
            continue
        end
    
        ort_i = points[i] - points[i_base] # - не нулевой вектор, задающий направление на очередную точку
        cos_i = cos_angle(ort_base, ort_i)
    
        if cos_i > cos_max
            cos_max = cos_i
            convex_shell[end] = i 
        elseif cos_i == cos_max && quad_len(ort_i) > quad_len(ort_base) # на луче, содержащем сторону выпуклого многоугольника, может оказаться более двух точек заданного множества (надо выбрать самую дальнюю из них)
            convex_shell[end] = i
        end
    end
    
    return convex_shell[end]
end

"""Квадрат модуля вектора (скалярное произведение на самого себя)"""
quad_len(vec) = dot(vec, vec)

#-------------------------------------

"""
grekhom!(points::Vector{Vector2D{T}})

Алгоритм Грехома построения выпуклой оболочки заданных точек плоскости
- points - набор точек плоскости
"""
function grekhom!(points::Vector{Vector2D{T}})::ConvexPolygon{T} where T<:Real
        ydata = (points[i][2] for i in 1:length(points))
        i_start = findmin(ydata) # индекс самой нижней точки
        points[begin], points[i_start] = points[i_start], points[begin]

        sort!(@view(points[begin+1:end]), by = (point -> angle(point, Vector2D{T}((1,0)))))
        push!(points, points[begin]) # теперь points[end] == points[begin] 
        convex_polygon = [firstindex(points), firstindex(points)+1, firstindex(points)+2] # - в стек помещены первые 3 точки
        
        for i in firstindex(points)+3:lastindex(points)
            while sign(points[i]-points[convex_polygon[end]], points[convex_polygon[end-1]]-points[convex_polygon[end]]) < 0
                pop!(convex_polygon)
            end
            push!(convex_polygon, i)
        end
    
        return ConvexPolygon{T}(points[convex_polygon])  # convex_polygon[begin] == convex_polygon[end]
    end
    

#-------------------------------------

"""
oriented_S_1(polygon::AbstractPolygon)

Считает значение ориентированной площади заданного плоского многоугольника, воспользовавшись методом трапеций
- polygon - многоугольник
"""
function oriented_S_1(polygon::AbstractPolygon)
    S = 0
    for k in firstindex(polygon.vertices):(lastindex(polygon.vertices)-1)
        S += (polygon.vertices[k][2] + polygon.vertices[k+1][2])*(polygon.vertices[k+1][1] - polygon.vertices[k][1]) / 2
    end

    return S
end

"""
oriented_S_2(polygon::AbstractPolygon)

Считает значение ориентированной площади заданного плоского многоугольника, воспользовавшись методом треугольников
- polygon - многоугольник
"""
function oriented_S_2(polygon::AbstractPolygon)
    S = 0
    p0 = polygon.vertices[1]
    for k in (firstindex(polygon.vertices)+1):(lastindex(polygon.vertices)-1)
        S += xdot(polygon.vertices[k]-p0, polygon.vertices[k+1]-p0) / 2
    end

    return S
end


"""
increase!(polygon::ConvexPolygon, A::Vector2D)

Достраивает данный выпуклый многоугольник, добавляя в его оболочку данную точку и убирая лишние
- polygon - выпуклый многоугольник
- A - точка, которую нужно пристроить
"""
function increase!(polygon::ConvexPolygon{T}, A::Vector2D{T}) where T<:Real
    imi = -1
    ima = -1
    mi = 10000
    ma = -10000

    for i in firstindex(polygon.vertices):lastindex(polygon.vertices)
        ang = angle(polygon.vertices[i] - A, Vector2D{T}((0,1)))
        if ang < mi
            mi = ang
            imi = i
        end
        if ang > ma
            ma = ang
            ima = i
        end 
    end

    if imi > ima
        imi, ima = ima, imi
    end
    for i in (imi+1):(ima-1)
        deleteat!(polygon.vertices, i)
    end
    insert!(polygon.vertices, i2, A)

    return polygon
end


"""
third_algo(points::Vector{Vector2D{T}})

Алгоритм построения МВО с помощью добавления точек по одной
- Points - набор точек, на которых будет строится МВО
"""
function third_algo(points::Vector{Vector2D{T}})::ConvexPolygon{T} where T<:Real
    ps = points[1:2]
    
    k = 3
    while angle(ps[2]-ps[1], points[k]-ps[1]) == 0
        k += 1
    end
    push!(ps, points[k])
    polygon = ConvexPolygon{T}(ps)

    for i in @view(points[k+1:end])
        if !isinner(i, polygon)
            increase!(ps, i)
        end
    end

    return polygon
end


"""
increase_wth_S!(polygon::ConvexPolygon{T}, A::Vector2D{T}, S<:Real)

Достраивает данный выпуклый многоугольник, добавляя в его оболочку данную точку и убирая лишние
- polygon - выпуклый многоугольник
- A - точка, которую нужно пристроить
- S - изначальная площадь многоугольника
"""
function increase_wth_S!(polygon::ConvexPolygon{T}, A::Vector2D{T}, S::Real) where T<:Real
    imi = -1
    ima = -1
    mi = 10000
    ma = -10000

    for i in firstindex(polygon.vertices):lastindex(polygon.vertices)
        ang = angle(polygon.vertices[i] - A, Vector2D{T}((0,1)))
        if ang < mi
            mi = ang
            imi = i
        end
        if ang > ma
            ma = ang
            ima = i
        end 
    end

    if imi > ima
        imi, ima = ima, imi
    end

    if ima - imi > 1
        S -= abs(oriented_S_2(Polygon(@view(polygon.vertices[imi:ima]))))
        
        for i in (imi+1):(ima-1)
            deleteat!(polygon.vertices, i)
        end
    end

    S += xdot(polygon.vertices[imi]-A, polygon.vertices[ima]-A)
    insert!(polygon.vertices, i2, A)

    return polygon, S
end

Plots.plot!(polygon::AbstractPolygon; kwargs...) = plot!(current(), polygon.vertices; kwargs...)
Plots.plot!(p::Plots.Plot, polygon::AbstractPolygon; kwargs...) = plot!(p, polygon.vertices; kwargs...)
Plots.plot(polygon::AbstractPolygon; kwargs...) = plot(polygon.vertices; kwargs...)


#-------------------12 практическое задание---------------------
"""
Является ли заданная последовательность точек вершинами некоторого многоугольника
"""
function is_poly(points::Vector{Vector2D{T}}) where {T}
    for i in 1:length(points)-1
        f = Segment2D{T}(points[i], points[i+1])
        for j in 1:i-1
            s = Segment2D{T}(points[j], points[j+1])
            if !isnothing(intersect(f, s))
                return false
            end
        end
    end
    return true
end
