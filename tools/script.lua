-- just some wrappers under KSR functions to make it more independed from specific cases

local function finish()
    if not TEST then
        KSR.info("Script execution done\n")
        KSR.x.exit()
    end
    return false
end

return {
    finish = finish
}