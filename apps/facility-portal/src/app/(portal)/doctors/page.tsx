import { redirect } from 'next/navigation';

export default function LegacyDoctorsRedirect() {
  redirect('/facility/staff/doctors');
}
