#! /usr/local/bin/ruby

class FieldDataBody
    attr_accessor :id, :bundle, :bodyValue
    def initialize(id, bundle, bodyValue)
        @id = id
		@bundle = bundle
		@bodyValue = bodyValue
    end
    def to_s
		return buildSql('field_data_body', ['node', @bundle, 0, @id, @id, 'und', 0, @bodyValue, '', 'full_html']) + "\n" +
			   buildSql('field_revision_body', ['node', @bundle, 0, @id, @id, 'und', 0, @bodyValue, '', 'full_html'])
    end
end

