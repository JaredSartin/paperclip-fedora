require "paperclip-fedora/version"
require "paperclip-fedora/railtie" if Rails.version >= "3.0"
require "FileUtils" unless defined?(FileUtils)

module Paperclip
  module Storage
    module Fedora
      extend self
      def self.extended(base)
        require 'rubydora'
        base.instance_eval do
          if(!@options[:fedora_config])
            @options[:fedora_config] = config_file
          end

          @fedora_config = parse_config(@options[:fedora_config])
          @path = ":basename_clean\::id"
          @url = @fedora_config[:host] + "/objects/#{@path}/datastreams/:style/content"
          
          Paperclip.interpolates(:basename_clean) do |attachment, style|
            s = File.basename(attachment.original_filename, File.extname(attachment.original_filename))
            s.downcase!
            s.gsub!(/'/, '')
            s.gsub!(/[^A-Za-z0-9:\-]+/, ' ')
            s.strip!
            s.gsub!(/\ +/, '-')
            s
          end unless Paperclip::Interpolations.respond_to? :basename_clean
        end
      end

      def exists?(style=default_style)
        exists_bool = !fedora_object.datastreams[style.to_s].new?
        exists_bool
      end

      def to_file(style=default_style)
        return @queued_for_write[style.to_s] if @queued_for_write[style.to_s]
        ds = fedora_object.datastreams[style.to_s]
        file = Tempfile.new([ds.label, style.to_s])
        file.binmode
        file.write(ds.file)
        file.rewind
        return file        
      end

      def flush_writes
        @queued_for_write.each do |style, file|
          ds = fedora_object.datastreams[style.to_s]
          ds.controlGroup = 'M'
          ds.file = file
          ds.dsLabel = "#{File.extname(file)} file"
          ds.save
          log("Added #{style} datastream to #{@object_id}")
        end
        @queued_for_write = {}
      end

      def flush_deletes
        @queued_for_delete.uniq!
        @queued_for_delete.each do |path|
          object = fedora.find(path)
          object.delete if !object.new?
          log("Deleted #{path}")
        end
        @queued_for_delete = []
      end

      def fedora
        @@repo ||= Rubydora.connect url: @fedora_config[:host], user: @fedora_config[:user], password: @fedora_config[:password] 
        @@repo
      end
      
      def fedora_object
        @object_id = path()
        object = fedora.find(@object_id)
        object.label = @object_id
        saved_object = object.save
        saved_object
      end

      def parse_config config
        config = find_credentials(config).stringify_keys
        (config[Rails.env] || config).symbolize_keys
      end

      def setup!
        FileUtils.cp(File.dirname(__FILE__) + "/../config/paperclip_fedora.yml", config_file) unless config?
      end

      def config_file
        Rails.root.join("config", "paperclip_fedora.yml").to_s
      end
      
      def config?
        File.file? config_file
      end

      private

      def find_credentials config
        case config
          when File
            YAML.load_file(config.path)
          when String
            YAML.load_file(config)
          when Hash
            config
          else
            raise ArgumentError, "Configuration settings are not a path, file, or hash."
        end
      end

    end
  end
end
