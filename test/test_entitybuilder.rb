require_relative 'test_helper'

class TestEntityBuilder < Minitest::Test
  def test_entity_builder_populates_values
    copy_line = %w[col1 col2]
    row_line = "123\t456"
    row = EntityBuilder.new(copy_line).build(row_line)

    assert_equal "123", row.col1
    assert_equal "456", row.col2
  end

  def test_entity_builder_populates_nulls
    copy_line = %w[col1 col2]
    row_line = "123\t\\N\t789"
    row = EntityBuilder.new(copy_line).build(row_line)

    assert_nil row.col2
  end

  def test_entity_to_string
    copy_line = %w[col1 col2 col3]
    row_line = "123\t456\t789"
    row = EntityBuilder.new(copy_line).build(row_line)

    row.col2 = 'ABC'

    assert_equal "123\tABC\t789", row.string
  end

  def test_entity_to_string_with_nil
    copy_line = %w[col1 col2 col3]
    row_line = "123\t456\t789"
    row = EntityBuilder.new(copy_line).build(row_line)

    row.col2 = nil

    assert_equal "123\t\\N\t789", row.string
  end

  def test_entity_to_string_with_true
    copy_line = %w[col1 col2 col3]
    row_line = "123\t456\t789"
    row = EntityBuilder.new(copy_line).build(row_line)

    row.col2 = true

    assert_equal "123\tt\t789", row.string
  end

  def test_entity_to_string_with_false
    copy_line = %w[col1 col2 col3]
    row_line = "123\t456\t789"
    row = EntityBuilder.new(copy_line).build(row_line)

    row.col2 = false

    assert_equal "123\tf\t789", row.string
  end

  def test_entity_to_string_with_integer
    copy_line = %w[col1 col2 col3]
    row_line = "123\t456\t789"
    row = EntityBuilder.new(copy_line).build(row_line)

    row.col2 = 100

    assert_equal "123\t100\t789", row.string
  end

  def test_entity_to_string_with_float
    copy_line = %w[col1 col2 col3]
    row_line = "123\t456\t789"
    row = EntityBuilder.new(copy_line).build(row_line)

    row.col2 = 100.00

    assert_equal "123\t100.0\t789", row.string
  end
end
