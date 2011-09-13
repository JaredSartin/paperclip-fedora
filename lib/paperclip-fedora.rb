require "paperclip-fedora/version"

module Paperclip
  module Storage
    module FedoraCommons
      def self.extended(base)
        require 'rubydora'
        base.instance_eval do
          if(!@options[:fedora_config])
            @options[:fedora_config] = Rails.root.to_s + "/config/paperclip_fedora.yml"
          end

          @fedora_config = parse_config(@options[:fedora_config])
          @url = @fedora_config[:host] + '/objects/:id/datastreams/:style/content'
          @path = ':id'
        end
      end

      def exists?(style=default_style)
        if exists?(style)
          !fedora_object.datastreams[style].new?
        else
          false
        end
      end

      def to_file(style=default_style)
        return @queued_for_write[style] if @queued_for_write[style]
        ds = fedora_object.datastreams[style]
        file = Tempfile.new([ds.label, style])
        file.binmode
        file.write(ds.file)
        file.rewind
        return file        
      end

      def flush_writes
        @queued_for_write.each do |style, file|
          ds = fedora_object.datastreams[style]
          ds.controlGroup = 'M'
          ds.file = file
          ds.dsLabel = file.basename
          ds.save
        end
        @queued_for_write = {}
      end

      def flush_deletes
        @queued_for_delete.each do |path|
          object = fedora.find(path)
          object.delete
        end
        @queued_for_delete = []
      end

      def fedora
        @@repo ||= Rubydora.connect url: @fedora_config[:host], user: @fedora_config[:user], password: @fedora_config[:password] 
        @@repo
      end
      
      def create_object
        object = fedora.find(@path)
        object.label = @path
        saved_object = object.save
        saved_object
      end

      def fedora_object
        @fedora_object ||= create_object
      end

      def parse_config config
        config = find_credentials(config).stringify_keys
        (config[Rails.env] || config).symbolize_keys
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
