--[[
  table_to_json

  A simple helper function to turn a lua table into a json object.
--]]
function table_to_json(lua_table)
  local result = {}

  for key, value in pairs(lua_table) do
      table.insert(result, string.format("\"%s\": \"%s\"", key, value))
  end

  return "{" .. table.concat(result, ",") .. "}"
end

--[[
  ga_body

  Google Analytics body - a simple helper function to generate json data for the GA API.
--]]
function ga_body(client_id, event_data)
  return string.format("{ \"client_id\": \"%s\", \"events\": [%s] }", client_id, event_data)
end

return {
  table_to_json = table_to_json,
  ga_body       = ga_body
}