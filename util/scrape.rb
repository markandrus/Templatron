#! /usr/local/bin/ruby

require 'rubygems'
require 'nokogiri'
require 'mysql'

def unicode_to_html(str)
	str.unpack("U*").collect {|s| (s > 127 ? "&##{s};" : s.chr) }.join("")
end

def quote_string(v)
	# v.to_s.gsub(/\\/, '\&\&').gsub(/'/, "\'")
=begin
	v.to_s.gsub("\0", '\0'
		 ).gsub(/'/, '\''
		 ).gsub(/"/, '\"'
		 ).gsub("\b", '\b'
		 ).gsub("\n", '\n'
		 ).gsub("\r", '\r'
		 ).gsub("\t", '\t'
		 ).gsub("\Z", '\Z'
		 ).gsub('\', '\\'
		 ).gsub('%', '\%'
		 ).gsub('_', '\_'
		 )
=end
	unicode_to_html(v.to_s.gsub(/\\/, "\\"+"\\").gsub(/'/, "''").gsub(/\n/, "\\n").gsub(/\t/, "\\t"))
	# Mysql.escape_string(v)
end

# Collect HTML from `div#content div#bottomrow div#col1' or `div#content',
# Exclude `div.imgrt'
# Transform h5 to h6, h4 to h5, h3 to h4, etc.
def scrape(filePath)
	doc = Nokogiri::HTML.parse(File.read(filePath))
	content = ''
	doc.css('h5').each { |h| h.name = 'h6' }
	doc.css('h4').each { |h| h.name = 'h5' }
	doc.css('h3').each { |h| h.name = 'h4' }
	doc.css('h2').each { |h| h.name = 'h3' }
	doc.css('h1').each { |h| h.name = 'h2' }
	doc.css('a#maincontent').each do |a|
		a.remove
	end
	doc.css('div.imgrt').each do |div|
		div.remove
	end
	doc.css('div#content div#bottomrow div#col1').each do |div|
		content += div.inner_html
	end
	doc.css('div#content').each do |div|
		if content == ''
			content += div.inner_html
		end
	end
	content.gsub!(/<!--[ \r\n\t]*.*[ \r\n\t]*-->/, '')
	return quote_string(content)
end

