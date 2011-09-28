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
          @host = @fedora_config[:host]
          @port = @fedora_config[:port]
          @context = @fedora_config[:context]
          @custom_namespace = @options[:fedora_pid]

          @server_url = "http\://#{@host}\:#{@port}/#{@context}"
          @object_id = instance.uuid || @custom_pid || path()
          @path = @object_id
          @url = "#{@server_url}/objects/#{@path}/datastreams/:style/content"

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
        @object_id = instance.uuid || @custom_pid || path()
        @path = @object_id
        @url = "#{@server_url}/objects/#{@path}/datastreams/:style/content"
        ps = fedora_object.datastreams['paperclip_styles']
        style_list = ps.content
        @queued_for_write.each do |style, file|
          style_list = "#{style_list.strip} #{style.to_s}"
          ds = fedora_object.datastreams[style.to_s]
          ds.controlGroup = 'M'
          ds.file = file
          ds.dsLabel = "Paperclip: #{File.extname(file)} file"
          ds.save
          log("Added #{style} datastream to #{@object_id}")
        end
        ps.content = style_list.strip
        ps.save
        @queued_for_write = {}
      end

      def flush_deletes
        @queued_for_delete.uniq!
        @queued_for_delete.each do |path|
          object = fedora.find(path)
          pso = object.datastreams['paperclip_styles']
          ps = pso.content
          ps.split(' ').each do |style|
            ds = object.datastreams[style]
            ds.delete
            log("Deleted #{path} - #{style} stream")
          end
          pso.content = " "
          pso.save
        end
        @queued_for_delete = []
      end

      def fedora
        @@repo ||= Rubydora.connect url: @server_url, user: @fedora_config[:user], password: @fedora_config[:password] 
        @@repo
      end
      
      def fedora_object
        @object_id = instance.uuid || @custom_pid || path()
        @path = @object_id
        @url = "#{@server_url}/objects/#{@path}/datastreams/:style/content"
        object = fedora.find(@object_id)
        object.label = @object_id
        saved_object = object.save
        paperclip_styles = object.datastreams['paperclip_styles']
        if paperclip_styles.new?
          paperclip_styles.controlGroup = 'M'
          paperclip_styles.dsLabel = "Paperclip styles - Used for deletion tracking"
          paperclip_styles.content = " "
          paperclip_styles.mimeType = "text/plain"
          paperclip_styles.save
        end
        saved_object
      end

      def parse_config config
        config = find_credentials(config).stringify_keys
        (config[Rails.env] || config).symbolize_keys
      end

      def setup!
        FileUtils.cp(File.dirname(__FILE__) + "/../config/fedora.yml", config_file) unless config?
      end

      def config_file
        Rails.root.join("config", "fedora.yml").to_s
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
