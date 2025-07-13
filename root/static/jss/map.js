const map = new ol.Map({
  target: 'map',
  layers: [
    new ol.layer.Tile({
      source: new ol.source.OSM()
    })
  ],
  view: new ol.View({
    center: ol.proj.fromLonLat([x, y]),
    zoom: z
  })
});
const layer = new ol.layer.Vector({
  source: new ol.source.Vector({
    features: [
      new ol.Feature({
        geometry: new ol.geom.Point(ol.proj.fromLonLat([x, y])),
      })
    ]
  }),
  style: new ol.style.Style({
    image: new ol.style.Icon({
      anchor: [0.5, 1],
      crossOrigin: 'anonymous',
      src: marker,
    })
  })
});
map.addLayer(layer);
