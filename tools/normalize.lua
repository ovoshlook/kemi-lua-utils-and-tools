-- remove all parameters from the username part
local function sipUri(uri) 
    if not uri or string.len(uri) == 0 then
        return 
    end
        
    uri = string.gsub(uri,";.*@","@")
    return uri
end

return {
    sipUri=sipUri
}