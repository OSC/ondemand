--[[
  http200

  Returns a 200 response with a message.
--]]
function http200(r, msg)
  r.status = 200
  if msg then
    r:write("Success -- " .. msg)
  else
    r:write("Success")
  end
  return apache2.DONE  -- skip remaining handlers
end

--[[
  http404

  Returns a 404 response with a message.
--]]
function http404(r, msg)
  r.status = 404
  if msg then
    r:write("Error -- " .. msg)
  else
    r:write("Error")
  end
  return apache2.DONE  -- skip remaining handlers
end

--[[
--http302

  Returns a 302 response with a location.
--]]
function http302(r, loc)
  r.status = 302
  r.headers_out['Location'] = loc
  return apache2.DONE  -- skip remaining handlers
end

--[[
--http307

  Returns a 307 response with a location.
--]]
function http307(r, loc)
  r.status = 307
  r.headers_out['Location'] = loc
  return apache2.DONE  -- skip remaining handlers
end

return {
  http200 = http200,
  http302 = http302,
  http307 = http307,
  http404 = http404
}
