# Annahme: $c ist dein Catalyst-Context und $id ist der gewünschte location_id-Wert

# 1. Zugriff auf das Location-Modell (angenommen es heißt "Location")
my $location_rs = $c->model('DB::Location')->search(
    {
        'me.id' => $id,  # oder einfach 'id' => $id, wenn kein Alias verwendet wird
    },
    {
        join => {
            event => {  # Annahme: Die Beziehung heißt 'event'
                select => [ 'title' ],  # Nur die title-Spalte aus der Event-Tabelle
                as     => 'event'       # Alias für die Event-Tabelle
            }
        }
    }
);

# 2. Alternative mit explizitem JOIN (falls die obige Variante nicht funktioniert)
my $location_rs = $c->model('DB::Location')->search(
    {
        'me.id' => $id,
    },
    {
        join => 'event',  # Annahme: Die Beziehung heißt 'event'
        '+select' => [ 'event.title' ],  # Füge die Event-Titel-Spalte hinzu
        '+as'     => [ 'event_title' ]   # Optional: Alias für den Titel
    }
);

# 3. In deiner Template-Datei (z.B. mit TT2):
# [% FOREACH loc IN location_rs %]
#     Ort: [% loc.name %], Event: [% loc.event.title %]
# [% END %]
# Oder falls du den Alias verwendet hast:
# [% FOREACH loc IN location_rs %]
#     Ort: [% loc.name %], Event: [% loc.event_title %]
# [% END %]
```

Wichtige Hinweise:
1. Die genauen Tabellen- und Beziehungsnamen müssen an deine DBIx::Class-Schema-Definition angepasst werden
2. Falls die Beziehung anders heißt als 'event', musst du den korrekten Namen verwenden
3. Die `select`-Option ist optional, aber nützlich, um nur bestimmte Spalten zu laden
4. Im Template musst du den ResultSet korrekt übergeben (z.B. über `$c->stash->{location_rs} = $location_rs;`)

Falls du eine spezifischere Lösung brauchst, gib bitte mehr Details zu deiner DBIx::Class-Schema-Definition und den genauen Tabellenbeziehungen.
