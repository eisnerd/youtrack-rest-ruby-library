require File.expand_path("../../../spec_helper.rb", __FILE__)

describe YouTrackAPI::Connection do
  it 'should not use SSL for YouTrack installations without SSL' do
    YouTrackAPI::Connection.new("http://my.youtrack.install.tld").connection.should_not be_use_ssl
  end
  it 'should use SSL for YouTrack installations with SSL' do
    YouTrackAPI::Connection.new("https://my.youtrack.install.tld").connection.should be_use_ssl
  end
end
