const map = new ol.Map({
    target: 'map',
    layers: [
        new ol.layer.Tile({
            source: new ol.source.OSM()
        })
    ],
    view: new ol.View({
        center: ol.proj.fromLonLat([x, y]),
        zoom: z,
    })
});

var locationLayer = new ol.layer.Vector({
    source: new ol.source.Vector(),
    style: new ol.style.Style({
        image: new ol.style.Icon({
            anchor: [0.5, 1],
            anchorXUnits: "fraction",
            anchorYUnits: "fraction",
            src: marker, 
        })
    })
});
map.addLayer(locationLayer);

for (let i = 0; i < locations.length; i++) {
    locationLayer.getSource().addFeature(createMarker(locations[i][1], locations[i][2], locations[i][0]));

    map.on('click', (evt) => {
        const feature = map.forEachFeatureAtPixel(evt.pixel,
           (feature) => {
               return feature;
            });
        if (feature) {
            window.open(feature.get('link'), 'Location\'s details', 'width=700,height=800');
        }
    });

}

function createMarker(lng, lat, id) {
    return new ol.Feature({
        geometry: new ol.geom.Point(ol.proj.fromLonLat([lng, lat])),
        link: id
    });
}

// Change mouse cursor when over marker
map.on('pointermove', function (e) {
    const hit = map.hasFeatureAtPixel(e.pixel);
    map.getTargetElement().style.cursor = hit ? 'pointer' : '';
});
