# 
# To change this template, choose Tools | Templates
# and open the template in the editor.


module SessionCleaner
  def self.clean
    SessionCleaner.execute_sql "DELETE FROM sessions WHERE created_at < '#{2.day.ago.to_s(:db)}'"
  end

  # Session expiration as described in http://guides.rubyonrails.org/security.html section 2.9
  def self.sweep
    SessionCleaner.execute_sql "DELETE FROM sessions WHERE updated_at < '#{30.minute.ago.to_s(:db)}'"
  end

  private

  def self.execute_sql sql_stmt
    sql = ActiveRecord::Base.connection();
    sql.execute "SET autocommit=0";
    sql.begin_db_transaction
    sql.update sql_stmt;
    sql.commit_db_transaction
  end
end
