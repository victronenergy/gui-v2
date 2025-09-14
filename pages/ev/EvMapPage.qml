/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtWebView
import Victron.VenusOS

Page {
	id: root

	property string evServiceUid: ""
	property string evName: ""

	//% "EV Location"
	title: qsTrId("ev_location_title")

	VeQuickItem {
		id: latitudeItem
		uid: root.evServiceUid + "/Position/Latitude"
	}

	VeQuickItem {
		id: longitudeItem
		uid: root.evServiceUid + "/Position/Longitude"
	}

	VeQuickItem {
		id: rangeItem
		uid: root.evServiceUid + "/RangeToGo"
	}

	VeQuickItem {
		id: customNameItem
		uid: root.evServiceUid + "/CustomName"
	}

	readonly property bool hasValidPosition: latitudeItem.valid && longitudeItem.valid
	readonly property real evLatitude: latitudeItem.valid ? latitudeItem.value : 0
	readonly property real evLongitude: longitudeItem.valid ? longitudeItem.value : 0
	readonly property real evRange: rangeItem.valid ? rangeItem.value : 0
	readonly property string displayName: customNameItem.valid && customNameItem.value ? customNameItem.value : (evName || "EV")

	// Generate the HTML content for the map using OpenStreetMap + Leaflet
	readonly property string mapHtml: `
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>EV Location</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" 
          integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=" crossorigin=""/>
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"
            integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo=" crossorigin=""></script>
    <style>
        body { 
            margin: 0; 
            padding: 0; 
            font-family: Arial, sans-serif; 
            background-color: #1a1a1a; 
            color: white; 
        }
        #map { 
            position: absolute; 
            top: 0; 
            bottom: 0; 
            width: 100%; 
        }
        .range-info {
            position: absolute;
            top: 20px;
            right: 20px;
            background-color: rgba(0, 0, 0, 0.8);
            padding: 12px 16px;
            border-radius: 8px;
            backdrop-filter: blur(10px);
            z-index: 1000;
            border: 1px solid #4a9eff;
            min-width: 120px;
        }
        .range-label {
            font-size: 12px;
            color: #999;
            text-transform: uppercase;
            margin-bottom: 8px;
        }
        .range-value {
            font-size: 20px;
            font-weight: bold;
            color: #4a9eff;
            margin-bottom: 12px;
        }
        .range-legend {
            font-size: 11px;
            color: #ccc;
            line-height: 1.4;
        }
        .range-legend-item {
            display: flex;
            align-items: center;
            margin-bottom: 4px;
        }
        .range-legend-color {
            width: 12px;
            height: 12px;
            border-radius: 50%;
            margin-right: 6px;
            border: 1px solid rgba(255,255,255,0.3);
        }
        .no-gps {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            text-align: center;
            z-index: 1000;
            background-color: rgba(0, 0, 0, 0.9);
            padding: 32px;
            border-radius: 16px;
            max-width: 400px;
            border: 1px solid #333;
        }
        .leaflet-popup-content-wrapper {
            background-color: #2a2a2a;
            color: white;
            border-radius: 8px;
        }
        .leaflet-popup-tip {
            background-color: #2a2a2a;
        }
        .leaflet-popup-content {
            color: white;
        }
        .leaflet-popup-content h3 {
            color: #4a9eff;
            margin-top: 0;
        }
        /* Dark theme for map controls */
        .leaflet-control-zoom a {
            background-color: #2a2a2a;
            color: white;
            border-color: #444;
        }
        .leaflet-control-zoom a:hover {
            background-color: #3a3a3a;
            color: #4a9eff;
        }
        .leaflet-control-attribution {
            background-color: rgba(42, 42, 42, 0.8);
            color: #ccc;
        }
        .leaflet-control-attribution a {
            color: #4a9eff;
        }
    </style>
</head>
<body>
    <div id="map"></div>
    
    <div class="range-info" id="rangeInfo" style="display: none;">
        <div class="range-label">Range</div>
        <div class="range-value" id="rangeValue">-- km</div>
        <div class="range-legend">
            <div class="range-legend-item">
                <div class="range-legend-color" style="background-color: rgba(74, 158, 255, 0.6);"></div>
                <span>Highway driving</span>
            </div>
            <div class="range-legend-item">
                <div class="range-legend-color" style="background-color: rgba(74, 158, 255, 0.4);"></div>
                <span>Mixed driving</span>
            </div>
            <div class="range-legend-item">
                <div class="range-legend-color" style="background-color: rgba(74, 158, 255, 0.2);"></div>
                <span>City driving</span>
            </div>
        </div>
    </div>

    <div class="no-gps" id="noGpsOverlay" style="display: none;">
        <div style="font-size: 48px; margin-bottom: 16px; opacity: 0.6;">📍</div>
        <div style="font-size: 18px; margin-bottom: 8px;">No GPS Position Available</div>
        <div style="font-size: 14px; color: #999; line-height: 1.4;">
            GPS coordinates are required to show the EV location on the map.
        </div>
    </div>

    <script>
        let map;
        let evMarker;
        let rangeCircles = [];
        let evData = {
            name: '${root.displayName}',
            latitude: ${root.hasValidPosition ? root.evLatitude : 52.377956},
            longitude: ${root.hasValidPosition ? root.evLongitude : 4.897070},
            range: ${root.evRange},
            hasGPS: ${root.hasValidPosition}
        };

        function initializeMap() {
            if (!evData.hasGPS) {
                document.getElementById('noGpsOverlay').style.display = 'block';
                return;
            }

            // Initialize map with OpenStreetMap tiles
            map = L.map('map').setView([evData.latitude, evData.longitude], 13);

            // Add OpenStreetMap tile layer
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                maxZoom: 19,
                attribution: '© <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
            }).addTo(map);

            // Add EV marker and range circles
            addEVMarker();
            if (evData.range > 0) {
                addRealisticRangeCircles();
                showRangeInfo();
            }
        }

        function addEVMarker() {
            // Create custom EV icon
            const evIcon = L.divIcon({
                className: 'custom-div-icon',
                html: '<div style="background-color: #4a9eff; border: 3px solid white; border-radius: 50%; width: 32px; height: 32px; display: flex; align-items: center; justify-content: center; font-weight: bold; font-size: 12px; color: white; box-shadow: 0 2px 8px rgba(0,0,0,0.3);">EV</div>',
                iconSize: [32, 32],
                iconAnchor: [16, 16]
            });

            // Add marker to map
            evMarker = L.marker([evData.latitude, evData.longitude], {icon: evIcon})
                .addTo(map)
                .bindPopup(\`
                    <div>
                        <h3>\${evData.name}</h3>
                        <p><strong>Range:</strong> \${evData.range} km</p>
                        <p><strong>Position:</strong> \${evData.latitude.toFixed(4)}, \${evData.longitude.toFixed(4)}</p>
                        <p style="font-size: 12px; color: #999; margin-top: 8px;">
                            Range circles show realistic driving distances based on road conditions.
                        </p>
                    </div>
                \`);
        }

        function addRealisticRangeCircles() {
            // Clear existing circles
            rangeCircles.forEach(circle => map.removeLayer(circle));
            rangeCircles = [];

            // Base range in meters
            const baseRange = evData.range * 1000;

            // Range circles with different confidence levels
            const rangeConfigs = [
                {
                    // Outer circle: Highway driving (80% of theoretical range)
                    factor: 0.8,
                    color: '#4a9eff',
                    fillOpacity: 0.1,
                    opacity: 0.6,
                    weight: 1,
                    dashArray: '10, 5'
                },
                {
                    // Middle circle: Mixed driving (60% of theoretical range)
                    factor: 0.6,
                    color: '#4a9eff',
                    fillOpacity: 0.15,
                    opacity: 0.7,
                    weight: 2,
                    dashArray: '5, 3'
                },
                {
                    // Inner circle: City driving (40% of theoretical range)
                    factor: 0.4,
                    color: '#4a9eff',
                    fillOpacity: 0.2,
                    opacity: 0.8,
                    weight: 2,
                    dashArray: null
                }
            ];

            // Add circles from largest to smallest (so smaller ones appear on top)
            rangeConfigs.forEach(config => {
                const circle = L.circle([evData.latitude, evData.longitude], {
                    color: config.color,
                    fillColor: config.color,
                    fillOpacity: config.fillOpacity,
                    opacity: config.opacity,
                    weight: config.weight,
                    radius: baseRange * config.factor,
                    dashArray: config.dashArray
                }).addTo(map);
                
                rangeCircles.push(circle);
            });

            // Fit map to show the largest circle with some padding
            const outerCircle = rangeCircles[0];
            const group = new L.featureGroup([evMarker, outerCircle]);
            map.fitBounds(group.getBounds().pad(0.1));
        }

        function showRangeInfo() {
            const rangeInfo = document.getElementById('rangeInfo');
            const rangeValue = document.getElementById('rangeValue');
            rangeValue.textContent = evData.range + ' km';
            rangeInfo.style.display = 'block';
        }

        // Function to update EV data from QML
        function updateEvData(newData) {
            evData = { ...evData, ...newData };
            
            if (evData.hasGPS && map) {
                // Update marker position
                if (evMarker) {
                    evMarker.setLatLng([evData.latitude, evData.longitude]);
                    evMarker.setPopupContent(\`
                        <div>
                            <h3>\${evData.name}</h3>
                            <p><strong>Range:</strong> \${evData.range} km</p>
                            <p><strong>Position:</strong> \${evData.latitude.toFixed(4)}, \${evData.longitude.toFixed(4)}</p>
                            <p style="font-size: 12px; color: #999; margin-top: 8px;">
                                Range circles show realistic driving distances based on road conditions.
                            </p>
                        </div>
                    \`);
                }

                // Update range circles
                if (evData.range > 0) {
                    addRealisticRangeCircles();
                }

                // Update range info
                const rangeValue = document.getElementById('rangeValue');
                if (rangeValue) {
                    rangeValue.textContent = evData.range + ' km';
                }

                // Center map on new position
                map.setView([evData.latitude, evData.longitude]);
            }
        }

        // Initialize when page loads
        document.addEventListener('DOMContentLoaded', initializeMap);
    </script>
</body>
</html>`

	Rectangle {
		anchors.fill: parent
		color: Theme.color_page_background

		Column {
			anchors.fill: parent
			spacing: 0

			// Header with EV info
			Rectangle {
				width: parent.width
				height: Theme.geometry_listItem_height
				color: Theme.color_listItem_background

				Row {
					anchors {
						left: parent.left
						leftMargin: Theme.geometry_listItem_content_horizontalMargin
						right: parent.right
						rightMargin: Theme.geometry_listItem_content_horizontalMargin
						verticalCenter: parent.verticalCenter
					}
					spacing: Theme.geometry_listItem_content_spacing

					Label {
						id: evNameLabel
						anchors.verticalCenter: parent.verticalCenter
						text: root.displayName
						color: Theme.color_font_primary
						font.pixelSize: Theme.font_size_body1
					}

					Item {
						width: parent.width - evNameLabel.width - evStatsLabel.width - (2 * parent.spacing)
						height: 1
					}

					Label {
						id: evStatsLabel
						anchors.verticalCenter: parent.verticalCenter
						text: root.evRange > 0 ? Math.round(root.evRange) + " km" : "-- km"
						color: Theme.color_font_secondary
						font.pixelSize: Theme.font_size_caption
					}
				}
			}

			// Map container
			Item {
				width: parent.width
				height: parent.height - Theme.geometry_listItem_height

				// Try WebView first, fallback to placeholder if not available
				Loader {
					id: webViewLoader
					anchors.fill: parent
					
					sourceComponent: Component {
						WebView {
							anchors.fill: parent
							
							Component.onCompleted: {
								console.log("WebView created, loading OpenStreetMap with realistic range")
								loadHtml(root.mapHtml)
							}

							onLoadingChanged: function(loadRequest) {
								if (loadRequest.status === WebView.LoadSucceededStatus) {
									console.log("OpenStreetMap with realistic range loaded successfully")
								} else if (loadRequest.status === WebView.LoadFailedStatus) {
									console.log("OpenStreetMap failed to load")
									webViewLoader.sourceComponent = mapPlaceholderComponent
								}
							}

							// Update map when EV data changes
							Connections {
								target: root
								function onEvLatitudeChanged() { updateMapData() }
								function onEvLongitudeChanged() { updateMapData() }
								function onEvRangeChanged() { updateMapData() }
								function onHasValidPositionChanged() { updateMapData() }
							}

							function updateMapData() {
								if (root.hasValidPosition) {
									const updateScript = `updateEvData({
										latitude: ${root.evLatitude},
										longitude: ${root.evLongitude},
										range: ${root.evRange},
										hasGPS: true,
										name: '${root.displayName}'
									});`
									runJavaScript(updateScript)
								}
							}
						}
					}

					onStatusChanged: {
						if (status === Loader.Error) {
							console.log("WebView not available, using placeholder")
							sourceComponent = mapPlaceholderComponent
						}
					}
				}

				// Fallback placeholder component
				Component {
					id: mapPlaceholderComponent
					
					Rectangle {
						anchors.fill: parent
						color: Theme.color_listItem_background

						Column {
							anchors.centerIn: parent
							spacing: Theme.geometry_listItem_content_spacing

							Label {
								anchors.horizontalCenter: parent.horizontalCenter
								text: root.hasValidPosition ? "🗺️ Map integration requires WebView" : "📍 No GPS Data"
								color: Theme.color_font_primary
								font.pixelSize: Theme.font_size_body1
							}

							Label {
								anchors.horizontalCenter: parent.horizontalCenter
								text: root.hasValidPosition 
									? "Lat: " + root.evLatitude.toFixed(6) + ", Lng: " + root.evLongitude.toFixed(6)
									: "GPS coordinates are required to show the EV location"
								color: Theme.color_font_secondary
								font.pixelSize: Theme.font_size_caption
								horizontalAlignment: Text.AlignHCenter
								wrapMode: Text.WordWrap
								width: Math.min(parent.parent.width * 0.8, 400)
							}

							Label {
								anchors.horizontalCenter: parent.horizontalCenter
								text: root.evRange > 0 ? "Range: " + Math.round(root.evRange) + " km" : "Range: Unknown"
								color: Theme.color_font_secondary
								font.pixelSize: Theme.font_size_caption
								visible: root.hasValidPosition
							}

							Label {
								anchors.horizontalCenter: parent.horizontalCenter
								text: "Realistic range circles: 80% highway, 60% mixed, 40% city"
								color: Theme.color_ok
								font.pixelSize: Theme.font_size_caption
								opacity: 0.8
								visible: root.hasValidPosition
							}

							Label {
								anchors.horizontalCenter: parent.horizontalCenter
								text: "Using OpenStreetMap (Free)"
								color: Theme.color_ok
								font.pixelSize: Theme.font_size_caption
								opacity: 0.8
							}

							Label {
								anchors.horizontalCenter: parent.horizontalCenter
								text: "EV Service UID: " + root.evServiceUid
								color: Theme.color_font_secondary
								font.pixelSize: Theme.font_size_caption
								opacity: 0.7
							}
						}
					}
				}
			}
		}
	}

	// Back button handling
	Keys.onBackPressed: {
		Global.pageManager.popPage()
		event.accepted = true
	}
}