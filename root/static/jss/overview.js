/**
 * Elements that make up the popup.
 */
const container = document.getElementById('popup');
const content = document.getElementById('popup-content');
const closer = document.getElementById('popup-closer');

/**
 * Create an overlay to anchor the popup to the map.
 */
const overlay = new ol.Overlay({
  element: container,
  autoPan: {
    animation: {
      duration: 250,
    },
  },
});

/**
 * Add a click handler to hide the popup.
 * @return {boolean} Don't follow the href.
 */
closer.onclick = function() {
  overlay.setPosition(undefined);
  closer.blur();
  return false;
};


/**
 * Create the map.
 */
const map = new ol.Map({
  layers: [
    new ol.layer.Tile({
      source: new ol.source.OSM(),
    }),
  ],
  overlays: [overlay],
  target: 'map',
  view: new ol.View({
    center: ol.proj.fromLonLat([x, y]),
    zoom: z,
  }),
});

const features = [];
for (key in Marker)
{
  const _Data = Marker[key];
  const feature = new ol.Feature({
    geometry: new ol.geom.Point(
      ol.proj.fromLonLat([parseFloat(_Data.long), parseFloat(_Data.lat)])
    ),
    address: _Data.address,
    events: _Data.events,
  });
  features.push(feature);
}

const markers = new ol.layer.Vector({
  source: new ol.source.Vector({
    features: features,
  }),
  style: new ol.style.Style({
    image: new ol.style.Icon({
      anchor: [0.5, 1],
      src: marker,
    }),
  }),
});

map.addLayer(markers);  

map.on('click', function (evt) {
  const feature = map.forEachFeatureAtPixel(evt.pixel, function (feature) {
    return feature;
  });
  if (feature) {
    const address = feature.get('address');
    const events = feature.get('events');
    let eventList = '<ul>';
    for (const eventKey in events) {
        eventList += `<li>${events[eventKey]}</li>`;
    }
    eventList += '</ul>';
    const coordinates = feature.getGeometry().getCoordinates();
    content.innerHTML = 
      `<p>Address: ${address}</p>${eventList}`
    overlay.setPosition(coordinates);
  }
});

/**
 * Change mouse cursor when over marker.
 */
map.on('pointermove', function (e) {
    const hit = map.hasFeatureAtPixel(e.pixel);
    map.getTargetElement().style.cursor = hit ? 'pointer' : '';
});
