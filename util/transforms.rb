#! /usr/local/bin/ruby

require 'highline/import'

$aliasPool = []
$imgPool = []

def getParent(file, selector, domain)
	doc = Nokogiri::HTML.parse(File.read(file))
	parent = ''
	doc.css('ul.sectionhead li a').each do |a|
		parent += procUrl(a['href'].strip, domain)
	end
	return parent
end

def buildLinkPool(file, tmpDir, selector, domain)
	linkPool = []
	doc = Nokogiri::HTML.parse(File.read(file))
	doc.css(selector).each do |a|
		href = procUrl(a['href'].strip, domain)
		title = escape_apos(a.content.strip)
		filePath = tmpDir + fixUrl(href, domain, tmpDir)
		if !File.file?(filePath) then filePath = '/dev/null' end
		linkPool.push Link.new(title, href, filePath, [])
	end
	return linkPool.uniq
end

# Build "New" UrlAlias with input from user
def newUrlAlias(linkText, linkPath, hasParent)
	tab = ''
	if hasParent then tab = "\t" end
	puts tab + "Title:    " + linkText
	puts tab + "URL:      " + linkPath
	if linkPath != '/' && (linkPath.length < 6 || (linkPath[0, 6] != 'http:/' && linkPath[0, 6] != 'https:')) then
		newLink = String.new(linkPath).split('/')
		if !newLink.nil? && !newLink.last.nil? then newLink = newLink.last.gsub(/\.s?html/, '') else newLink = '' end
		url = nil
		while !$aliasPool.index(url).nil? || url.nil?
			if !url.nil?
				puts "\n" + tab + "ERROR: That URL alias is already in use. Please provide another"
			end
			url = ask(tab + '> ') { |q| q.default = newLink != '' ? 'page/' + newLink : '' }
		end
		if url != '!!' then $aliasPool.push(url) end
	else
		url = linkPath
	end
	puts "\n"
	UrlAlias.new(getLastUrlAliasId(), 0, url.strip)
end

# Transform the pool of links into our SQL-generating `Page' objects
def transformLinkPool(linkPool, hasParent)
	(linkPool.map do |link|
		# Prompt for "New" UrlAlias
		newUrlAlias = newUrlAlias(link.linkText, link.relativePath, hasParent)
		# Process children first
		children = transformLinkPool(link.children, true)
		if !children.nil? && !children.empty? then puts "" end
		# Process parent
		content = ''
		rightImage = nil
		if File.file?(link.filePath)
			scraped = scrape(link.filePath)
			content = scraped['content']
			rightImage = scraped['rightImage']
			if !rightImage.nil?
				imgHash = {'filePath' => rightImage['filePath'], 'fileName' => rightImage['filePath'].split('/').last}
				$imgPool.push imgHash
			end
		end
		page = Page.new(link.linkText, content, link.relativePath, children, rightImage)
		newUrlAlias.node = page.id
		page.newUrlAlias = newUrlAlias
		if newUrlAlias.linkPath == '!!' then nil else page end
	end).reject { |n| n.nil? }
end

def weightParentPages(pages)
	i = 0
	pages.each { |page| page.menuLink.weight = -50 + i; i += 1 }
end

def correctPseudoPages(pages)
	pages.each do |page|
		page.isPseudo = page.initPath[0, 6] == 'http:/' || page.initPath[0, 6] == 'https:'
	end
end

def to_sql(linkPool)
	correctPseudoPages(weightParentPages(transformLinkPool(linkPool, false))).inject(
		File.read('etc/base.sql')
	) { |sql, page| sql += page.to_s }
end

