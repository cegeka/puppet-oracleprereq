#!/usr/bin/env rspec

require 'spec_helper'

describe 'oracleprereq' do
  let(:pre_condition) { "define limits::conf($domain, $type, $item, $value) {}" "class limits {}" }
  let(:facts) { { :architecture => 'i386' } }
  #let(:pre_condition) { "class limits {}" }
  it { should contain_class 'oracleprereq' }
end
