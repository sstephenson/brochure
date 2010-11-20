module Brochure
  class Error     < ::StandardError; end
  class TemplateNotFound    < Error; end
  class CaptureNotSupported < Error; end
end
