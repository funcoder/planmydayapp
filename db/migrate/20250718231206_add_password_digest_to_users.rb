class AddPasswordDigestToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :password_digest, :string
    add_column :users, :email_address, :string
    add_index :users, :email_address, unique: true
    
    # Remove old Devise columns
    remove_column :users, :encrypted_password, :string if column_exists?(:users, :encrypted_password)
    remove_column :users, :reset_password_token, :string if column_exists?(:users, :reset_password_token)
    remove_column :users, :reset_password_sent_at, :datetime if column_exists?(:users, :reset_password_sent_at)
    remove_column :users, :remember_created_at, :datetime if column_exists?(:users, :remember_created_at)
    remove_column :users, :sign_in_count, :integer if column_exists?(:users, :sign_in_count)
    remove_column :users, :current_sign_in_at, :datetime if column_exists?(:users, :current_sign_in_at)
    remove_column :users, :last_sign_in_at, :datetime if column_exists?(:users, :last_sign_in_at)
    remove_column :users, :current_sign_in_ip, :string if column_exists?(:users, :current_sign_in_ip)
    remove_column :users, :last_sign_in_ip, :string if column_exists?(:users, :last_sign_in_ip)
    remove_column :users, :email, :string if column_exists?(:users, :email)
  end
end
