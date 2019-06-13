require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require 'byebug'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res)
    @req=req
    @res=res
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    !!@already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    @res['Location'] = url
    @res.status = 302
    @session.store_session(@res)
    if already_built_response?
      raise "Can't render twice"
    else
      @already_built_response = @res
    end
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type = "text/html")
    #@res.body = content
    @res['Content-Type'] = content_type
    @res.write(content)
    @session.store_session(@res)
    if already_built_response?
      raise "Can't render twice"
    else
      @already_built_response = @res
    end
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    dirpath = File.expand_path(File.dirname(__FILE__))
    holder = dirpath.split('/')
    holder.pop
    @res['Content-Type'] = "text/html"
    str = self.class.name
    str = str.split('Controller')[0].downcase
    template_path = File.join(holder.join("/"),'views', "#{str}_controller", "#{template_name}.html.erb")
    returned_code = File.read(template_path)
    @res.write(ERB.new(returned_code).result(binding))
    @session.store_session(@res)
    if already_built_response?
      raise "Can't render twice"
    else
      @already_built_response = @res
    end
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
  end
end

  
 