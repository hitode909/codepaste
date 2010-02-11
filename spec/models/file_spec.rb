# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../models_helper'

describe Model::File do
  include Model
  before do
    @aliver = load("model/user__aliver")
    @title = load("model/file__title")
  end

  it 'has file class' do
    @title.should be_an_instance_of Model::File
  end
  it 'has name' do
    @title.name.should == 'title.txt'
  end
  it 'has body' do
    @title.body.should == 'Diary 2007'
  end
  it 'has user relation' do
    @title.user.should == @aliver
  end
end
