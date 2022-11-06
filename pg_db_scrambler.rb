require 'bigdecimal'

module RowModifiers
  class OrderModifier
    UPPER_LIMIT = 5000.00

    def call(row)
      row.contract_price = genrand(50.0, UPPER_LIMIT)
      row.net_contract_price = genrand(10.0, row.contract_price)
      row.contract_price_rebate = format_bd subtract(row.contract_price, row.net_contract_price)
    end

    private

    def genrand(limit1, limit2=nil)
      if limit2.nil?
        rand(0.0..limit1.to_f)
      else
        rand(limit1..limit2.to_f)
      end.round(2).to_s
    end

    def subtract(*vals)
      val = BigDecimal.new(vals.shift)
      vals.each { |v| val = val - BigDecimal.new(v) }

      val
    end

    def format_bd(bd)
      bd.truncate(2).to_s('F')
    end
  end

  class UsersModifier
    def initialize(user_count = 1)
      @user_count = user_count
    end

    def call(row)
      return if row.id == "0"

      row.email_address = "user-#{@user_count}@nologin"
      row.status = 'DISABLED'
      row.name = "User #{@user_count}"
      row.company_name = "Company for User #{@user_count}"
      row.job_title = "Title for User #{@user_count}"
      row.phone_number = "%010d" % [@user_count]
      row.failed_login_attempt_count = 0

      @user_count += 1
    end
  end
end

class EntityBuilder
  PG_FIELD_SEPARATOR = "\t"
  PG_NULL = '\N'

  def initialize(cols)
    @klass = EntityBuilder.build_class(cols)
  end

  def build(row='')
    @klass.new row.split(PG_FIELD_SEPARATOR)
  end

  private

  def self.build_class(attrs)
    Class.new do
      attr_accessor *attrs

      define_method(:initialize) do |*vals|
        attrs.each_with_index do |attr, i|
          value = vals.first[i]
          instance_variable_set "@#{attr}", value == PG_NULL ? nil : value
        end
      end

      define_method(:string) do 
        attrs.collect do |attr|
          v = instance_variable_get("@#{attr}")
          case v
          when NilClass then PG_NULL
          when TrueClass, FalseClass then v.to_s[0]
          else v
          end
        end.join(PG_FIELD_SEPARATOR)
      end
    end
  end
end

module PgDumpParser
  def self.call(inio, outio)
    modifier = nil
    builder = nil

    inio.each_line do |line|
      modifier = nil if line =~ /^\\\./

      unless modifier.nil?
        row = builder.build line
        modifier.call row
        line = row.string
      end

      outio.puts line

      if line =~ /^COPY.*FROM stdin;$/
        modifier = find_modifier get_table(line)
        builder = EntityBuilder.new get_columns(line) unless modifier.nil?
      end
    end
  end

  private

  def self.get_table(line)
    line[/^COPY\s(\w+)\s/, 1]
  end

  def self.get_columns(line)
    line[/COPY\s\w+\s\((.*)\)\sFROM stdin;/, 1].split(/\s*,\s*/)
  end

  def self.find_modifier(table_name)
    class_name = "#{table_name.split('_').collect(&:capitalize).join}Modifier".to_sym

    if RowModifiers.constants.include? class_name
      RowModifiers.const_get(class_name).new
    else
      nil
    end
  end
end

PgDumpParser.call(ARGF, STDOUT) if __FILE__ == $0
