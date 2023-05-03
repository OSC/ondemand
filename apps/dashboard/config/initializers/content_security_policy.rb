# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

if Configuration.csp_enabled?
  Rails.application.config.content_security_policy do |policy|
    policy.default_src :self
    policy.font_src    :self, :data
    policy.img_src     :self, :data
    policy.object_src  :none
    policy.script_src(*Configuration.script_sources)
    policy.style_src   :self
    policy.connect_src(*Configuration.connect_sources)

    # Specify URI for violation reports
    # policy.report_uri "/csp-violation-report-endpoint"
  end
end

# If you are using UJS then enable automatic nonce generation
Rails.application.config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }

# Set the nonce only to specific directives
Rails.application.config.content_security_policy_nonce_directives = ['script-src', 'style-src']

# Report CSP violations to a specified URI
# For further information see the following documentation:
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
if Configuration.csp_enabled?
  Rails.application.config.content_security_policy_report_only = Configuration.csp_report_only
end
