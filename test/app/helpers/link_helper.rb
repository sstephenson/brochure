module LinkHelper
  def link_to(title, url)
    "<a href=\"#{url}\">#{title}</a>"
  end
end
