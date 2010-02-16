# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../models_helper'

describe Model::User do
  include Model
  before do
    @aliver = load("model/user__aliver")
    @zombie = load("model/user__zombie")
    @adminkun = load("model/user__adminkun")
    @title = load("model/file__title")
    @hey = load("model/note__hey")
  end

  it 'has user class' do
    @aliver.should be_an_instance_of Model::User
  end
  it 'has name' do
    @aliver.name.should == 'aliver'
    @zombie.name.should == 'zombie'
  end
  it 'has password' do
    @aliver.password.should == 'all'
    @zombie.password.should == 'zoo'
  end
  it 'may has profile' do
    @aliver.profile.should == 'from Brasil.'
    @zombie.profile.should be_nil
  end

  it 'has is_alive' do
    @aliver.is_alive.should be_true
    @zombie.is_alive.should be_false
  end

  it 'has is_admin' do
    @aliver.is_admin.should be_false
    @adminkun.is_admin.should be_true
  end

  it 'has files relations' do
    @aliver.files.should == [@title]
  end
  it 'has notes relations' do
    @aliver.notes.should == [@hey]
  end

  it 'provides register method' do
    j = Model::User.register('jjj', 'kkk')
    j.should be_kind_of Model::User
    j.name.should == 'jjj'
    j.password.should == 'kkk'
  end

  it 'cannot create same name users' do
    a = Model::User.register('aaa', 'aaa')
    a.should be_kind_of Model::User
    lambda{
      Model::User.register('aaa', 'aaa')
    }.should raise_error
  end

  it 'rejects empty name or password' do
    lambda{
      Model::User.register('', '')
    }.should raise_error

    lambda{
      Model::User.register('ok', '')
    }.should raise_error

    lambda{
      Model::User.register('', 'ok')
    }.should raise_error
  end

  it 'provides login method' do
    a = Model::User.register('aaa', 'aaa')
    a2 = Model::User.login('aaa', 'aaa')
    a2.should be_kind_of Model::User
  end

  it 'will reject login with wrong password' do
    who = Model::User.login('aliver', 'aaaaaaa')
    who.should be_nil
  end

  it 'will reject login of not exist user' do
    who = Model::User.login('abcdefg', 'abcdefg')
    who.should be_nil
  end

  it 'has (common) path method' do
    @aliver.path.should  == '/user/1'
    @aliver.path('hello').should  == '/user/1.hello'
  end
end
