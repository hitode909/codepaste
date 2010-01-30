# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../models_helper'

describe Model::User do
  include Model
  before do
    @aliver = load("model/user__aliver")
    @diary = load("model/project__diary")
    @title = load("model/file__title")
    @hey = load("model/note__hey")
  end

  it 'has project class' do
    @diary.should be_an_instance_of Model::Project
  end
  it 'has name' do
    @diary.name.should == 'diary'
  end
  it 'has description' do
    @diary.description.should == 'My diary project'
  end
  it 'has user relation' do
    @diary.user.should == @aliver
  end

  it 'has files relations' do
    @diary.files.should == [@title]
  end
  it 'has notes relations' do
    @diary.notes.should == [@hey]
  end
end
