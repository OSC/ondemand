# frozen_string_literal: true

class AppPreseter < SimpleDelegator
  attr_reader :cache_data

  def initialize(app, cache_data = {})
    super(app)
    @cache_data = cache_data.to_h
  end

  def attributes
    @attributes ||= begin
      return [] unless valid?

      raise StandardError, 'im here'

      local_attribs = form_config.fetch(:attributes, {})
      attrib_list   = form_config.fetch(:form, []).concat('cluster')

      attrib_list.map do |attribute_id|
        attribute_opts = local_attribs.fetch(attribute_id.to_sym, {})

        attributes_opts.merge!({
                                 value: cache_data[attribute_id],
                                 fixed: true
                               })

        SmartAttributes::AttributeFactory.build(attribute_id, attribute_opts)
      end
    end
  end
end
