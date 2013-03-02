#!/usr/bin/env rspec

require 'spec_helper'

describe 'oracleprereq' do
  let(:pre_condition) { "define limits::conf($domain, $type, $item, $value) {}" "class limits {}" }
  let(:facts) { { :architecture => 'i386', :hardwaremodel => 'i686', :operatingsystemrelease => '5.8', :memorysize => '4 GB', :pagesize => '4096'} }
  it { should contain_class 'oracleprereq' }
end
