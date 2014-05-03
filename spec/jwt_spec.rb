require 'spec_helper'
require 'timecop'

describe 'Userbin::JWT' do
  let(:token) { 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiIsImlhdCI6MTM5ODIzOTIwMywiZXhwIjoxMzk4MjQyODAzfQ.eyJ1c2VyX2lkIjoiZUF3djVIdGRiU2s4Yk1OWVpvanNZdW13UXlLcFhxS3IifQ.Apa7EmT5T1sOYz4Af0ERTDzcnUvSalailNJbejZ2ddQ' }

  context 'valid JWT' do
    it 'returns a payload' do
      payload = Userbin::JWT.new(token).to_json
      payload['user_id'].should == 'eAwv5HtdbSk8bMNYZojsYumwQyKpXqKr'
    end

    it 'verifies that JWT has expired' do
      new_time = Time.utc(2014, 4, 23, 8, 46, 44)
      Timecop.freeze(new_time) do
        Userbin::JWT.new(token).expired?.should be_true
      end
    end

    it 'verifies that JWT has not expired' do
      new_time = Time.utc(2014, 4, 23, 8, 46, 43)
      Timecop.freeze(new_time) do
        Userbin::JWT.new(token).expired?.should be_false
      end
    end
  end

  context 'invalid JWT' do
    let(:token) { 'eyJ0eXhtWWNTU3pEUHp6WFF2WmZp26mn7Kkl6UgE' }

    it 'throws error' do
      expect {
        payload = Userbin::JWT.new(token).to_json
      }.to raise_error(Userbin::SecurityError)
    end
  end

  context 'nil JWT' do
    let(:token) { nil }

    it 'throws error' do
      token = nil
      expect {
        payload = Userbin::JWT.new(token).to_json
      }.to raise_error(Userbin::SecurityError)
    end
  end

end
