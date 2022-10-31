# frozen_string_literal: true
require "smart_attributes"

# Model class to hold the support ticket form data needed to submit a support ticket
#
class SupportTicket
  include ActiveModel::Model
  include SupportTicketValidator

  attr_reader :attributes

  validate :support_ticket_validation

  DEFAULT_FIELDS = [:username, :email, :cc, :subject, :session_id, :session_description, :attachments, :description, :queue]

  def self.from_config(attributes_config)
    local_opts = attributes_config.fetch(:attributes, {})
    attrib_list = attributes_config.fetch(:form, DEFAULT_FIELDS)
    Rails.logger.info "SupportTicket defined attributes: #{attrib_list}"

    attributes = attrib_list.map do |attribute_id|
      default_opts = SupportTicket.default_opts.fetch(attribute_id.to_sym, {})
      attribute_opts = default_opts.merge(local_opts.fetch(attribute_id.to_sym, {}))

      attribute_opts = { value: attribute_opts, fixed: true } unless attribute_opts.is_a?(Hash)

      SmartAttributes::AttributeFactory.build(attribute_id, attribute_opts)
    end

    SupportTicket.new(attributes)
  end

  def attributes=(params = {})
    params.each do |attr, value|
      self.public_send("#{attr}=", value) if self.respond_to?("#{attr}=")
    end if params
  end

  # @param attributes [Array<Attribute>] list of attribute objects
  def initialize(attributes = [])
    @attributes = attributes
    @attributes.each do |attribute|
      define_singleton_method("#{attribute.id}="){ |value| attribute.value = value }
      define_singleton_method("#{attribute.id}"){ attribute.value }
    end
  end

  # To avoid errors when expected fields are removed from the list of configured attributes
  def method_missing(method_name, *arguments, &block)
    nil
  end

  # For a block {|attribute| ...}
  # @yield [SmartAttribute::Attribute] Gives the next attribute object in the
  #   list
  def each(&block)
    @attributes.each(&block)
  end

  private

  def self.default_opts
    {
      username: {
        required: true,
        readonly: true,
      },
      email: {
        widget: "email_field",
        required: true,
      },
      cc: {
        widget: "email_field",
      },
      subject: {
        required: true,
      },
      session_id: {
        widget: "hidden_field",
      },
      session_description: {
        hide_when_empty: true,
        disabled: true,
      },
      attachments: {
        widget: "file_attachments",
      },
      description: {
        widget: "text_area",
        required: true,
        rows: 10,
      },
      queue: {
        widget: "hidden_field",
      },
    }
  end

end