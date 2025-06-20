---
--- Create database for ToxHer
---
PRAGMA foreign_keys = ON;
CREATE TABLE location (
    id            INTEGER PRIMARY KEY,
    address       TEXT,
    longitude     FLOAT,
    latitude      FLOAT,
    rating        INTEGER
);

CREATE TABLE event (
    id            INTEGER PRIMARY KEY,
    location_id   INTEGER REFERENCES location(id) ON DELETE CASCADE ON UPDATE CASCADE,
    title         TEXT,
    pubdate       DATE default '0000-00-00',
    source        TEXT,
    body          TEXT,
    image         TEXT
);
---
--- Load some sample data
---
INSERT INTO location VALUES (1, 'André-Pican-Straße 40, 16515 Oranienburg', 52.7511572566098, 13.2552372718261, 5);
INSERT INTO location VALUES (2, 'Lindenring 18, 16515 Oranienburg', 52.751607, 13.245723, 4);
INSERT INTO event VALUES (1, 1, 'Kita-Kinder und erhöhte Strahlung - ist die Angst der Eltern begründet?', '2022-10-22', 'MOZ.de', 'Bei der Sanierung eines einstigen Getränkemarktes in Oranienburg gab es eine böse Überraschung. Von radioaktiven Stoffen war die Rede. Waren dort nicht Kinder untergebracht? Der Kreis klärt auf.', '');
INSERT INTO event VALUES (2, 2, 'Versteckte Atom-Strahlen lassen Menschen um ihr Leben bangen. Doch die Behörden weigern sich zu handeln', '1994-11-10', '', 'Oranienburg -- die Angst geht um in der 30000 Einwohner zählenden Kreisstadt vor den Toren Berlins. Jeder fragt sich: Wen trifft es als nächsten, wer wird als nächster an Krebs erkranken? Der Grund: Im Lindenring-Viertel, das an das Gelände einer ehemaligen Rüstungsfabrik grenzt, tickt eine "Zeitbombe". Ihr Inhalt: atomare Strahlen, doppelt so stark wie normal.', '');
