require 'json'
require 'byebug'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  attr_reader :session
  def initialize(req)
    if !req.cookies.empty?
      @session = JSON.parse(req.cookies["_rails_lite_app"])
    else
      @session = {}
    end
  end

  def [](key)
    @session[key]
  end

  def []=(key, val)
    @session[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    # debugger
      res.set_cookie("_rails_lite_app", @session.to_json)
  end
end
