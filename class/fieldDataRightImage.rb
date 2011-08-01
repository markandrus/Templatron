#! /usr/local/bin/ruby

$lastFid = 60
def getLastFid()
	$lastFid += 1
	return $lastFid - 1
end

class FileManaged
	attr_accessor :fid, :filename, :uri, :filemime
	def initialize(fid, filename, uri)
		@fid = fid; @filename = filename; @uri = uri
		@filemime = 'image/' + @filename.match(/[a-z]*$/).to_s.sub(/jpg$/, 'jpeg')
	end

	# Returns SQL
	def to_s
		return buildSql('file_managed', {'fid' => @fid, 'filename' => @filename.gsub(/^\//, ''), 'uri' => @uri, 'filemime' => @filemime, 'status' => 1}) + "\n"
	end
end

class FieldDataRightImage
    attr_accessor :id, :bundle, :fid, :alt, :title, :filePath, :fileManaged
    def initialize(id, bundle, filePath, alt, title)
        @id = id; @bundle = bundle; @filePath = filePath; @alt = alt; @title = title
		@fid = getLastFid()
		fileName = @filePath.split('/')
		if !fileName.nil? && !fileName.empty? then fileName = fileName.last else fileName = @filePath end
		@fileManaged = FileManaged.new(@fid, fileName, @filePath)
    end

    # Returns SQL
    def to_s
		return @fileManaged.to_s + "\n" +
			   buildSql('field_data_field_rightimage', ['node', @bundle, 0, @id, @id, 'und', 0, @fid, @alt, @title]) + "\n" +
			   buildSql('field_revision_field_rightimage', ['node', @bundle, 0, @id, @id, @fid, @alt, @title])
    end
end

