module BoolReader
  FALSE_VALUES = ['', '0', 'F', 'FALSE', 'OFF', 'NO'].freeze

  def read_bool(value)
    # By converting to a string and upcasing, the size of FALSE_VALUES is less than the effective false values,
    # which are [nil, false, '', 0, '0', 'f', 'F', 'false', 'FALSE', 'off', 'OFF', 'no', 'NO'],
    # as well as all other capitalization combinations
    !FALSE_VALUES.include?(value.to_s.upcase)
  end
end
