local RFC1918 = {
    "10%.%d+%.%d+%.%d+",
    "192%.168%.%d+%.%d+",
    "172%.16%.%d+%.%d+",
    "127%.%d+%.%d+%.%d+",
}

local IPv4 = 0
local IPv6 = 1

function getIPFromAddr(addr)
    local result = string.match(addr,":?(%d+%.%d+%.%d+%.%d+):?") 
    if result then
        return result
    end

    local first = string.sub(addr,1,1)
    -- [AD:RR:E:SS] | sip:[AD:RR:E:SS] | sip:[AD:RR:E:SS]:PORT | sips:[AD:RR:E:SS]:PORT | tel:[AD:RR:E:SS]:PORT | <sip:[AD:RR:E:SS]:PORT
    if first == "[" or string.match(first,"[<st]") then
        return string.match(addr,"%[([a-fA-F0-9:]*)%]:?")
    end
        
    return addr
    
end

function getPortFromAddr(addr)
    return string.match(addr..";",":(%d+);") or 5060
end

function getProtoFromAddr(addr)
    return string.match(addr,"transport=([utdcplsw]+)") or "udp"
end

function getIPType(ip)
    local R = {ERROR = -1, STRING = -2, IPV4 = IPv4, IPV6 = IPv6 }
    if type(ip) ~= "string" then return R.ERROR end
    -- check for format 1.11.111.111 for ipv4
    local chunks = {ip:match("^(%d+)%.(%d+)%.(%d+)%.(%d+)$")}
    if #chunks == 4 then
        for _,v in pairs(chunks) do
            if tonumber(v) > 255 then return R.STRING end
        end
        return R.IPV4
    end
  
    -- check for ipv6 format, should be 8 'chunks' of numbers/letters
    -- without leading/trailing chars
    -- or fewer than 8 chunks, but with only one `::` group
    local chunks = {ip:match("^"..(("([a-fA-F0-9]*):"):rep(8):gsub(":$","$")))}
    if #chunks == 8 or #chunks < 8 and ip:match('::') and not ip:gsub("::","",1):match('::') then
      for _,v in pairs(chunks) do
        if #v > 0 and tonumber(v, 16) > 65535 then return R.STRING end
      end
      return R.IPV6
    end
  
    return R.STRING
  end

local function isPrivate(ip)

    for i=1,#RFC1918,1 do
        if string.match(ip,RFC1918[i]) then
            return true
        end
    end
    return false
   
end

return {
    IPv4 = IPv4,
    IPv6 = IPv6,
    getIPType = getIPType,
    isPrivate = isPrivate,
    getIPFromAddr = getIPFromAddr,
    getPortFromAddr = getPortFromAddr,
    getProtoFromAddr = getProtoFromAddr,

}