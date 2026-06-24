'use client';

import { useEffect, useMemo } from 'react';
import L from 'leaflet';
import { MapContainer, Marker, TileLayer, useMapEvents } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';

import iconRetinaUrl from 'leaflet/dist/images/marker-icon-2x.png';
import iconUrl from 'leaflet/dist/images/marker-icon.png';
import shadowUrl from 'leaflet/dist/images/marker-shadow.png';

const HARARE_LAT = -17.8252;
const HARARE_LON = 31.0335;

// Leaflet default marker assets break under Next/Webpack without explicit URLs.
// eslint-disable-next-line @typescript-eslint/no-explicit-any
delete (L.Icon.Default.prototype as any)._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: iconRetinaUrl.src,
  iconUrl: iconUrl.src,
  shadowUrl: shadowUrl.src,
});

export interface MapPosition {
  lat: number;
  lng: number;
}

function MapClickHandler({
  onChange,
  disabled,
}: {
  onChange: (pos: MapPosition) => void;
  disabled?: boolean;
}) {
  useMapEvents({
    click(event) {
      if (disabled) return;
      onChange({ lat: event.latlng.lat, lng: event.latlng.lng });
    },
  });
  return null;
}

function DraggableMarker({
  position,
  onChange,
  disabled,
}: {
  position: MapPosition;
  onChange: (pos: MapPosition) => void;
  disabled?: boolean;
}) {
  return (
    <Marker
      position={[position.lat, position.lng]}
      draggable={!disabled}
      eventHandlers={{
        dragend: (event) => {
          const marker = event.target;
          const { lat, lng } = marker.getLatLng();
          onChange({ lat, lng });
        },
      }}
    />
  );
}

export function FacilityLocationMap({
  position,
  onChange,
  disabled,
}: {
  position: MapPosition | null;
  onChange: (pos: MapPosition) => void;
  disabled?: boolean;
}) {
  const center = useMemo(
    () => position ?? { lat: HARARE_LAT, lng: HARARE_LON },
    [position?.lat, position?.lng],
  );

  useEffect(() => {
    // Ensure Leaflet recalculates size when shown inside a card layout.
    const timer = setTimeout(() => window.dispatchEvent(new Event('resize')), 100);
    return () => clearTimeout(timer);
  }, []);

  return (
    <div className="overflow-hidden rounded-lg border border-[var(--border)]">
      <MapContainer
        center={[center.lat, center.lng]}
        zoom={position ? 15 : 12}
        className="h-[280px] w-full"
        scrollWheelZoom
      >
        <TileLayer
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
          url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        />
        <MapClickHandler onChange={onChange} disabled={disabled} />
        {position && (
          <DraggableMarker position={position} onChange={onChange} disabled={disabled} />
        )}
      </MapContainer>
    </div>
  );
}
