class AddUserAgreementAcceptedOn < ActiveRecord::Migration
  def self.up
    add_column :users, :user_agreement_accepted_on, :datetime, :null => true
    User.reset_column_information

    execute('update users set user_agreement_accepted_on = now() where user_agreement_accepted_on is null');
    change_column :users, :user_agreement_accepted_on, :datetime, :null => false
  end

  def self.down
    remove_column :users, :user_agreement_accepted_on
  end
end
