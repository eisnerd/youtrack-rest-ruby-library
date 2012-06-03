require File.expand_path("../../../spec_helper.rb", __FILE__)

describe YouTrackAPI::Connection do
  it 'should not use SSL for YouTrack installations without SSL' do
    YouTrackAPI::Connection.new("http://my.youtrack.install.tld").connection.should_not be_use_ssl
  end

  it 'should use SSL for YouTrack installations with SSL' do
    YouTrackAPI::Connection.new("https://my.youtrack.install.tld").connection.should be_use_ssl
  end

  describe '#url_encode' do
    it 'should encode parameters correctly' do
      conn = YouTrackAPI::Connection.new("https://my.youtrack.install.tld")
      expected = "login=Jane%20Doe&password=It's%20actually%20a%20passphrase."
      conn.url_encode({ 'login' => 'Jane Doe', 'password' => "It's actually a passphrase." }).should == expected
    end
  end

  describe '#request' do
    describe 'with method_name == :post' do
      it 'should use POST data' do
        pending "Currently uses query params"
      end
    end
  end
end
