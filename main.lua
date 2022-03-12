-- Prepare for execution lua modules from the subfolders of the folder this scritp is in.s
local myPath = debug.getinfo(1).source:match("@?(.*/)")
if not string.match(package.path, myPath) then
    package.path = myPath .. '?.lua;' .. package.path
end

local testSuite = require "kemi-test-suite.init"
local roles = require "roles.init"
local tools = require "tools.init"
local drivers = require "drivers.init"

function ksr_request_route()

    local result,err = roles.check.request()
    
    if not result then
        if err then
            KSR.sl.sl_send_reply(err.suggestedCode, err.suggestedReason)
        end
        return stopHandling()
    end

    if KSR.is_OPTIONS() and KSR.is_myself_ruri() and KSR.corex.has_ruri_user() < 0 then
        KSR.sl.send_reply(200,"Keepalive")
        tools.script.finish()
    end

    if KSR.is_CANCEL() then
        if KSR.tm.t_check_trans()>0 then
            roles.relay.send()
            tools.script.finish()
        end
    end

    result = roles.withindlg.request()
    
    if  result > 1 then

        if result == 2 then
            roles.relay.send()
            tools.script.finish()
        end

        if KSR.is_ACK() then
            roles.relay.send()
            tools.script.finish()
        end

        -- request with to_tag but does not belongs to any transaction and it is not an ACK
        if result == 3 then
            KSR.sl.send_reply(404,"Not found")
        end
        tools.script.finish()

    end

    KSR.hdr.remove("Route");

	if KSR.is_method_in("IS") then
		KSR.rr.record_route();
    end

    result,err = roles.dispatch.getRoute()
    if not result then
        if err then
            KSR.sl.sl_send_reply(err.suggestedCode, err.suggestedReason)
        end
    end

    roles.relay.send()

end

function ksr_reply_route()
    KSR.info("onreply route running\n")
    roles.nathandle.sip()
    roles.nathandle.sdp()

end

function ksr_branch_route_wrapper()
    roles.nathandle.sip()
    roles.nathandle.sdp()
end

function ksr_onreply_route_wrapper()
    roles.nathandle.sip()
    roles.nathandle.sdp()
end

-- function failure_route_wrapper()
-- end

function ksr_xhttp_wrapper()

    if type(roles.http_server) then
        roles.http_server.listen()
    end

end

testSuite.run()