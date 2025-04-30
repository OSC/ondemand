module EncryptedCache

  def decypted_cache_data(app: nil, data: {})
    encrypt_decript(app: app, data: data, action: :decrypt)

  # catch the error for backward compatability. i.e., what's cached is not encrypted.
  rescue ActiveSupport::MessageEncryptor::InvalidMessage
    data
  end

  def encypted_cache_data(app: nil, data: {})
    encrypt_decript(app: app, data: data, action: :encrypt)
  end

  def encrypt_decript(app: nil, data: {}, action: :encrypt)
    return {} if app.nil?

    secret_fields = app.attributes.select { |a| a.widget == 'password_field' }.map(&:id)

    if secret_fields.empty?
      data
    else
      modified_data = {}

      secret_fields.each do |field|
        raw = data[field.to_sym]
        next if raw.to_s.empty?

        modified_data[field.to_sym] = if action == :encrypt
                                        encryptor.encrypt_and_sign(raw)
                                      else
                                        encryptor.decrypt_and_verify(raw)
                                      end
      end

      data.merge(modified_data)
    end
  end

  def encryptor
    @encryptor ||= ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base[0..31])
  end
end
