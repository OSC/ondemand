json.default_trs do
  json.merge! @default_locale_translations
end

json.curr_trs do
  json.merge! @current_locale_translations
end
