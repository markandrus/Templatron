#! /usr/local/bin/ruby

require 'rubygems'
#require 'readline'
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

# Validate arguments & print usage
if (ARGV[0].nil? || ARGV[0].strip! == '') then usage(); exit; end

# Download the entire target Web Express site using `wget'
webExpressUrl = ARGV[0]
wgetDir = 'tmp/'
puts "Downloading `" + webExpressUrl + "'..."
puts "\twget --quiet --recursive --no-clobber --domains #{webExpressUrl} #{webExpressUrl} -P #{wgetDir} -l 2\n\n"
`wget --quiet --recursive --no-clobber --domains #{webExpressUrl} #{webExpressUrl} -P #{wgetDir} -l 2`
puts "Creating output directory..."
puts "\trm -rf #{'out/' + webExpressUrl + '/'}"
`rm -rf #{'out/' + webExpressUrl + '/'}`
puts "\tmkdir #{'out/' + webExpressUrl + '/'}\n\n"
`mkdir #{'out/' + webExpressUrl + '/'}`

# NOTE: Assumes BSD version of `find'!
sitePath = './' + wgetDir + webExpressUrl + '/'
found = `find #{sitePath.sub(/\/$/, '')} -name index.html`

# Build the pool of links according to the target sites navigation lists
# NOTE: We only need to traverse `index.html' pages
puts "Building tree structure from the following files..."
linkPool = []
found.each_line do |file|
	file.strip!
	puts "\t" + file
	doc = Nokogiri::HTML.parse(File.read(file))
	# Record all top-level navigation entries
	doc.css('ul.sectionname li a').each do |a|
		href = a['href'].strip
		tailStr = File.directory?(sitePath + href) ? 'index.html' : ''
		link = Link.new(a.content.strip, procUrl(href, webExpressUrl), sitePath + procUrl(href, webExpressUrl) + tailStr, [])
		linkPool.push(link)
	end
	linkPool.uniq!
	# Record the children (if any) of each navigation entry
	parentLinkText = ''
	# Parent link
	doc.css('ul.sectionhead li a').each do |a|
		parentLinkText += a.content.strip
		parentLinkUrl = procUrl(a['href'].strip, webExpressUrl)
		childLinkPool = []
		if parentLinkText != ''
			# Child links
			doc.css('ul.sectionhead + ul li a').each do |b|
				href = b['href'].strip
				link = Link.new(b.content.strip, procUrl(href, webExpressUrl), sitePath + procUrl(href, webExpressUrl), [])
				childLinkPool.push(link)
			end
			childLinkPool.uniq!
			# Attach child links to parent link
			for link in linkPool do
				if link.linkText === parentLinkText || link.relativePath === parentLinkUrl
					link.children = childLinkPool
				end
			end
		end
	end
	linkPool.uniq!
end

puts ""

# Process Site Title
print "Site Title: "
#siteTitle = Readline.readline
siteTitle = $stdin.gets
print "Generating Masthead Image... "
makeMasthead(siteTitle, 'out/' + webExpressUrl + '/masthead.png')
puts "out/" + webExpressUrl + "/masthead.png\n\n"

# Print notice before request for new URLs
puts "Transforming `#{webExpressUrl}'...\n\n"
puts "\tPlease provide new URLs for the converted pages."
puts "\tNOTE: The original URLs will also work on the TemplaTron site.\n\n"

# Transform linkPool, and write SQL to file
outputSql = to_sql(linkPool)
File.open('out/' + webExpressUrl + '/db.sql', 'w') { |f| f.write(outputSql) }
puts "Output saved to `#{'out/' + webExpressUrl + '/'}'."

