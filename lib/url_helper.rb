module UrlHelper
  def truncate_text(txt, len)
    txt = "#{txt[0, len]}..." if txt.length > len
    txt
  end

  def absolute_path(options)
    "#{APP_CONFIG[CONFIG_PROTOCOL]}://#{APP_CONFIG[CONFIG_HOST]}:#{APP_CONFIG[CONFIG_PORT]}#{url_for(options.merge({:only_path => true, :skip_relative_url_root => true}))}"
  end
end