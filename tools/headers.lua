local get = function(headerName)

    local headers = {}
    local i = 0
    local value = KSR.pv.get("$(hdr(" .. headerName .. ")[" .. i .. "])")
    while value do
        KSR.info(headerName .. "[" .. i .. "]: " .. value)
        table.insert(headers, value)
        i = i + 1
        value = KSR.pv.get("$(hdr(" .. headerName .. ")[" .. i .. "])")
    end
    if not next(headers) then return nil end
    return headers

end

return {
    get = get
}