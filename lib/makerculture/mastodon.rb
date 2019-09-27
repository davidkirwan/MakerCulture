require "mastodon"

module Makerculture
  module Mammoth
  class << self 
    attr_accessor :client, :token

    def setup(token)
      @token = token
      @client = Mastodon::REST::Client.new(base_url: 'https://gab.com', bearer_token: token)
    end

    def post(status, group)
      begin
        account = @client.verify_credentials
        #puts account.id
        #puts account.username

        post = @client.create_status(status, {:group_id=>group})

        post.url
      rescue Exception => e
        raise e
      end
    end

  end
  end
end
