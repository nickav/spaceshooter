-- extend table to support finding elements
function table.find(tab,el)
    for index, value in pairs(tab) do
        if value == el then
            return index
        end
    end
end

-- http://lua-users.org/wiki/OptimisationCodingTips
function fast_assert(condition, ...)
    if not condition then
        if getn(arg) > 0 then
            assert(condition, call(format, arg))
        else
            assert(condition)
        end
    end
end