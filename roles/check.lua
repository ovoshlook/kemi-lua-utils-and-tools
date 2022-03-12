--request returns true,nill in case of all checks passed or false, err = {  code, reason }
local function request()
    
    -- Used old notation instead KSR.kx.get_ua() for those scenarions when kamailio kx doesn't support it as it was introduced in 5.4
    -- However plz check and update your kamailio version if you are using KEMIX module approach
    local ua = KSR.pv.get("$ua");

    if KSR.siputils.has_totag() < 0 then
        if not ua or  ( ua and string.find(ua, "friendly-scanner") or string.find(ua, "sipcli")) then
            return false
        end
    end

    if KSR.maxfwd.process_maxfwd(10) < 0 then
        return false, {  code = 483, reason = "Too Many Hops" }
	end

	if KSR.sanity.sanity_check(1511, 7)<0 then
        KSR.err("Malformed SIP message from ".. KSR.kx.get_srcip() .. ":" .. KSR.kx.get_srcport() .."\n");
        return false
    end

    return true
    
end

return {
    request = request
}