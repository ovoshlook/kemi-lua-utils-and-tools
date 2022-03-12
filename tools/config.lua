local json = require "tools.json"

local dataFieldsAllowed = { "redis" }

local config
local hash = os.time(os.date("!*t"))
local default = require("config")

local function verify(data) 
    
    if not data or string.len(data)== 0 then 
        return false, {suggestedCode = 400, suggestedReason = "No data found"}
    end

    local decoded = json.decode(data)
    
    if not decoded then
        return false, {suggestedCode = 400, suggestedReason = "Can't read data. Wrong data format"}
    end

    local validData = {}
    for i=1,#dataFieldsAllowed do 
        -- ignoring all unknown keys
        if decoded[dataFieldsAllowed[i]] then
            validData[dataFieldsAllowed[i]] = decoded[dataFieldsAllowed[i]]
        end
    end

    return validData
end

local function put(data)
    
    local res,err = verify(data)
    
    if not res then
        return false, err
    end

    -- revrite config with new one
    if not config then
        config = res
    else
        for k,v in pairs(res) do
            config[k] = v
        end
    end

    KSR.pv.sets("$sht(cache=>config)",json.encode(config))
    KSR.pv.seti("$sht(cache=>hash)",os.time(os.date("!*t")))
    
    return true
end

local function get(...)

    local h = KSR.pv.get("$sht(cache=>hash)")
    
    if h and h > 0 and h > hash then
        config = json.decode(KSR.pv.get("$sht(cache=>config)"))
    else 
        KSR.info("Can't find cached config. Getting default.\n")
        config = default
    end
    
    local base = config
    local found 
    for i=1,#arg do
        if base[arg[i]] then
            base = base[arg[i]]
            if i == #arg then
                found = true
            end
        end
    end

    -- if not found and requested not whole config return emty string
    if not found and #arg > 0 then
        KSR.err("Requested configuration does not exists\n")
        return ""
    end

    return base 
    
end

local cfg = {
    put = put,
    get = get,
}

if TEST then
    cfg.verify = verify
end

return cfg