require_relative 'test_helper'

class TestPgDumpParser < Minitest::Test
  def test_process_no_changes
    in_text = "one\ntwo\n"
    out = StringIO.new
    PgDumpParser.call StringIO.new(in_text), out

    assert_equal in_text, out.string
  end

  def test_process_builtin_modifiers
    inio = StringIO.new <<EOF
COPY users (id, email_address, status, name, company_name, job_title, phone_number, failed_login_attempt_count) FROM stdin;
10\tsupplier@example.com\tENABLED\tSupplier User\tSupplier\t1235552222\t3
EOF
    expected_out = <<EOF
COPY users (id, email_address, status, name, company_name, job_title, phone_number, failed_login_attempt_count) FROM stdin;
10\tuser-1@nologin\tDISABLED\tUser 1\tCompany for User 1\tTitle for User 1\t0000000001\t0
EOF
    outio = StringIO.new

    PgDumpParser.call inio, outio

    assert_equal expected_out, outio.string
  end

  def test_process_no_modifier_for_found_table
    text = "--Comment\n\nCOPY test_table (col1, col2) FROM stdin;\n123\tABC\n\\.\n"
    out = StringIO.new
    PgDumpParser.call StringIO.new(text), out

    assert_equal text, out.string
  end
  
  def test_process_colname_with_quotes
    in_text = <<EOF
COPY log (id, "timestamp", user_id, action, metadata) FROM stdin;
3 2017-11-22 15:08:24.316 1 LOGGED_IN { "userName": "Some User", "userEmail": "Some.User@example.com" }
EOF
    out = StringIO.new
    PgDumpParser.call StringIO.new(in_text), out

    assert_equal in_text, out.string
  end
end
