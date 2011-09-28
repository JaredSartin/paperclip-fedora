paperclip-fedora
================

Paperclip-Fedora uses Rubydora to extend the storage options of Paperclip to use Fedora Commons.

## Installation

To use, require the gem in your Gemfile:

`gem 'paperclip-fedora'`

To specify Fedora Commons as your storage location, add the storage option to your
has_attachment:

`has_attached_file :content, :storage => :Fedora`

You can set your own pid for the object by specifying it in the has_attached file of your model as well, such as:

`has_attached_file :content, :storage => :Fedora, :fedora_pid => self.uuid`

or have uuid on your model this is getting added to. If uuid is present on the model, this will be the Fedora object id.

(Note, if the pid is static, all of your uploads will continually overwrite each other. Make sure to generate them in the form of
NAMESPACE:ID - for valid PID naming see https://wiki.duraspace.org/display/FEDORA35/Fedora+Identifiers#FedoraIdentifiers-PIDs )

For server connection options, you should have a file titled fedora.yml in your
/config folder. There is a nifty rake task to put the yaml file there for you:

`rake paperclip:fedora:setup`

After that, go edit the yaml file with your server settings per rails environment (They default to a Fedora Commons server on the localhost).
The settings will reflect the default Fedora Commons settings: host (in form localhost or example.com), port, and context (Fedora Commons context,
based on your Fedora Commons setup).

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
