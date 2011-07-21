#! /usr/local/bin/ruby

require 'rubygems'
require 'nokogiri'

# Collect HTML from `div#content div#bottomrow div#col1' or `div#content',
# Exclude `div.imgrt'
# Transform h5 to h6, h4 to h5, h3 to h4, etc.
# `doc' is Nokogiri::HTML
def scrape(doc)
	content = ''
	doc.css('div.imgrt').each do |div|
		div.remove
	end
	doc.css('div#content div#bottomrow div#col1').each do |div|
		content += div.content
	end
	doc.css('div#content').each do |div|
		content += div.content
	end
	return content
end

