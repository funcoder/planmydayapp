import { Meteor } from 'meteor/meteor';
import { Accounts } from 'meteor/accounts';

Meteor.startup(() => {
  // Check if admin user exists
  const adminUser = Meteor.users.findOne({ 'emails.address': 'admin@example.com' });
  
  if (!adminUser) {
    // Create admin user if it doesn't exist
    const adminId = Accounts.createUser({
      email: 'admin@example.com',
      password: 'admin123', // You should change this in production
      profile: {
        role: 'admin'
      }
    });

    // Add admin role to the user
    Meteor.users.update(adminId, {
      $set: { 'profile.role': 'admin' }
    });

    console.log('Admin user created successfully');
  }
}); 