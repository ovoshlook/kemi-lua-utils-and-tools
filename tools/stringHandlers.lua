local split = function(str, splitter)
    local value = {}
    local index = 1
    for half in string.gmatch(str, '([^' .. splitter .. ']+)') do
        value[index] = half
        index = index + 1
    end
    return value, index
end

local strToTab = function(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

local removeFromTab = function (tbl, val)
    for i, v in pairs(tbl) do
      if string.find(v,val) then
        table.remove(tbl, i)
      end
    end
    return tbl
  end


local tabToStr = function (tbl)
  result = "";
  for i in ipairs(tbl) do
        result = result..tbl[i].."\n"
  end
  return result;
end

local remove_line_by_prefix = function (body, val)
  -- get body as string, return string
  local tbl = strToTab(body,"\n")
  for i, v in pairs(tbl) do
    if string.find(v,val) then
      print('removal index:'..i..' value:'..v)
      table.remove(tbl, i)
    end
  end
  return tabToStr(tbl)
end

local function isempty(s)
  return s == nil or s == ''
end

function removeTabFromTab(tbl, val)
  for i_1,v_1 in pairs(val) do
   for i, v in pairs(tbl) do
     if string.find(v,v_1) then
       table.remove(tbl, i)
       removeTabFromTab(tbl,val)
     end
   end
  end
   return tbl
 end
 

return {
    split = split,
    strToTab = strToTab,
    removeFromTab = removeFromTab,
    tabToStr = tabToStr,
    remove_line_by_prefix = remove_line_by_prefix,
    isempty = isempty,
    removeTabFromTab = removeTabFromTab
}