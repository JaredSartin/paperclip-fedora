paperclip-fedora
================

Paperclip-Fedora uses Rubydora to extend the storage options of Paperclip to use Fedora Commons.

## Installation

To use, require the gem in your Gemfile:

`gem 'paperclip-fedora'`

To specify Fedora Commons as your storage location, add the storage option to your
has_attachment:

`has_attached_file :content, :storage => :Fedora`

## Usage

The Fedora Commons storage has very complex ways of connecting data. Currently in
paperclip-fedora there is no support for complex relationships. The upload creates
a data object with a datastream per style (such as thumbnails, image sizes, or
other that you specify, as well as the original upload).

## Todo

The object and datastream labels are currently static and not too pretty. Plans to 
make the object label the original filename and the datastreams follow a similar pattern.

## Copyright & Acknowledgements

Using Paperclip: https://github.com/thoughtbot/paperclip

Using Rubydora: https://github.com/cbeer/rubydora

Copyright (c) 2011 Jared Sartin. See LICENSE for
further details.

