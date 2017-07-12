# frozen_string_literal: true

require 'spec_helper'

describe 'Castle::VERSION' do
  it 'have version' do
    expect(Castle::VERSION).to match(/\d\.\d\.\d/)
  end
end
