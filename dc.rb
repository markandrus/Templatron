#! /usr/local/bin/ruby

require 'rubygems'
require 'nokogiri'
require 'class/page.rb'
require 'class/node.rb'
require 'class/menuLink.rb'
require 'class/fieldDataBody.rb'
require 'class/urlAlias.rb'
require 'class/nodeAccess.rb'
require 'class/link.rb'
require 'util/scrape.rb'

if (ARGV[0].nil? || ARGV[0].strip! == '') || (ARGV[1].nil? || ARGV[1].strip! == '')
	puts "DC Autobot 1.0, a University of Chicago Web Express to TemplaTron site converter."
	puts "Usage: #{$0} [WE_URL] [OUTPUT_SQL]"
	puts "Example: #{$0} crimelab.uchicago.edu sql/crimelab.sql\n\n"
	puts "Mail bug reports and suggestions to <andrus@uchicago.edu>."
	exit
end

# Read in the initial Templatron SQL file
baseSql = File.read('sql/base.sql')

# Download the entire target Web Express site using `wget'
webExpressUrl = ARGV[0]
wgetDir = 'tmp/'
`wget --quiet --recursive --no-clobber --domains #{webExpressUrl} #{webExpressUrl} -P #{wgetDir} -l 2`

# NOTE: Assumes BSD version of `find'!
sitePath = './' + wgetDir + webExpressUrl + '/'
found = `find #{sitePath.sub(/\/$/, '')} -name index.html`

# Build the pool of links according to the target sites navigation lists
# NOTE: We only need to traverse `index.html' pages
linkPool = []
found.each_line do |file|
	file.strip!
	doc = Nokogiri::HTML.parse(File.read(file))
	# Record all top-level navigation entries
	doc.css('ul.sectionname li a').each do |a|
		href = a['href'].strip
		tailStr = File.directory?(sitePath + href) ? 'index.html' : ''
		link = Link.new(a.content.strip, href, sitePath + href.sub(/^\//, '') + tailStr, [])
		linkPool.push(link)
	end
	linkPool.uniq!
	# Record the children (if any) of each navigation entry
	parentLinkText = ''
	# Parent link
	doc.css('ul.sectionhead li a').each do |a|
		parentLinkText += a.content.strip
		childLinkPool = []
		if parentLinkText != ''
			# Child links
			doc.css('ul.sectionhead + ul li a').each do |b|
				href = b['href'].strip
				link = Link.new(b.content.strip, href, sitePath + href.sub(/^\//, ''), [])
				childLinkPool.push(link)
			end
			childLinkPool.uniq!
			# Attach child links to parent link
			for link in linkPool do
				if link.linkText === parentLinkText
					link.children = childLinkPool
				end
			end
		end
	end
	linkPool.uniq!
end

# Transform the pool of links into our SQL-generating `Page' objects
def transformLinkPool(linkPool)
	return linkPool.map do |link|
		# Process children first
		children = transformLinkPool(link.children)
		content = scrape(link.filePath)
		# Process parent
		page = Page.new(link.linkText, content, link.relativePath, children)
	end
end

# Transform and collect SQL
outputSql = ''
pages = transformLinkPool(linkPool)
# puts baseSql
outputSql += baseSql
i = 0
pages.each do |page|
	if !page.nil? then
		page.menuLink.weight = -50 + i
		i += 1
		# puts page.to_s
		outputSql += page.to_s
	end
end

# Write SQL to file
File.open(ARGV[1], 'w') {|f| f.write(outputSql)}

