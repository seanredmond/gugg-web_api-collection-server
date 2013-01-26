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

# Set up exhibitions, one past, one current, one future
today = Date.today
pastex = @DB[:collection_tms_exhibitions].where(:exhibitionid => 1)
currentex = @DB[:collection_tms_exhibitions].where(:exhibitionid => 2)
futureex = @DB[:collection_tms_exhibitions].where(:exhibitionid => 3)

pastex.update(:beginisodate => today - 365, :endisodate => today - 360)
currentex.update(:beginisodate => today - 30, :endisodate => today + 30)
futureex.update(:beginisodate => today + 305, :endisodate => today + 365)

require 'gugg-web_api-collection-server'
