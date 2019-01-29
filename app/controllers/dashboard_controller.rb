class DashboardController < ApplicationController
  def index
    @motd = MotdFile.new.formatter
    set_my_quotas
  end

  def logout
  end
  
  def translations
    trs = I18n.backend.send(:translations)
    @current_locale = I18n.locale
    @default_locale = I18n.default_locale
    @current_locale_translations = trs[@current_locale]
    @default_locale_translations = trs[@default_locale]
    @i18n_load_paths = I18n.load_path
    def flatten_translations(translations, key = [])
      new_hash = {}
      if translations.respond_to?(:each_pair)
        translations.each_pair { |k,v|
          new_hash.merge!(flatten_translations(v, key + [k]))
        }
      elsif translations.respond_to?(:each_index)
        translations.each_with_index { |v,i|
          new_hash.merge!(flatten_translations(v, key + [i]))
        }
      else
        new_hash.merge!({key => translations})
      end
      new_hash
    end
    @flat_current_locale_translations = flatten_translations(@current_locale_translations)
    @flat_default_locale_translations = flatten_translations(@default_locale_translations)
    @flat_all_locale_keys = flatten_translations(@current_locale_translations.merge(@default_locale_translations))
  end
end

class Hash
  def sort_recursive()
    sorted = self.sort
    sorted = sorted.map{|a|
      a[1] = a[1].sort_recursive if a[1].respond_to?(:sort_recursive)
      [a[0], a[1]]
    }
  end
end
