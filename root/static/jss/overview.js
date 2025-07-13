// Initialise the map
const map = new ol.Map({
    target: 'map',
    layers: [new ol.layer.Tile({ source: new ol.source.OSM() })],
    view: new ol.View({
        center: ol.proj.fromLonLat([x, y]),
        zoom: z,
    }),
});

// Add style and layers
for (var i = 0; i < locations.length; i++) {
    var id      = locations[i][0];
    var lon     = locations[i][1];
    var lat     = locations[i][2];
    var address = locations[i][3];
    const locationFeature = new ol.Feature({
        link: id,
        geometry: new ol.geom.Point(ol.proj.fromLonLat([lon, lat])),
        address: address, // not used
    });

    const locationStyle = new ol.style.Style({
        image: new ol.style.Icon({
            anchor: [0.5, 1],
            src: marker,
        })
    });

    locationFeature.setStyle(locationStyle);

    const locationLayer = new ol.layer.Vector({
        source: new ol.source.Vector({
            features: [locationFeature]
        })
    });

    map.on('click', (evt) => {
        const feature = map.forEachFeatureAtPixel(evt.pixel,
           (feature) => {
               return feature;
            });
        if (feature) {
            window.open(feature.get('link'), 'Location\'s details', 'width=700,height=800');
        }
    });

    map.addLayer(locationLayer);
}

// Change mouse cursor when over marker
map.on('pointermove', function (e) {
    const hit = map.hasFeatureAtPixel(e.pixel);
    map.getTargetElement().style.cursor = hit ? 'pointer' : '';
});
