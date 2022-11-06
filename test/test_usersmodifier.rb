require_relative 'test_helper'

class TestUsersModifier < Minitest::Test
  def test_changes_email_address
    copy_line = 'COPY users (id, email_address, status, name, company_name, job_title, phone_number, failed_login_attempt_count) FROM stdin;'
    row_line = "10\tcustomer@example.com\tENABLED\tCustomer User\tSupplier\t1235552222\t0"

    row = EntityBuilder.new(columns).build(row_line)
    RowModifiers::UsersModifier.new.call row

    email_address = row.string.split(/\t/)[1]

    assert_equal 'user-1@nologin', email_address
  end

  def test_disables_users
    copy_line = 'COPY users (id, email_address, status, name, company_name, job_title, phone_number, failed_login_attempt_count) FROM stdin;'
    row_line = "10\tcustomer@example.com\tENABLED\tCustomer User\tSupplier\t1235552222\t0"

    row = EntityBuilder.new(columns).build(row_line)
    RowModifiers::UsersModifier.new.call row

    status = row.string.split(/\t/)[2]

    assert_equal 'DISABLED', status
  end

  def test_changes_name
    copy_line = 'COPY users (id, email_address, status, name, company_name, job_title, phone_number, failed_login_attempt_count) FROM stdin;'
    row_line = "10\tcustomer@example.com\tENABLED\tCustomer User\tSupplier\t1235552222\t0"

    row = EntityBuilder.new(columns).build(row_line)
    RowModifiers::UsersModifier.new.call row

    name = row.string.split(/\t/)[3]

    assert_equal 'User 1', name
  end

  def test_changes_company_name
    copy_line = 'COPY users (id, email_address, status, name, company_name, job_title, phone_number, failed_login_attempt_count) FROM stdin;'
    row_line = "10\tcustomer@example.com\tENABLED\tCustomer User\tSupplier\t1235552222\t0"

    row = EntityBuilder.new(columns).build(row_line)
    RowModifiers::UsersModifier.new.call row

    company_name = row.string.split(/\t/)[4]

    assert_equal 'Company for User 1', company_name
  end

  def test_changes_job_title
    copy_line = 'COPY users (id, email_address, status, name, company_name, job_title, phone_number, failed_login_attempt_count) FROM stdin;'
    row_line = "10\tcustomer@example.com\tENABLED\tCustomer User\tCustomer\t1235552222\t0"

    row = EntityBuilder.new(columns).build(row_line)
    RowModifiers::UsersModifier.new.call row

    job_title = row.string.split(/\t/)[5]

    assert_equal 'Title for User 1', job_title
  end

  def test_changes_phone_number
    copy_line = 'COPY users (id, email_address, status, name, company_name, job_title, phone_number, failed_login_attempt_count) FROM stdin;'
    row_line = "10\tcustomer@example.com\tENABLED\tCustomer User\tSupplier\t1235552222\t0"

    row = EntityBuilder.new(columns).build(row_line)
    RowModifiers::UsersModifier.new.call row

    phone_number = row.string.split(/\t/)[6]

    assert_equal '0000000001', phone_number
  end

  def test_reset_failed_login_attempt_count
    copy_line = 'COPY users (id, email_address, status, name, company_name, job_title, phone_number, failed_login_attempt_count) FROM stdin;'
    row_line = "10\tcustomer@example.com\tENABLED\tCustomer User\tSupplier\t1235552222\t3"

    row = EntityBuilder.new(columns).build(row_line)
    RowModifiers::UsersModifier.new.call row

    failed_login_attempt_count = row.string.split(/\t/)[7]

    assert_equal "0", failed_login_attempt_count
  end

  def test_reset_skip_system_user
    copy_line = 'COPY users (id, email_address, status, name, company_name, job_title, phone_number, failed_login_attempt_count) FROM stdin;'
    row_line = "0\tsystem@thisapp.com\tENABLED\tSystem User\tMy Company\tSystem User\t1235552222\t3"

    row = EntityBuilder.new(columns).build(row_line)
    RowModifiers::UsersModifier.new.call row

    assert_equal row_line, row.string
  end

  private

  def columns
    %w[id email_address status name company_name job_title phone_number failed_login_attempt_count]
  end
end
