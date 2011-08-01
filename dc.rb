#! /usr/local/bin/ruby

require 'rubygems'
require 'nokogiri'
require 'highline/import'

require 'class/page.rb'
require 'class/node.rb'
require 'class/menuLink.rb'
require 'class/fieldDataBody.rb'
require 'class/fieldDataRightImage.rb'
require 'class/urlAlias.rb'
require 'class/nodeAccess.rb'
require 'class/link.rb'

require 'util/misc.rb'
require 'util/scrape.rb'
require 'util/transforms.rb'
require 'util/makeMasthead.rb'

# Validate arguments & print usage
if ARGV[0].nil? || ARGV[0].strip! == '' then usage() & exit end

domain = ARGV[0]
tmp = 'tmp/'
wgetSite(domain, tmp)
tmpDir = './' + tmp + domain + '/'
# NOTE: Assumes BSD version of `find'
htmlDocs = (`find #{tmp + domain} -name index.html`).lines.sort do |a, b|
	a.split('/').length <=> b.split('/').length
end

puts "Building tree structure from the following files..."
links = []
childPool = htmlDocs.map do |file|
	puts "\t" + file.strip!
	links = links.empty? ? buildLinkPool(file, tmpDir, 'ul.sectionname li a', domain) : links
	parent = getParent(file, 'sectionhead li a', domain)
	{:parent => parent, :children => buildLinkPool(file, tmpDir, 'ul.sectionhead + ul li a', domain)}
end
childPool.each do |child|
	links.select { |link| fixUrl(link.relativePath, domain, tmpDir) == fixUrl(child[:parent], domain, tmpDir) }.each do |parent|
		parent.children = child[:children]
	end
end

# Process Site Title
siteTitle = ask("\nSite Title: ") { |q| q.validate = /[a-z]+/ }
print "Generating Masthead Image... "
if makeMasthead(siteTitle, 'out/' + domain + '/masthead.png')
	puts "`out/" + domain + "/masthead.png'\n\n"
else
	puts "FAIL"
end

# Print notice before request for new URLs
puts "Transforming `#{domain}'...\n\n"
puts "\tPlease provide new URLs for the converted pages."
puts "\tNOTE: The original URLs will also work on the TemplaTron site.\n\n"

# Transform linkPool, and write SQL to file
outputSql = to_sql(links)
File.open('out/' + domain + '/db.sql', 'w') { |f| f.write(outputSql) }
puts "\nOutput saved to `#{'out/' + domain + '/'}'."

# These images will be moved to the server
mkdirCmd = "mkdir ./out/#{domain}/img 1>/dev/null 2>/dev/null"
`#{mkdirCmd}`
mkdirCmd = "mkdir ./out/#{domain}/img/resize 1>/dev/null 2>/dev/null"
`#{mkdirCmd}`
$imgPool.each do |imgHash|
	puts imgHash['filePath']
	mvCmd = "mv #{tmpDir + imgHash['filePath'].gsub(' ', '\ ')} ./out/#{domain}/img/#{imgHash['fileName'].gsub(' ', '\ ')} 1>/dev/null 2>/dev/null"
	`#{mvCmd}`
	convCmd = "convert -resize 218 ./out/#{domain}/img/#{imgHash['fileName'].gsub(' ', '\ ')} ./out/#{domain}/img/resize/#{imgHash['fileName'].gsub(' ', '\ ')} 1>/dev/null 2>/dev/null"
	`#{convCmd}`
end

# Copy files to server
sftp('andrus', domain, 'webspace.uchicago.edu')

