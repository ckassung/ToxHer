# Toxher

## Installation

### Install Catalyst

`$ cpanm install Catalyst::Runtime`
`$ cpanm install Catalyst::Devel`
`$ cpanm install Catalyst::View::TT`

### Install Database

Use the following command to build a toxher.db SQLite database:

`$ sqlite3 toxher.db < schema.sql`

Before eventually using this command again delete toxher.db. Then run 

`$ ./script/toxher_create.pl model DB DBIC::Schema ToxHer::Schema create=static naming=current use_namespaces=1 dbi:SQLite:toxher.db on_connect_do="PRAGMA foreign_keys = ON"`

for generating/updating result classes. The toxher.db database file must be in
the app's topmost directory. To test the application, then run

`$ script/toxher_server.pl -r`

## Database

```mermaid
---
title: Toxher DB schema
---
classDiagram
  class location {
    -id: INTEGER PRIMARY KEY
    -adress: TEXT
    -longitude: FLOAT
    -latitude: FLOAT
  }
  class event {
    -id: INTEGER PRIMARY KEY
    -location_id: INTEGER REFERENCES
    -title: TEXT
    -date: DATE
    -source: TEXT
    -body: TEXT
    -image:TEXT
  }
location "1" --o "n" event : a location has one or more toxic events
```

## TODOs

SELECT load_extension('mod_spatialite');
SELECT InitSpatialMetaData();
SELECT AddGeometryColumn('location', 'geometry', 4326, 'POINT', 'XY');
