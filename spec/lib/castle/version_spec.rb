# frozen_string_literal: true

require 'spec_helper'

describe Castle do
  it 'have version' do
    expect(described_class::VERSION).to match(/\d\.\d\.\d/)
  end
end
