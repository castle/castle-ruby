require 'spec_helper'
require 'timecop'

describe 'Userbin::JWT' do
  context 'valid JWT' do
    let(:jwt) { 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiIsImlhdCI6MTM5Nzg2NTU1MCwiZXhwIjoxMzk3ODY5MTUwfQ.eyJ1c2VyX2lkIjoiN1d2anBvMThtWWNTU3pEUHp6WFF2WmJIajdadzVEczEifQ.ht2YSVQQkOMuHn8XmdPDG0k-78CybZp26mn7Kkl6UgE' }

    it 'returns a payload' do
      payload = Userbin::JWT.new(jwt).to_json
      payload['user_id'].should == '7Wvjpo18mYcSSzDPzzXQvZbHj7Zw5Ds1'
    end

    it 'verifies that JWT has expired' do
      new_time = Time.utc(2014, 4, 19, 0, 59, 11)
      Timecop.freeze(new_time) do
        Userbin::JWT.new(jwt).expired?.should be_true
      end
    end

    it 'verifies that JWT has not expired' do
      new_time = Time.utc(2014, 4, 19, 0, 59, 10)
      Timecop.freeze(new_time) do
        Userbin::JWT.new(jwt).expired?.should be_false
      end
    end
  end

  context 'invalid JWT' do
    let(:jwt) { 'eyJ0eXhtWWNTU3pEUHp6WFF2WmZp26mn7Kkl6UgE' }

    it 'throws error on invalid JWT' do
      jwt = 'eyJ0eXhtWWNTU3pEUHp6WFF2WmZp26mn7Kkl6UgE'
      expect {
        payload = Userbin::JWT.new(jwt).to_json
      }.to raise_error(Userbin::SecurityError)
    end
  end

end
