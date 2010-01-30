# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../models_helper'

describe Model::User do
  include Model
  before do
    @aliver = load("model/user__aliver")
    @zombie = load("model/user__zombie")
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
end
