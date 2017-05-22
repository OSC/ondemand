module SmartAttributes
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
      @id   = id.to_s
      @opts = opts.to_h.symbolize_keys
    end

    # Whether this attribute should be displayed as a form input
    # @return [Boolean] whether this attribute can be modified by user
    def fixed?
      !!opts[:fixed]
    end

    # Value of attribute
    # @return [String] attribute value
    def value
      opts[:value].to_s
    end

    def value=(other)
      @opts[:value] = other
    end

    # Type of form widget used for this attribute
    # @return [String] widget type
    def widget
      (opts[:widget] || "text_field").to_s
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

    # Whether this attribute is required
    # @return [Boolean] is required
    def required
      !!opts[:required]
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
      value
    end
  end
end
