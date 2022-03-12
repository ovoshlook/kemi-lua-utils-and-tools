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

local function parse(value) 
    local uname,host,port,urlParams,headerParams=string.match(value,"<sip:(.*)@([%a%d%.]+):*(%d*)([;?[%a%d-=:]*]*)>?([;?[%a%d-=:]*]*)")
    return {
        uname = uname,
        host = host,
        port = port,
        urlParams = urlParams,
        headerParams = headerParams
    }
end

return {
    get = get,
    parse = parse
}