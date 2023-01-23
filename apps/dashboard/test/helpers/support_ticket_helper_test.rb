# frozen_string_literal: true

require 'test_helper'

class SupportTicketHelperTest < ActionView::TestCase
  include SupportTicketHelper

  test 'support_ticket_description_text should read content from support_ticket configuration' do
    expected_description = 'This is description text'
    Configuration.stubs(:support_ticket_config).returns({ description: expected_description })
    ::Configuration.support_ticket_config[:description]&.html_safe
    assert_equal expected_description, support_ticket_description_text
  end

  test 'filter_session_parameters should filter known parameters' do
    known_parameters = ['ood_connection_info']
    expected_session_parameters = {
      "job_name":      'job',
      "job_owner":     'owner',
      "accounting_id": 'account',
      "procs":         'process',
      "queue_name":    'queue'
    }

    known_parameters.each do |parameter|
      session_info = expected_session_parameters.clone
      session_info[parameter] = {}
      assert_equal expected_session_parameters, filter_session_parameters(session_info)
    end
  end
end
