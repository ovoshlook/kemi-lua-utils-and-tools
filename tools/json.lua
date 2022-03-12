local json = require "tools.json"

local function encode(data) 
    local encoded = json.encode(data)

    if not encoded then
        KSR.err("Can't encode data to json\n")
        return false
    end

    local normalized = string.gsub(encoded,"\\","")

    if not normalized then
        KSR.err("Can't normalise data to json\n")
        return false
    end

    return encoded
end

local function decode(data) 
    local decoded = json.decode(data)
    if not decoded then
        KSR.err("Can't decode data from json\n")
        return false
    end
    return decoded
end

return {
    encode = encode,
    decode = decode
}