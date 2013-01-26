cwd = File.dirname(__FILE__)

@DB=Sequel.sqlite

structure = File.open(File.join(cwd, 'test-structure.sql'), 'r').read
@DB.execute_ddl(structure)

contents = File.open(File.join(cwd, 'test-data.sql'), 'r').read
@DB.execute_dui(contents)

MEDIA_ROOT = 'http://u.r.l/media'
MEDIA_PATHS = {
  :one => 'path_one',
  :two => 'path_two',
  :three => 'path_three'
}
MEDIA_DIMENSIONS = {
  :one => 100,
  :two => 200,
  :three => nil
}


require 'gugg-web_api-collection-server'
