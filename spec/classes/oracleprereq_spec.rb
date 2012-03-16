#!/usr/bin/env rspec

require 'spec_helper'

describe 'oracleprereq' do
  let(:pre_condition) { "class limits {}" }
  let(:pre_condition) { "define limits::conf($domain, $type, $item, $value) {}" }
  it { should contain_class 'oracleprereq' }
end
