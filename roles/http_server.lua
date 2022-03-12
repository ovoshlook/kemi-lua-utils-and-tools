local config = require "config"


local function listen()
    KSR.info("HTTP Received\n");
    local url = KSR.pv.get("$hu")

    if not config.ACLAPI[KSR.kx.get_srcip()] then
        KSR.x.exit()
    end

    if url == "/dispatcher/reload" then
        KSR.info("Reloading dispathcer\n")
        KSR.dispatcher.ds_reload()
        KSR.xhttp.xhttp_reply("200", "Ok", "", "")
    end


end

local http = {
    listen = listen
}

return http