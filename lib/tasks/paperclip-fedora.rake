namespace :paperclip do
  namespace :fedora do
    desc "Copy the default configuration to the config folder"
    task :setup => :environment do
      Paperclip::Storage::Fedora.setup!
    end
  end
end
