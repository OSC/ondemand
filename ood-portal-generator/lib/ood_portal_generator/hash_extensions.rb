module OodPortalGenerator
  # Some elements have been taken from Rails (https://github.com/rails/rails)
  # and it's LICENSE has been added as RAILS-LICENSE in the root directory of this project.
  module HashExtensions
    refine Hash do
      # Returns a hash that includes everything except given keys.
      #   hash = { a: true, b: false, c: nil }
      #   hash.except(:c)     # => { a: true, b: false }
      #   hash.except(:a, :b) # => { c: nil }
      #   hash                # => { a: true, b: false, c: nil }
      #
      # This is useful for limiting a set of parameters to everything but a few known toggles:
      #   @person.update(params[:person].except(:admin))
      def except(*keys)
        slice(*self.keys - keys)
      end unless method_defined?(:except)

      # Returns a new hash with all keys converted to symbols, as long as
      # they respond to +to_sym+. This includes the keys from the root hash
      # and from all nested hashes and arrays.
      #
      #   hash = { 'person' => { 'name' => 'Rob', 'age' => '28' } }
      #
      #   hash.deep_symbolize_keys
      #   # => {:person=>{:name=>"Rob", :age=>"28"}}
      def deep_symbolize_keys
        deep_transform_keys { |key| key.to_sym rescue key }
      end

      # Returns a new hash with all keys converted by the block operation.
      # This includes the keys from the root hash and from all
      # nested hashes and arrays.
      #
      #  hash = { person: { name: 'Rob', age: '28' } }
      #
      #  hash.deep_transform_keys{ |key| key.to_s.upcase }
      #  # => {"PERSON"=>{"NAME"=>"Rob", "AGE"=>"28"}}
      def deep_transform_keys(&block)
        _deep_transform_keys_in_object(self, &block)
      end

      # Destructively converts all keys by using the block operation.
      # This includes the keys from the root hash and from all
      # nested hashes and arrays.
      def deep_transform_keys!(&block)
        _deep_transform_keys_in_object!(self, &block)
      end

      private

      # Support methods for deep transforming nested hashes and arrays.
      def _deep_transform_keys_in_object(object, &block)
        case object
        when Hash
          object.each_with_object(self.class.new) do |(key, value), result|
            result[yield(key)] = _deep_transform_keys_in_object(value, &block)
          end
        when Array
          object.map { |e| _deep_transform_keys_in_object(e, &block) }
        else
          object
        end
      end

      def _deep_transform_keys_in_object!(object, &block)
        case object
        when Hash
          object.keys.each do |key|
            value = object.delete(key)
            object[yield(key)] = _deep_transform_keys_in_object!(value, &block)
          end
          object
        when Array
          object.map! { |e| _deep_transform_keys_in_object!(e, &block) }
        else
          object
        end
      end
    end
  end
end
