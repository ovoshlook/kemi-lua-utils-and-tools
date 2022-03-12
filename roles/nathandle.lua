
local IPAddrTemplate = "(%d+.%d+.%d+.%d)"
local FalseIPAddrs = {
    "127.0.0.1",
    "0.0.0.0"
}

local candidateTemplates = {
    localCandidate = "a=candidate:.+%.local"
}

local function sip()
    
    KSR.force_rport()
	
	if KSR.is_REGISTER() then
        KSR.nathelper.fix_nated_register()
        return
    end
    
    if KSR.siputils.is_first_hop() > 0 then
        if KSR.siputils.is_request() > 0 then
            KSR.nathelper.handle_ruri_alias()
        end
        if KSR.hdr.is_present("Contact") > 0 then
            KSR.nathelper.add_contact_alias()
        end
        return
    end
    
end

local function sdp() 
    local body = KSR.pv.get("$rb")
    if string.len(body) == 0 then return end
    -- local newBody = handleSDP(body)
    -- KSR.textops.set_body(newBody,"application/sdp")
    KSR.rtpengine.rtpengine_manage("force replace-origin replace-session-connection")
end

return {
    sip = sip,
    sdp = sdp
}