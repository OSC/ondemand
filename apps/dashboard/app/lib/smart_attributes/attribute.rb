# frozen_string_literal: true

module SmartAttributes
  # This is the base class that all other, more specific, Attributes
  # should subclass.
  class Attribute
    # Unique identifier of attribute
    # @return [String] attribute id
    attr_reader :id

    # Hash of options used to define this attribute
    # @return [Hash] attribute options
    attr_reader :opts

    # @param id [#to_s] id of attribute
    # @param opts [#to_h] options for attribute
    def initialize(id, opts = {})
      @id   = id.to_s.downcase
      @opts = opts.to_h.symbolize_keys
    end

    # Whether this attribute should be displayed as a form input
    # @return [Boolean] whether this attribute can be modified by user
    def fixed?
      !!opts[:fixed]
    end

    def hide_when_empty?
      !!opts[:hide_when_empty]
    end

    # Value of attribute. It is converted to String.
    # To support HTML file inputs, if the attribute is detected as as file input, it is not converted.
    # @return [String] attribute value
    def value
      if ['file_field', 'file_attachments'].include?(widget) || opts[:value].class.to_s.match(/UploadedFile/)
        opts[:value]
      else
        opts[:value].to_s
      end
    end

    # Check select widget has options values provided
    # @return [StandardError] if missing any values
    def validate!
      if widget == 'select' && (select_choices.size != select_choices.compact.size)
        raise StandardError, I18n.t('dashboard.batch_connect_form_invalid', id: id)
      end

      self
    end

    def value=(other)
      @opts[:value] = other
    end

    def cacheable?(default_value)
      if opts[:cacheable].nil?
        default_value
      else
        to_bool(opts[:cacheable])
      end
    end

    # Type of form widget used for this attribute
    # @return [String] widget type
    def widget
      (opts[:widget] || 'text_field').to_s
    end

    # Form label for this attribute
    # @param fmt [String, nil] formatting of form label
    # @return [String] form label
    def label(fmt: nil)
      (opts[:label] || id.titleize).to_s
    end

    # Help text for this attribute
    # @param fmt [String, nil] formatting of help text
    # @return [String] help text
    def help(fmt: nil)
      opts[:help].to_s
    end

    def help_html(fmt: nil)
      OodAppkit.markdown.render(help(fmt: fmt)).html_safe
    end

    # Whether this attribute is required
    # @return [Boolean] is required
    def required
      !!opts[:required]
    end

    def display?
      !!opts[:display]
    end

    # Submission hash describing how to submit this attribute
    # @param fmt [String, nil] formatting of hash
    # @return [Hash] submission hash
    def submit(fmt: nil)
      {}
    end

    # The comparison operator
    # @param other [#to_s] object to compare against
    # @return [Boolean] whether objects are equivalent
    def ==(other)
      id == other.to_s
    end

    # The value of the attribute
    # @return [String] attribute value
    def to_s
      value.to_s
    end

    # Hash of html options for Rails form helpers
    # @return [Hash] key value pairs are html options
    def html_options
      opts.fetch(:html_options, {})
    end

    # Assign the html_options
    # @return [Hash] key value pairs are html options
    def html_options=(input_opts)
      opts[:html_options] = input_opts
    end

    # Hash of field options for Rails form helpers
    # these are assumed to be everything that isn't already defined
    # as a method on this class, but is in the opts hash, except for
    # label, help, and required, which are defined methods on this class
    # but should be called to be included.
    #
    # @return [Hash] key value pairs are field options
    def field_options(fmt: nil)
      opts.reject do |k, _v|
        reserved_keys.include?(k)
      end.merge({
                  label:    label(fmt: fmt),
                  help:     help_html(fmt: fmt),
                  required: required
                })
    end

    # Hash of both field options and html options
    # @return [Hash] key value pairs are field and html options
    def all_options(fmt: nil)
      field_options(fmt: fmt).merge(html_options)
    end

    # Hash of field options to serialize (to yaml). Similar to
    # field_options, with the exception that it does not filter
    # reserved_keys.
    #
    # It's basically calling opts with some keys updated for convenience.
    def options_to_serialize(fmt: nil)
      opts.merge({
                   label:    label(fmt: fmt),
                   help:     help_html(fmt: fmt),
                   required: required
                 }).compact
    end

    # Array of choices for select fields used to build <option> tags
    # @return [Array] choices in form [name, value], [name, value]
    def select_choices(hide_excludable: true)
      opts.fetch(:options, []).to_a.reject do |option_data|
        if hide_excludable
          option = option_data.is_a?(Array) ? option_data.first : option_data
          exclude_select_choices.include?(option)
        else
          false
        end
      end.map do |entry|
        # always cast to array so other layers can try .first & .second for labels and values.
        entry.is_a?(Array) ? entry : [entry, entry]
      end
    end

    def exclude_select_choices
      opts.fetch(:exclude_options, []).to_a
    end

    def exclude_select_choices=(list)
      opts[:exclude_options] = list
    end

    # String value if this attribute is "checked" (relevant for checkboxes)
    # @return [String] checked value
    def checked_value
      opts.fetch(:checked_value, '1')
    end

    # String value if this attribute is "unchecked" (relevant for checkboxes)
    # @return [String] unchecked value
    def unchecked_value
      opts.fetch(:unchecked_value, '0')
    end

    def min=(value)
      @opts[:min] = value.to_i
    end

    def max=(value)
      @opts[:max] = value.to_i
    end

    private

    # Array of reserved keys for options that are used as methods in this class
    # for the value of these options, the methods in this class should be used,
    # instead of the underlying option
    # @return [Array<Symbol>] option keys
    def reserved_keys
      [
        :widget, :fixed, :hide_when_empty, :options, :html_options, :checked_value, :unchecked_value,
        :required, :label, :help, :cacheable
      ]
    end

    FALSE_VALUES = [false, '', 0, '0', 'f', 'F', 'false', 'FALSE', 'off', 'OFF', 'no', 'NO'].freeze

    # Returns false if value is included among False_Values set
    # @param value the value to be checked
    # @return [Boolean]
    def to_bool(value)
      !FALSE_VALUES.include?(value)
    end
  end
end
