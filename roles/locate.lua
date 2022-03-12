-- User location service
local function user(storage,username)

    KSR.log("info","Locating user "..username.."\n")
	local rc = KSR.registrar.lookup(storage);
    
    if rc < 0 then
        KSR.log("info","Unable to locate "..username.."\n")
        return false
    end

    return true
end


return {
    user = user
} 
