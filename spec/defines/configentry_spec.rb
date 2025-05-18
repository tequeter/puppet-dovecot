require 'spec_helper'

describe 'dovecot::configentry' do
  let(:pre_condition) do
    <<-EOS
      class { 'dovecot':
        package_name        => ['dovecot-core'],
        poolmon_config_file => 'foo',
      }
    EOS
  end
  let(:title) { 'foo' }
  let(:default_params) do
    {
      'file'    => '/dovecot.conf',
      'key'     => 'foo',
      'value'   => 'bar',
      'comment' => 'Comment.'
    }
  end

  context 'with key=dovecot_config_version' do
    let(:params) do default_params.merge({ 'key' => 'dovecot_config_version' }) end

    it 'is output at the top of the config file' do
      is_expected.to contain_concat__fragment('dovecot /dovecot.conf config / 01 dovecot_config_version 01 comment')
      is_expected.to contain_concat__fragment('dovecot /dovecot.conf config / 01 dovecot_config_version 02')
    end
  end

  context 'with a top-level key' do
    let(:params) do default_params.merge({ 'key' => 'foo' }) end

    it 'gets ordered second' do
      is_expected.to contain_concat__fragment('dovecot /dovecot.conf config / 02 foo 01 comment')
      is_expected.to contain_concat__fragment('dovecot /dovecot.conf config / 02 foo 02')
    end
  end

  context 'with a key under a section' do
    let(:params) do default_params.merge({ 'key' => 'foo', 'sections' => ['s1'] }) end

    it 'gets ordered next' do
      is_expected.to contain_concat__fragment('dovecot /dovecot.conf config / 03 s1 01 section start')
      is_expected.to contain_concat__fragment('dovecot /dovecot.conf config / 03 s1 02 foo 01 comment')
      is_expected.to contain_concat__fragment('dovecot /dovecot.conf config / 03 s1 02 foo 02')
      is_expected.to contain_concat__fragment('dovecot /dovecot.conf config / 03 s1 05 section end')
    end
  end

  context 'with an !include' do
    let(:params) do default_params.merge({ 'key' => '!include' }) end

    it 'gets ordered last' do
      is_expected.to contain_concat__fragment('dovecot /dovecot.conf config / 04 !include bar')
    end

    it 'keeps the comment next to it' do
      pending('comments on !include are currently not supported')
      is_expected.not_to contain_concat__fragment('dovecot /dovecot.conf config / 02 !include 01 comment')
      is_expected.to     contain_concat__fragment('dovecot /dovecot.conf config / 04 !include bar comment')
    end
  end
end
