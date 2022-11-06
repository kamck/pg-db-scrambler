require_relative '../pg_db_scrambler'
require 'bigdecimal'
require 'minitest/autorun'

class String
	def to_bd
		BigDecimal.new(self)
	end
end
