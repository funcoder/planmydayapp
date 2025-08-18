import { Template } from 'meteor/templating';
import { ReactiveVar } from 'meteor/reactive-var';
import { Meteor } from 'meteor/meteor';

import './main.html';
import './main.css';

interface HelloTemplateInstance extends Blaze.TemplateInstance {
  counter: ReactiveVar<number>;
}

interface CustomUserProfile extends Meteor.UserProfile {
  role?: string;
}

// Add authentication helpers
Template.registerHelper('currentUser', () => {
  return Meteor.user();
});

Template.registerHelper('isAdmin', () => {
  const user = Meteor.user();
  return user && (user.profile as CustomUserProfile).role === 'admin';
});

// Add logout event handler
Template.body.events({
  'click .logout-btn'() {
    Meteor.logout();
  }
});

Template.hello.onCreated(function helloOnCreated(this: HelloTemplateInstance) {
  // counter starts at 0
  this.counter = new ReactiveVar(0);
});

Template.hello.helpers({
  counter() {
    return (Template.instance() as HelloTemplateInstance).counter.get();
  },
});

Template.hello.events({
  'click button'(event, instance: HelloTemplateInstance) {
    // increment the counter when button is clicked
    instance.counter.set(instance.counter.get() + 1);
  },
});
