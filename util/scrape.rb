#! /usr/local/bin/ruby

require 'rubygems'
require 'nokogiri'

def unicode_to_html(str)
	str.unpack("U*").collect {|s| (s > 127 ? "&##{s};" : s.chr) }.join("")
end

def quote_string(v)
	v.to_s.gsub(/\\/, "\\"+"\\").gsub(/'/, "''").gsub(/\n/, '').gsub(/\t/, "\\t")
end

def escape_apos(v)
	if !v.nil?
		v.to_s.gsub!(/'/, "''")
	else
		v = ' '
	end
	return v
end

def transformHeaders(doc)
	doc.css('h5').each { |h| h.name = 'h6' }
	doc.css('h4').each { |h| h.name = 'h5' }
	doc.css('h3').each { |h| h.name = 'h4' }
	doc.css('h2').each { |h| h.name = 'h3' }
	doc.css('h1').each { |h| h.name = 'h2' }
end

def deleteMisc(doc)
	doc.css('a#maincontent + h2').each { |h| h.remove }
	doc.css('a#maincontent').each { |a| a.remove }
	doc.css('div.imgrt').each { |div| div.remove }
end

def deleteComments(doc)
	doc.xpath('//comment()').each { |comment| comment.remove }
end

# Collect HTML from `div#content div#bottomrow div#col1' or `div#content',
# Exclude `div.imgrt'
# Transform h5 to h6, h4 to h5, h3 to h4, etc.
def scrape(filePath)
	# Clean up the file
	doc = Nokogiri::HTML.parse(File.read(filePath))
	rightImage = nil
	doc.css('div.imgrt img').each do |img|
		rightImage = Hash.new
		rightImage['filePath'] = img['src'].strip
		rightImage['alt'] = escape_apos(img['alt'].strip)
		rightImage['title'] = ' '
		#puts "Got Image:\t" + rightImage['filePath']
		#puts "      Alt:\t" + rightImage['alt']
		#puts "    Title:\t" + rightImage['title']
		#puts ""
		#puts ""
	end
	deleteComments(doc)
	deleteMisc(doc)
	transformHeaders(doc)
	# Aggregate content
	content = ''
	doc.css('div#content div#bottomrow div#col1').each do |div|
		content += div.inner_html
	end
	doc.css('div#content').each do |div|
		if content == ''
			content += div.inner_html
		end
	end
	# Prepare for SQL
	return {'content' => quote_string(unicode_to_html(content)), 'rightImage' => rightImage}
end

