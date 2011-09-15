paperclip-fedora
================

Paperclip-Fedora uses Rubydora to extend the storage options of Paperclip to use Fedora Commons.

## Installation

To use, require the gem in your Gemfile:

`gem 'paperclip-fedora'`

To specify Fedora Commons as your storage location, add the storage option to your
has_attachment:

`has_attached_file :content, :storage => :Fedora`

For server connection options, you should have a file titled paperclip-fedora.yml in your
/config folder. There is a nifty rake task to put the yaml file there for you:

`rake paperclip:fedora:setup`

After that, go edit the yaml file with your server settings per rails environment (They default to a server on the localhost).

## Overview

The Fedora Commons storage has very complex ways of connecting data. Currently in
paperclip-fedora there is no support for complex relationships. The upload creates
a data object with a datastream per style (such as thumbnails, image sizes, or
other that you specify), as well as the original upload.

## Todo

More features?

## Copyright & Acknowledgements

Using Paperclip: https://github.com/thoughtbot/paperclip

Using Rubydora: https://github.com/cbeer/rubydora
