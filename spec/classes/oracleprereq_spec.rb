#!/usr/bin/env rspec

require 'spec_helper'

describe 'oracleprereq' do
  let(:pre_condition) { "define limits::conf($domain, $type, $item, $value) {}" "class limits {}" }
  let(:facts) { { :architecture => 'i386', :hardwaremodel => 'i686', :operatingsystemrelease => '6.2' } }
  it { should contain_class 'oracleprereq' }
end
