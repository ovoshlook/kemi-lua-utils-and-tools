local function send()
    
	KSR.info("Relaying\n")
	if KSR.is_method_in("IBSU") then
		if KSR.tm.t_is_set("branch_route")<0 then
			KSR.tm.t_on_branch("ksr_branch_route_wrapper")
		end
	end
    
	if KSR.is_method_in("ISU") then
		if KSR.tm.t_is_set("onreply_route")<0 then
			KSR.tm.t_on_reply("ksr_onreply_route_wrapper")
        	end
	end

	if KSR.is_INVITE() then
		if KSR.tm.t_is_set("failure_route")<0 then
			KSR.tm.t_on_failure("ksr_failure_route_wrapper")
		end
	end

    	KSR.info("Send to "..tostring(KSR.pv.get("$du")).." via socket "..tostring(KSR.pv.get("$fs")).."\r\n")
	if KSR.tm.t_relay() < 0 then
		KSR.sl.sl_reply_error()
		return false
	end

    	return true
end

return {
    send = send
}