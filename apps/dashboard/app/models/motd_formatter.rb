# Module for all the different Message of the Day (MOTD) formatters.
module MotdFormatter
  # aliasing motd classes for backwards compatibility 
  MotdFormatterOsc          = MotdFormatter::Osc
  MotdFormatterMarkdown     = MotdFormatter::Markdown
  MotdFormatterMarkdownErb  = MotdFormatter::MarkdownErb
  MotdFormatterRss          = MotdFormatter::Rss
  MotdFormatterPlaintext    = MotdFormatter::Plaintext
  MotdFormatterPlaintextErb = MotdFormatter::PlaintextErb
end
