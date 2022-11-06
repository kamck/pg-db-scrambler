pg-db-scrambler
================

Usage
--------

	$> ruby pg_db_scrambler.rb input.sql > output.sql


Dependencies
--------------------

There are currently no required external gems.


Input
--------
The input SQL is a file taken from the output of `pg_dump`. The below snippet will produce a backup script that cleans the existing objects before creating and populating new ones.

	pg_dump -f db_clean.sql --clean \
        -T "pg_*" \
        -U database_user \
        -h localhost old_database

Output
---------
The output from `pg_db_scrambler.rb` can then be imported into the target database.
>**Note**
>It is advisable to run the output script as the application user to retain permissions unless you plan to update permissions after the import has completed.

	psql -f db_clean.sql -U database_user \
		-h localhost new_database

Tests
--------
All tests can be run by using the following

	$> ruby test/ts.rb

You can also run an individual test class in the same way. If you add a test, ensure to include it in `ts.rb`.

Adding Modifiers
-------------------
Modifiers are classes that change the data of a table's row. They can be used to replace sensitive data or enter a `NULL` into a column.

A modifier can be added by declaring a class in the `RowModifiers` namespace. The modifier's name must be the name of the table in camel case followed by "Modifier". For example, the following declares a modifier for the `CUSTOMERS` table

	
	module RowModifiers
	  class CustomersModifier
	  end
	end


The modifier class must define a method named `call` that takes one parameter. This parameter is the row to be modified. A column can be changed by referencing the column's name. For example, the following changes the `ORDER_TYPE` column in the `CUSTOMERS` table
	
	class CustomersModifier
	  def call(row)
	    row.order_type = 'EXPRESS'
	  end
	end
	
The `row` variable will be prepopulated with the current row's values from the input script. This allows you to conditionally change data.

	class UsersModifier
	  def process(row)
	    if row.email_address != 'admin@example.com'
	      row.name = 'New Name'
		end
	  end
    end
	
Prepopulated values will always be strings, except `NULL`s which will be populated with `nil`.

On output, `true`, `false`, and `nil` values will be translated to their PostgreSQL values. All other values will rely on their `to_str` or `to_s` implementations.

	class SampleTableModifier
	  def process(row)
		row.column1 = 'Person A'
		row.column2 = true
		row.column3 = 100
		row.column4 = nil
	  end
	end
	
will produce

	Person A	t	100	\N
