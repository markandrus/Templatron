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
require 'util/usage.rb'
require 'util/scrape.rb'
require 'util/procUrl.rb'
require 'util/makeMasthead.rb'
require 'util/transforms.rb'
require 'util/wget.rb'
require 'util/sftp.rb'
require 'util/fixUrl.rb'

# Validate arguments & print usage
if ARGV[0].nil? || ARGV[0].strip! == ''
	usage()
	exit
end

domain = ARGV[0]
tmp = 'tmp/'
wgetSite(domain, tmp)
tmpDir = './' + tmp + domain + '/'
found = `find ./#{tmp + domain} -name index.html`

# Download the entire target Web Express site using `wget'
webExpressUrl = ARGV[0]
wgetDir = 'tmp/'
wgetSite(domain, 'tmp/')

# NOTE: Assumes BSD version of `find'!
sitePath = './' + wgetDir + webExpressUrl + '/'
htmlDocs = (`find #{sitePath.sub(/\/$/, '')} -name index.html`).lines.sort do |a, b|
	a.split('/').length <=> b.split('/').length
end

def buildLinkPool(file, tmpDir, selector, domain)
	linkPool = []
	doc = Nokogiri::HTML.parse(File.read(file))
	doc.css(selector).each do |a|
		href = procUrl(a['href'].strip, domain)
		title = escape_apos(a.content.strip)
		# filePath = tmpDir + href + (File.directory?(tmpDir + href) ? 'index.html' : '')
		puts '>>' + href
		filePath = fixUrl(href, domain, tmpDir)
		puts '>>>>' + filePath.to_s
		if !File.file?(filePath) then filePath = '/dev/null' end
		linkPool.push Link.new(title, href, filePath, [])
	end
	return linkPool.uniq
end

def getParent(file, selector, domain)
	doc = Nokogiri::HTML.parse(File.read(file))
	parent = ''
	doc.css('ul.sectionhead li a').each do |a|
		parent += procUrl(a['href'].strip, domain)
	end
	return parent
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

puts ""

# Process Site Title
siteTitle = ask("Site Title: ")
print "Generating Masthead Image... "
makeMasthead(siteTitle, 'out/' + domain + '/masthead.png')
puts "out/" + domain + "/masthead.png\n\n"

# Print notice before request for new URLs
puts "Transforming `#{domain}'...\n\n"
puts "\tPlease provide new URLs for the converted pages."
puts "\tNOTE: The original URLs will also work on the TemplaTron site.\n\n"

# Transform linkPool, and write SQL to file
outputSql = to_sql(links)
File.open('out/' + domain + '/db.sql', 'w') { |f| f.write(outputSql) }
puts "Output saved to `#{'out/' + domain + '/'}'."

# Copy files to server
sftp('andrus', domain, 'webspace.uchicago.edu')

