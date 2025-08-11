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





Certainly! To achieve this, you'll need to write a controller in Catalyst that fetches the necessary data from your SQLite database and passes it to a Template Toolkit (TT2) view. Below is an example of how you can write such a controller in Catalyst.

### Controller Code

First, let's create a controller that will fetch the data from the database and pass it to the view.

```perl
package MyApp::Controller::Locations;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    # Fetch locations and their associated events
    my $locations = $c->model('DB::Location')->search(
        {},
        {
            prefetch => 'events',
            order_by => 'id'
        }
    );

    # Prepare data for the view
    my @markers;
    while (my $location = $locations->next) {
        my %marker = (
            id      => $location->id,
            long    => $location->longitude,
            lat     => $location->latitude,
            address => $location->address,
            events  => {},
        );

        my $events = $location->events;
        my $event_count = 1;
        while (my $event = $events->next) {
            my $event_date = $event->pubdate;
            $event_date =~ s/-/ /g; # Replace dashes with spaces
            $marker{events}->{"event$event_count"} = "$event_date: $event->title";
            $event_count++;
        }

        push @markers, \%marker;
    }

    # Pass data to the view
    $c->stash(markers => \@markers);

    # Render the view
    $c->stash(template => 'locations/index.tt2');
}

__PACKAGE__->meta->make_immutable;

1;
```

### View Code (Template Toolkit)

Next, create a Template Toolkit view file (`locations/index.tt2`) that will generate the JavaScript array.

```tt2
[%- SET markers = stash.markers -%]
const Marker = [
[%- FOREACH marker IN markers -%]
    {
        id: [% marker.id %],
        long: [% marker.long %],
        lat: [% marker.lat %],
        address: '[% marker.address %]',
        events: {
[%- FOREACH event IN marker.events.keys -%]
            [% event %]: '[% marker.events.$event %]',
[%- END -%]
        },
    },
[%- END -%]
];
```

### Explanation

1. **Controller**:
   - The `index` action fetches all locations and their associated events using the `search` method with the `prefetch` option.
   - It then iterates over the locations and prepares the data in the required format.
   - The data is passed to the view using `$c->stash`.

2. **View**:
   - The view iterates over the `markers` array and generates the JavaScript array structure.
   - It uses Template Toolkit syntax to dynamically insert the data into the JavaScript array.

### Additional Notes

- Ensure that your Catalyst application is properly configured to use the SQLite database and that the `DB::Location` and `DB::Event` models are correctly defined.
- The `prefetch` option in the `search` method ensures that the associated events are fetched in a single query, improving performance.
- The `order_by` option ensures that the locations are fetched in a consistent order.

This should give you a good starting point for displaying the locations and their associated events in your Catalyst application.
