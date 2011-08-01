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

# Variables
domain = ARGV[0]
tmp = 'tmp/'
wgetSite(domain, tmp)
tmpDir = './' + tmp + domain + '/'

# Find all `index.html' files and sort by depth
# NOTE: Assumes BSD version of `find'
findCmd = "find #{tmp + domain} -name index.html"
htmlDocs = (`#{findCmd}`).lines.sort { |a, b| a.split('/').length <=> b.split('/').length }

# Build Tree Structure
puts "Building tree structure from the following files..."
links = []
htmlDocs.each do |file|
	puts "\t" + file.strip!
	# Build (parent) link pool from the first `file', AKA `/index.hmtl'
	links = links.empty? ? buildLinkPool(file, tmpDir, 'ul.sectionname li a', domain) : links
	# If this is a child page, determine the parent and build any child links
	parent = getParent(file, 'sectionhead li a', domain)
	children = buildLinkPool(file, tmpDir, 'ul.sectionhead + ul li a', domain)
	# Connect the children to their respective parent; `links.select' should return only 1 result
	links.select { |link| fixUrl(link.relativePath, domain, tmpDir) == fixUrl(parent, domain, tmpDir) }.each { |parent| parent.children = children }
end

# Process Site Title
siteTitle = ask("\nSite Title: ") { |q| q.validate = /.+/ }
print "Generating Masthead Image... "
mastheadPath = 'out/' + domain + '/masthead.png'
puts makeMasthead(siteTitle, mastheadPath) ? '`' + mastheadPath + "'\n\n" : "FAIL"

# Print notice before request for new URLs
puts "Transforming `#{domain}'...\n\n"
puts "\tPlease provide new URLs for the converted pages."
puts "\tNOTE: The original URLs will also work on the TemplaTron site.\n\n"

# Transform linkPool, and write SQL to file
File.open('out/' + domain + '/db.sql', 'w') { |f| f.write(to_sql(links)) }
puts "\nOutput saved to `#{'out/' + domain + '/'}'..."

# These images will be moved to the server
mkdirCmd = "mkdir ./out/#{domain}/img"
`#{mkdirCmd}`
mkdirCmd = "mkdir ./out/#{domain}/img/resize"
`#{mkdirCmd}`
puts "The following images will be copied to the new site:"
$imgPool.each do |imgHash|
	puts "\t" + imgHash['filePath']
	mvCmd = "mv #{tmpDir + imgHash['filePath'].gsub(' ', '\ ')} ./out/#{domain}/img/#{imgHash['fileName'].gsub(' ', '\ ')} 1>/dev/null 2>/dev/null"
	`#{mvCmd}`
	convCmd = "convert -resize 218 ./out/#{domain}/img/#{imgHash['fileName'].gsub(' ', '\ ')} ./out/#{domain}/img/resize/#{imgHash['fileName'].gsub(' ', '\ ')} 1>/dev/null 2>/dev/null"
	`#{convCmd}`
end

# Copy files to server
sftp('andrus', domain, 'webspace.uchicago.edu')

