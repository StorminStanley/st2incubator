#!/usr/bin/env ruby
require 'yaml'
# Autogenerate Actions for ST2 and Freight

# Do not know how to model:
# * same parameter typed in multiple times
DEFAULT_DETAILS = {
  'runner_type' => 'run-remote',
  'enabled' => true,
  'entry_point' => '',
}

SOURCE_TYPES = ['dir', 'rpm', 'gem', 'python', 'empty', 'tar', 'deb']
OUTPUT_TYPES = ['deb', 'rpm']
DEFAULT_PARAMETERS = {
  'name' => {
    'type' => 'string',
    'description' => 'Package Name (e.g.: libpq)',
    'required' => true,
  },
  'source' => {
    'type' => 'string',
    'description' => 'Source type for fpm',
  },
  'output' => {
    'type' => 'string',
    'description' => 'Package output type for fpm',
  },
  'version' => {
    'type' => 'string',
    'description' => 'Package Versioni (e.g.: 0.1.1)',
    'required' => true,
  },
  'revision' => {
    'type' => 'string',
    'description' => 'Package Revision (e.g: 2)',
    'default' => '1',
    'required' => true,
  },
  'cmd' => {
    'default' => 'fpm -s {{source}} -t {{output}} -n {{name}} --version {{version}} --iteration {{revision}}',
    'immutable' => true,
  },
}

### These need to be re-added once https://github.com/StackStorm/st2/issues/887
### is resolved
OPTIONAL = {
  'description' => {
    'type' => 'string',
    'description' => 'Package Description (e.g.: Provides PostgreSQL Client libs)',
  },
  'maintainer' => {
    'type' => 'string',
    'description' => 'The maintainer of this package. (default: "<root@product-flashflirt.stage.office.airg.lan>")',
  },
  'c' => {
    'type' => 'string',
    'description' => '(chroot) Change directory to here before searching for files',
  },
  'prefix' => {
    'type' => 'string',
    'description' => "A path to prefix files with when building the target package. This may be necessary for all input packages. For example, the 'gem' type will prefix with your gem directory automatically.",
  },
}

SOURCE_TYPES.each do |source|
  OUTPUT_TYPES.each do |output|
    action_info = DEFAULT_DETAILS
    action_info['name'] = "create_#{output}_from_#{source}"
    action_info['description'] = "Create a #{output} package from #{source} with fpm"
    action_info['parameters'] = DEFAULT_PARAMETERS
    action_info['parameters']['source']['default'] = source
    action_info['parameters']['output']['default'] = output

    File.open("#{action_info['name']}.yaml", 'w') { |file| file.write(action_info.to_yaml) }
  end
end
