# frozen_string_literal: true

# Run on the deployment host/VM; containers use the host's kernel.
require_relative '../../lib/nginx_stage'

begin
  NginxStage::PunProcess.check_signal_support!
  puts "PUN descriptor signaling supported on #{Etc.uname[:release]} (#{RUBY_PLATFORM}); signal 0 only"
rescue NginxStage::Error, SystemCallError, IOError => e
  warn "PUN descriptor signaling unavailable: #{e.message}"
  exit 1
end
