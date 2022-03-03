local serviceiana = require "service.iana"


local uri = {}


function uri.new(url)
  local scheme = url:match("([A-Za-z0-9]+)://")
  if scheme then
    url = url:sub(#scheme+4, #url)
  end

  local userinfo = url:match("([^@]+)@")
  if userinfo then
    url = url:sub(#userinfo+2, #url)
  else
    userinfo = ""
  end

  local host = url:match("([a-zA-Z0-9\\.\\-\\_]+)")
  if host then
    url = url:sub(#host+1, #url)
  end

  if not scheme or not host then
    return nil, "uri: the URL passed is invalid"
  end

  local port = url:match(":([0-9]+)")
  if port then
    url = url:sub(#port+2, #url)
  else
    port = serviceiana.byname(scheme).port or ""
  end

  local authority = ("%s%s%s"):format((userinfo ~= "" and userinfo.."@") or "", host, (port ~= "" and ":"..tostring(port)) or "")

  local path = "/"..(url:match("/([^?]+)") or "")
  if path then
    url = url:sub(#path+1, #url)
  else
    path = ""
  end

  local query = url:match("?([^#]+)") or url:match("?(.*)")
  if query then
    url = url:sub(#query+1, #url)
  else
    query = ""
  end

  local fragment = url:match("#(.*)")
  if not fragment then
    fragment = ""
  end

  local pathquery = ""
  if #query > 0 then
    pathquery = ("%s?%s"):format(path, query)
  else
    pathquery = path
  end

  local fullpath = ""
  if #query > 0 and #fragment > 0 then
    fullpath = ("%s?%s#%s"):format(path, query, fragment)
  elseif #query > 0 then
    fullpath = ("%s?%s"):format(path, query)
  else
    fullpath = path
  end

  return {
    scheme    = scheme,
    userinfo  = userinfo,
    host      = host,
    port      = port,
    authority = authority,
    path      = path,
    query     = query,
    fragment  = fragment,
    pathquery = pathquery,
    fullpath  = fullpath,
  }
end


return uri
