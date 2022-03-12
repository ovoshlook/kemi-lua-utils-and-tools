local tools = require "tools.init"

local function validateCallback(cb)
    if not cb then
        KSR.warn("Callback was not set\n")
        return false
    end
    if type(cb) ~= "table" then
        KSR.err("Callback passed to http_client in incorrect format: expected table\n")
        return false
    end
    if not cb.module or not cb.method then
        KSR.err("Callback passed to http_client in incorrect format: expected { module=\"module.path\", method=\"name\", params = {...} }\n")
        return false
    end
    return true
end

--callback param has to be passed as { module="module.path", method="name"}
local function request(method,url,data,callback)
    --if KSR.tm.t_check_trans() < 0 or KSR.tmx.t_is_branch_route() < 0 then KSR.tm.t_newtran() end
    KSR.tm.t_newtran()
    KSR.pv.sets("$http_req(hdr)", "Content-Type: application/json")
    KSR.pv.sets("$http_req(body)",data)
    KSR.pv.seti("$http_req(timeout)",10000)
    KSR.http_async_client.query(url,"ksr_http_client_callback")
    local httpid = KSR.pv.get("$http_req_id")
    KSR.info("http async request id: "..httpid.."\n")
    
    if validateCallback(callback) then
        KSR.pv.sets("$sht(httpid=>"..httpid..")",tools.json.encode(callback))
    end
    return true

end


local function addReason(code)
    local reason = codesMap[code]
end

local function reply()
    
    local res = KSR.pv.get("$http_ok")
   
    local reply = {}
   
    if res == 1 then
        
        reply.status = tonumber(KSR.pv.get("$http_rs"))
        reply.reason = KSR.pv.get("$http_rr")

        KSR.info("HTTP CLIENT reply: status: "..reply.status.."\n")
        KSR.info("HTTP CLIENT reply: reason: "..reply.reason.."\n")

        local body = KSR.pv.get("$http_rb")
    
        if body and body ~= "null" then
            reply.body = body  
        end

    else
        
        reply.error = KSR.pv.get("$http_err")
        KSR.info("HTTP CLIENT reply error: "..reply.error.."\n")
        if not reply.status and reply.error == "TIMEOUT" then
            reply.status = 408
        end
    
    end

    if not reply.status or not reply.reason then
        reply = {
            status = 503,
            reason = "Internal error occured, try later"
        }
    elseif reply.status > 499 then
        reply = {
            status = 503,
            reason = "Internal error occured, try later"
        }
    end
   
    local httpid = KSR.pv.get("$http_req_id")
    local callback = KSR.pv.get("$sht(httpid=>"..httpid..")")
        
    if not callback then
        KSR.info("HTTP async reply to request id: "..httpid.." with no callback binding\n")
        tools.script.finish()
    end
    
    local cb = tools.json.decode(callback)
    
    if not cb then 
        KSR.err("Can't use callback\n")
        tools.script.finish()
    end 
    if cb.params and type(cb.params) == "table" then
        package.loaded[cb.module][cb.method](reply,unpack(params))
    else 
        package.loaded[cb.module][cb.method](reply)
    end

end

return {
    request = request,
    reply = reply
}
