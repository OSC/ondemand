module BatchConnect
  # An Interactive Application saved parameters from the form.
  class Settings
    include ActiveModel::Model

    attr_reader :token, :name, :values

    def initialize(token, name, values)
      @token = token.to_s
      @name = name.to_s
      @values = values.to_h
    end

    def app
      @app ||= BatchConnect::App.from_token token
    end

    def outdated?
      outdated = false
      # CHECK IF THERE ARE NEW ATTRIBUTES NOT IN THE VALUES HASH
      app.attributes.each do |attribute|
        outdated = true unless values.key?(attribute.id.to_sym)
      end
      # CHECK IF THERE ARE OLD VALUES NO LONGER IN THE APP ATTRIBUTES STILL IN THE VALUES HASH
      values.each_key do |attribute_id|
        outdated = true if app.attributes.select { |attribute| attribute.id.to_sym == attribute_id }.empty?
      end

      outdated
    end

  end
end
