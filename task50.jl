function next_indicator!(indicator::AbstractVector{Bool}, k)
    # в indicator - ровно k единц, остальные - нули, но это не проверяется! (фактически k - не используется)
    i=lastindex(indicator)
    while indicator[i]==0
        i-=1
    end
    #УТВ: indic[i]==1 и все справа - нули
    m=0; 
    while i >= firstindex(indicator) && indicator[i]==1 
        m+=1
        i-=1
    end
    if i < firstindex(indicator)
        return nothing
    end
    #УТВ: indicator[i]==0 и справа m>0 единиц, причем indicator[i+1]==1
    indicator[i]=1
    indicator[i+1:i+m-1] .= 0
    indicator[i+m:end] .= 1
    return indicator 
end
