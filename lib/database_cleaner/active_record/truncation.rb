require "database_cleaner/truncation_base"

module ActiveRecord
  module ConnectionAdapters

    class MysqlAdapter
      def can_truncate_multiple?
        false
      end
      def truncate_table(table_name)
        execute("TRUNCATE TABLE #{quote_table_name(table_name)};")
      end
    end

    class SQLite3Adapter
      def can_truncate_multiple?
        false
      end
      def truncate_table(table_name)
        execute("DELETE FROM #{quote_table_name(table_name)};")
      end
    end

    class JdbcAdapter
      def can_truncate_multiple?
        false
      end
      def truncate_table(table_name)
        execute("TRUNCATE TABLE #{quote_table_name(table_name)};")
      end
    end

    class PostgreSQLAdapter
      def can_truncate_multiple?
        true
      end
      def truncate_table(tables)
        tables=[tables].flatten.map{|t| quote_table_name(t)}.join(',')
        execute("TRUNCATE TABLE #{tables};")
      end
    end

    class SQLServerAdapter
      def can_truncate_multiple?
        false
      end
      def truncate_table(table_name)
        execute("TRUNCATE TABLE #{quote_table_name(table_name)};")
      end
    end

  end
end


module DatabaseCleaner::ActiveRecord
  class Truncation < ::DatabaseCleaner::TruncationBase

    def clean
      connection.disable_referential_integrity do
        if connection.can_truncate_multiple?
          connection.truncate_table tables_to_truncate
        else
          tables_to_truncate.each do |table_name|
            connection.truncate_table table_name
          end
        end
      end
    end

    private

    def tables_to_truncate
      (@only || connection.tables) - @tables_to_exclude
    end

    def connection
      ::ActiveRecord::Base.connection
    end

    # overwritten
    def migration_storage_name
      'schema_migrations'
    end

  end
end


