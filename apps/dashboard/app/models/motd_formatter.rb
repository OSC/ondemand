require "motd_formatter/markdown.rb"
require "motd_formatter/markdown_erb.rb"
require "motd_formatter/osc.rb"
require "motd_formatter/plaintext.rb"
require "motd_formatter/plaintext_erb.rb"
require "motd_formatter/rss.rb"

module MotdFormatter
  # aliasing motd classes for backwards compatibility 
  MotdFormatterOsc          = MotdFormatter::Osc
  MotdFormatterMarkdown     = MotdFormatter::Markdown
  MotdFormatterMarkdownErb  = MotdFormatter::MarkdownErb
  MotdFormatterRss          = MotdFormatter::Rss
  MotdFormatterPlaintext    = MotdFormatter::Plaintext
  MotdFormatterPlaintextErb = MotdFormatter::PlaintextErb
end
