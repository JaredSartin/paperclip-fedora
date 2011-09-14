module Paperclip
  module Storage
    module Fedora
      class Railtie < Rails::Railtie
        rake_tasks do
          require "paperclip-fedora/rake"
        end
      end
    end
  end
end
