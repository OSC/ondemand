# frozen_string_literal: true

# Sanitize an environment by returning a new Hash that can
# be used with ClimateControl to submit jobs with that new
# environment.
module SanitizedEnv
  PREFIXES = [
    'SECRET', 'PASSENGER', 'BUNDLE',
    'RACK', 'HTTP', 'NODE', 'RAILS', 'RUBY',
    'GEM', 'NGINX'
  ].freeze

  def sanitized_env
    # these are all one offs that we should clear so they don't conflict
    # with the job.
    {
      'LD_LIBRARY_PATH'  => nil,
      'MANPATH'          => nil,
      'PYTHONUNBUFFERED' => nil,
      'X_SCLS'           => nil,
      'WSGI_ENV'         => nil,
      'ALLOWED_HOSTS'    => nil,
      'IN_PASSENGER'     => nil,
      'SERVER_SOFTWARE'  => nil,
      'PKG_CONFIG_PATH'  => nil
    }.merge(sanitize_env(Regexp.new(PREFIXES.join('|'))))
  end

  def sanitize_env(prefix)
    ENV.select do |key, _value|
      key.start_with?(prefix)
    end.map do |key, _value|
      [key, nil]
    end.to_h
  end
end
