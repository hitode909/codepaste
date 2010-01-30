# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../models_helper'

describe Model::File do
  include Model
  before do
    @aliver = load("model/user__aliver")
    @diary = load("model/project__diary")
    @title = load("model/file__title")
    @hey = load("model/note__hey")
  end

  it 'has note class' do
    @hey.should be_an_instance_of Model::Note
  end
  it 'has name' do
    @hey.name.should == 'hey'
  end
  it 'has body' do
    @hey.body.should == 'This file is cool.'
  end
  it 'has user relation' do
    @hey.user.should == @aliver
  end
  it 'has project relation' do
    @hey.project.should == @diary
  end
  it 'has file relation' do
    @hey.file.should == @title
  end
end
