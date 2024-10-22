# frozen_string_literal: true

Browser.modern_rules.clear
Browser.modern_rules.tap do |rules|
  # original:
  # rules << -> (b) { b.webkit?  }
  # rules << -> (b) { b.firefox? && b.version.to_i >= 17  }
  # rules << -> (b) { b.ie? && b.version.to_i >= 9 && !b.compatibility_view?  }
  # rules << -> (b) { b.edge? && !b.compatibility_view?  }
  # rules << -> (b) { b.opera? && b.version.to_i >= 12  }
  # rules << -> (b) { b.firefox? && b.device.tablet? && b.platform.android? && b.version.to_i >= 14  }

  # for now, explicitly specify chrome and safari versions but allow
  # other webkit (i.e. mobile)
  rules << ->(b) { b.ie? && b.version.to_i >= 11 && !b.compatibility_view? }
  rules << ->(b) { b.chrome? && b.version.to_i >= 34 }
  rules << ->(b) { b.safari? && b.version.to_i >= 8 }
  rules << ->(b) { b.webkit? && !b.chrome? && !b.safari? }
  rules << ->(b) { b.firefox? && b.version.to_i >= 19 }
  rules << ->(b) { b.edge? && !b.compatibility_view? }
  rules << ->(b) { b.opera? && b.version.to_i >= 12  }
  rules << ->(b) { b.firefox? && b.device.tablet? && b.platform.android? && b.version.to_i >= 14 }
end
