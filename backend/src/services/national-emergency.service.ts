/** Zimbabwe national and city emergency numbers — always shown on the emergency hub. */

export interface NationalEmergencyService {
  id: string;
  name: string;
  serviceType: 'ambulance' | 'police' | 'fire' | 'disaster_response';
  phone: string;
  city: string;
  province: string;
  latitude: number;
  longitude: number;
  isNational: boolean;
}

const NATIONAL: NationalEmergencyService[] = [
  {
    id: 'national-ambulance',
    name: 'Ambulance (994)',
    serviceType: 'ambulance',
    phone: '994',
    city: 'National',
    province: 'Harare',
    latitude: -17.8252,
    longitude: 31.0335,
    isNational: true,
  },
  {
    id: 'national-police',
    name: 'Police (995)',
    serviceType: 'police',
    phone: '995',
    city: 'National',
    province: 'Harare',
    latitude: -17.8252,
    longitude: 31.0335,
    isNational: true,
  },
  {
    id: 'national-fire',
    name: 'Fire & Rescue (993)',
    serviceType: 'fire',
    phone: '993',
    city: 'National',
    province: 'Harare',
    latitude: -17.8252,
    longitude: 31.0335,
    isNational: true,
  },
  {
    id: 'national-emergency',
    name: 'General Emergency (999)',
    serviceType: 'disaster_response',
    phone: '999',
    city: 'National',
    province: 'Harare',
    latitude: -17.8252,
    longitude: 31.0335,
    isNational: true,
  },
  {
    id: 'national-mobile',
    name: 'Mobile Emergency (112)',
    serviceType: 'disaster_response',
    phone: '112',
    city: 'National',
    province: 'Harare',
    latitude: -17.8252,
    longitude: 31.0335,
    isNational: true,
  },
];

const CITY_SERVICES: Record<
  string,
  Omit<NationalEmergencyService, 'isNational'>[]
> = {
  Harare: [
    {
      id: 'harare-police',
      name: 'Harare Central Police',
      serviceType: 'police',
      phone: '+263242777777',
      city: 'Harare',
      province: 'Harare',
      latitude: -17.829,
      longitude: 31.052,
    },
    {
      id: 'harare-fire',
      name: 'Harare Fire Brigade',
      serviceType: 'fire',
      phone: '+263242720206',
      city: 'Harare',
      province: 'Harare',
      latitude: -17.8315,
      longitude: 31.0455,
    },
    {
      id: 'harare-ambulance',
      name: 'Harare Ambulance Dispatch',
      serviceType: 'ambulance',
      phone: '+263242703999',
      city: 'Harare',
      province: 'Harare',
      latitude: -17.8252,
      longitude: 31.0335,
    },
  ],
  Bulawayo: [
    {
      id: 'bulawayo-police',
      name: 'Bulawayo Central Police',
      serviceType: 'police',
      phone: '+26329271515',
      city: 'Bulawayo',
      province: 'Bulawayo',
      latitude: -20.1556,
      longitude: 28.5847,
    },
    {
      id: 'bulawayo-fire',
      name: 'Bulawayo Fire & Ambulance',
      serviceType: 'fire',
      phone: '+2632927171',
      city: 'Bulawayo',
      province: 'Bulawayo',
      latitude: -20.1556,
      longitude: 28.5847,
    },
  ],
  Mutare: [
    {
      id: 'mutare-police',
      name: 'Mutare Police',
      serviceType: 'police',
      phone: '+2632064444',
      city: 'Mutare',
      province: 'Manicaland',
      latitude: -18.9707,
      longitude: 32.6709,
    },
  ],
  Gweru: [
    {
      id: 'gweru-police',
      name: 'Gweru Police',
      serviceType: 'police',
      phone: '+26354222222',
      city: 'Gweru',
      province: 'Midlands',
      latitude: -19.4544,
      longitude: 29.8152,
    },
  ],
};

/** Rough bounding boxes for major Zimbabwe cities (lat/lon). */
function detectNearestCity(lat: number, lon: number): string | null {
  const cities: { name: string; lat: number; lon: number; radius: number }[] = [
    { name: 'Harare', lat: -17.8252, lon: 31.0335, radius: 0.45 },
    { name: 'Bulawayo', lat: -20.1556, lon: 28.5847, radius: 0.35 },
    { name: 'Mutare', lat: -18.9707, lon: 32.6709, radius: 0.25 },
    { name: 'Gweru', lat: -19.4544, lon: 29.8152, radius: 0.25 },
  ];

  let best: { name: string; dist: number } | null = null;
  for (const city of cities) {
    const dist = Math.hypot(lat - city.lat, lon - city.lon);
    if (dist <= city.radius && (!best || dist < best.dist)) {
      best = { name: city.name, dist };
    }
  }
  return best?.name ?? null;
}

export function getNationalEmergencyServices(options?: {
  lat?: number;
  lon?: number;
}): NationalEmergencyService[] {
  const services: NationalEmergencyService[] = [...NATIONAL];

  if (options?.lat != null && options?.lon != null) {
    const city = detectNearestCity(options.lat, options.lon);
    if (city && CITY_SERVICES[city]) {
      for (const entry of CITY_SERVICES[city]) {
        services.push({ ...entry, isNational: false });
      }
    }
  }

  return services;
}
