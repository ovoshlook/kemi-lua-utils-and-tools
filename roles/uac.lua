-- this module made for the request generation from the kamailio
local myAddr = os.getenv ("PUBLIC_IP")

local Request = {
    BYE = "BYE",
    INVITE = "INVITE"
}

local details = {
    "callId",
    "to",
    "from",
    "ruri",
    "contact",
    "routes",
    "cSeq"
}

local bodyType = {
    sdp = "application/sdp",
    json = "application/json"
}

local function check(typ,dtls,bt,body)
    if not typ or not Request[typ] then
        KSR.err("Request "..tostring(typ).." not implemented\n")
        return false
    end
    
    if not details or typ(details) ~= "table" then
        KSR.err("Details for the request "..Request[typ].." was not passed\n")
        return false
    end 

    for k,v in pairs(details) do
        if not dtls[v] then
            KSR.err("Details for the request "..Request[typ].."does not contain requred data field: '"..v.."'\n")
            return false
        end
    end

    if not bodyType[bt] and body and string.len(body) > 0 then
        KSR.err("Unknown body type "..tostring(bt).."\n")
        return false
    end
    return true
end

local function sendRequest(typ,dtls,bt,body)

    if not check(typ,dtls,bt,body) then
        return false 
    end
    
    local packet = "BYE "..ruri.." SIP/2.0\r\n".."Via: SIP/2.0/UDP "..config.myAddr..";branch=z9hG4bK"..callId.."\r\nVia: SIP/2.0/UDP 127.0.0.1;branch=z9hG4bK-fake\r\n"..faultRouteHeader.."From: "..from.."\r\n".."To: "..to.."\r\n".."CSeq: "..cSeq.." BYE\r\n".."Call-ID: " ..callId.. "\r\nContent-length: 0\r\n\r\n"
    --KSR.corex.send_data(destination,packet)

end

return {
    sendRequest = sendRequest
}