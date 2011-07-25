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

# The necessary initial SQL file
baseSql = File.read('sql/base.mysql')

# Method for downloading website
webExpressUrl = 'crimelab.uchicago.edu'
wgetDir = 'tmp/'
`wget --quiet --recursive --no-clobber --domains #{webExpressUrl} #{webExpressUrl} -P #{wgetDir} -l 2`

# Assumes BSD version of `find'
sitePath = './' + wgetDir + webExpressUrl + '/'
found = `find ./tmp/crimelab.uchicago.edu -name index.html`

# First we want to build our pool of links, AKA the navigation
linkPool = []
found.each_line do |file|
	file.strip!
	# path = file.sub(sitePath, '')
	# if path === 'index.html'
	doc = Nokogiri::HTML.parse(File.read(file))
	doc.css('ul.sectionname li a').each do |a|
		href = a['href'].strip
		tailStr = File.directory?(sitePath + href) ? 'index.html' : ''
		link = Link.new(a.content.strip, href, sitePath + href.sub(/^\//, '') + tailStr, [])
		linkPool.push(link)
	end
	linkPool = linkPool
	parentLinkText = ''
	doc.css('ul.sectionhead li a').each do |a|
		parentLinkText += a.content.strip
		childLinkPool = []
		if parentLinkText != ''
			doc.css('ul.sectionhead + ul li a').each do |b|
				href = b['href'].strip
				link = Link.new(b.content.strip, href, sitePath + href.sub(/^\//, ''), [])
				childLinkPool.push(link)
			end
			childLinkPool.uniq!
			for link in linkPool do
				if link.linkText === parentLinkText
					link.children = childLinkPool
				end
			end
		end
	end
	linkPool = linkPool.uniq
end

def transformLinkPool(linkPool)
	return linkPool.map do |link|
		children = transformLinkPool(link.children)
		content = scrape(link.filePath)
		page = Page.new(link.linkText, content, link.relativePath, children)
		#puts content
	end
end

pages = transformLinkPool(linkPool)

puts baseSql
i = 0
pages.each do |page|
	if !page.nil? then
		page.menuLink.weight = -50 + i
		i += 1
		puts page.to_s
	end
end
