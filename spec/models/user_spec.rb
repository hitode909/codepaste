# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../models_helper'

describe Model::User do
  include Model
  before do
    @aliver = load("model/user__aliver")
    @zombie = load("model/user__zombie")
    @diary = load("model/project__diary")
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

  it 'has projects relations' do
    @aliver.projects.should == [@diary]
  end

  it 'has files relations' do
    @aliver.files.should == [@title]
  end
  it 'has notes relations' do
    @aliver.notes.should == [@hey]
  end
end
