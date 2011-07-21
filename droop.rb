#! /usr/local/bin/ruby

require 'rubygems'
require 'nokogiri'
require 'class/page.rb'
require 'class/node.rb'
require 'class/menuLink.rb'
require 'class/fieldDataBody.rb'
require 'class/urlAlias.rb'
require 'class/nodeAccess.rb'
require 'util/scrape.rb'

# Method for downloading website
webExpressUrl = 'crimelab.uchicago.edu'
wgetDir = 'tmp/'
`wget --quiet --recursive --no-clobber --domains #{webExpressUrl} #{webExpressUrl} -P #{wgetDir} -l 2`

# Assumes BSD version of `find'
sitePath = './' + wgetDir + webExpressUrl + '/'
found = `find ./tmp/crimelab.uchicago.edu -name index.html`
found.each_line do |file|
	file.strip!
	path = file.sub(sitePath, '')
	if path == 'index.html'
		doc = Nokogiri::HTML.parse(File.read(file))
		doc.css('ul.sectionname li a').each do |a|
			puts a.content
		end
	end
	puts scrape(doc)
end


	#doc = Nokogiri::HTML.parse(File.read(found))
	#doc.css('ul.sectionhead li a').each do |parentLink|
# Algorithm
#    go to index
#    for each `li` in `ul.menu`
#        title = `li a`.innerHTML
#        url = `li a`.url
#        page = Node.new(id, 'page', title)
#        goto url
#            if `ul.sectionhead + ul`
#                set hasChildren = true
#                for each `ul.sectionhead + ul li`
#                    create node
#                    create link    
#

# mL = MenuLink.new(474, 0, 'Sample Content', 22, true, -48, 1);
# sL = MenuLink.new(475, 474, 'Basic Page', 23, false, -50, 2);
# puts mL.to_s
# puts sL.to_s
