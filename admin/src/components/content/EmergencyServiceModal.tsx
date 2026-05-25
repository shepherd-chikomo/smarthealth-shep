import { useEffect, useState } from 'react';
import { Modal } from '../ui';
import type { EmergencyServiceInput, EmergencyServiceRecord } from '../../lib/api';

const SERVICE_TYPES = [
  'ambulance', 'fire', 'police', 'hospital_er', 'poison_control',
  'mental_health_crisis', 'disaster_response', 'other',
] as const;

const PROVINCES = [
  'Bulawayo', 'Harare', 'Manicaland', 'Mashonaland Central', 'Mashonaland East',
  'Mashonaland West', 'Masvingo', 'Matabeleland North', 'Matabeleland South', 'Midlands',
] as const;

interface Props {
  service?: EmergencyServiceRecord | null;
  saving: boolean;
  error: string;
  onClose: () => void;
  onSave: (body: EmergencyServiceInput) => void;
}

export function EmergencyServiceModal({ service, saving, error, onClose, onSave }: Props) {
  const [name, setName] = useState('');
  const [serviceType, setServiceType] = useState<string>('ambulance');
  const [phone, setPhone] = useState('');
  const [alternatePhone, setAlternatePhone] = useState('');
  const [address, setAddress] = useState('');
  const [city, setCity] = useState('Harare');
  const [province, setProvince] = useState<string>('Harare');
  const [latitude, setLatitude] = useState('-17.8252');
  const [longitude, setLongitude] = useState('31.0335');
  const [is24Hours, setIs24Hours] = useState(true);
  const [isActive, setIsActive] = useState(true);

  useEffect(() => {
    if (service) {
      setName(service.name);
      setServiceType(service.serviceType);
      setPhone(service.phone);
      setAlternatePhone(service.alternatePhone ?? '');
      setAddress(service.address ?? '');
      setCity(service.city);
      setProvince(service.province);
      setLatitude(String(service.latitude));
      setLongitude(String(service.longitude));
      setIs24Hours(service.is24Hours);
      setIsActive(service.isActive);
    }
  }, [service?.id]);

  function handleSubmit() {
    onSave({
      name: name.trim(),
      serviceType,
      phone: phone.trim(),
      alternatePhone: alternatePhone.trim() || null,
      address: address.trim() || null,
      city: city.trim(),
      province,
      latitude: Number(latitude),
      longitude: Number(longitude),
      is24Hours,
      isActive,
    });
  }

  return (
    <Modal title={service ? 'Edit emergency service' : 'Add emergency service'} onClose={onClose} maxWidth="max-w-xl">
      <div className="grid gap-3 sm:grid-cols-2">
        <label className="block sm:col-span-2">
          <span className="text-sm text-slate-500">Name</span>
          <input className="input mt-1 w-full" value={name} onChange={(e) => setName(e.target.value)} required />
        </label>
        <label className="block">
          <span className="text-sm text-slate-500">Type</span>
          <select className="input mt-1 w-full" value={serviceType} onChange={(e) => setServiceType(e.target.value)}>
            {SERVICE_TYPES.map((t) => (
              <option key={t} value={t}>{t.replace(/_/g, ' ')}</option>
            ))}
          </select>
        </label>
        <label className="block">
          <span className="text-sm text-slate-500">Phone</span>
          <input className="input mt-1 w-full" value={phone} onChange={(e) => setPhone(e.target.value)} required />
        </label>
        <label className="block sm:col-span-2">
          <span className="text-sm text-slate-500">Alternate phone</span>
          <input className="input mt-1 w-full" value={alternatePhone} onChange={(e) => setAlternatePhone(e.target.value)} />
        </label>
        <label className="block sm:col-span-2">
          <span className="text-sm text-slate-500">Address</span>
          <input className="input mt-1 w-full" value={address} onChange={(e) => setAddress(e.target.value)} />
        </label>
        <label className="block">
          <span className="text-sm text-slate-500">City</span>
          <input className="input mt-1 w-full" value={city} onChange={(e) => setCity(e.target.value)} required />
        </label>
        <label className="block">
          <span className="text-sm text-slate-500">Province</span>
          <select className="input mt-1 w-full" value={province} onChange={(e) => setProvince(e.target.value)}>
            {PROVINCES.map((p) => (
              <option key={p} value={p}>{p}</option>
            ))}
          </select>
        </label>
        <label className="block">
          <span className="text-sm text-slate-500">Latitude</span>
          <input className="input mt-1 w-full" type="number" step="any" value={latitude} onChange={(e) => setLatitude(e.target.value)} />
        </label>
        <label className="block">
          <span className="text-sm text-slate-500">Longitude</span>
          <input className="input mt-1 w-full" type="number" step="any" value={longitude} onChange={(e) => setLongitude(e.target.value)} />
        </label>
        <label className="flex items-center gap-2 sm:col-span-2">
          <input type="checkbox" checked={is24Hours} onChange={(e) => setIs24Hours(e.target.checked)} />
          <span className="text-sm">24 hours</span>
        </label>
        <label className="flex items-center gap-2 sm:col-span-2">
          <input type="checkbox" checked={isActive} onChange={(e) => setIsActive(e.target.checked)} />
          <span className="text-sm">Active (visible in mobile app)</span>
        </label>
      </div>
      {error && <p className="mt-3 text-sm text-red-600">{error}</p>}
      <div className="mt-6 flex justify-end gap-2">
        <button type="button" className="btn-secondary" onClick={onClose}>Cancel</button>
        <button
          type="button"
          className="btn-primary"
          disabled={saving || !name.trim() || !phone.trim()}
          onClick={handleSubmit}
        >
          {saving ? 'Saving…' : 'Save'}
        </button>
      </div>
    </Modal>
  );
}
