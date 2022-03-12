local config = require ('tools.config')
local redisClient = require 'redis'

local host = "127.0.0.1"
local port = 6379

local conn

local function makeConn() 

    local redisConf = config.get("redis")
    if redisConf and type(redisConf) == "table" then
        if redisConf.host then host = redisConf.host end
        if redisConf.port then port = redisConf.port end
    end

    if conn then
        local res = conn:ping()
        if res then
            return conn
        end
    end
    
    status,conn = pcall(redisClient.connect,redisConf.host,redisConf.port)
    
    if status then
        return conn
    end

    KSR.err("Can't connect to redis server: "..conn.."\n")
    conn = nil

end

return {
    getConn = makeConn
}