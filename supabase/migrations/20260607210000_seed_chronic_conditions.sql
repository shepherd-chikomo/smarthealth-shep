-- Seed chronic conditions into profile_conditions common catalog (QA checklist PR-C)

BEGIN;

INSERT INTO public.profile_conditions (slug, label, is_common, sort_order, is_active)
SELECT v.slug, v.label, true, v.sort_order, true
FROM (VALUES
  ('hypertension-high-blood-pressure', 'Hypertension (High Blood Pressure)', 10),
  ('heart-failure', 'Heart Failure', 11),
  ('coronary-artery-disease', 'Coronary Artery Disease', 12),
  ('previous-heart-attack', 'Previous Heart Attack', 13),
  ('angina', 'Angina', 14),
  ('atrial-fibrillation', 'Arrhythmias (e.g. Atrial Fibrillation)', 15),
  ('pacemaker-or-implantable-defibrillator', 'Pacemaker or Implantable Defibrillator', 16),
  ('asthma', 'Asthma', 20),
  ('chronic-obstructive-pulmonary-disease-copd', 'Chronic Obstructive Pulmonary Disease (COPD)', 21),
  ('chronic-bronchitis', 'Chronic Bronchitis', 22),
  ('emphysema', 'Emphysema', 23),
  ('sleep-apnoea', 'Sleep Apnoea', 24),
  ('oxygen-dependence', 'Oxygen Dependence', 25),
  ('type-1-diabetes', 'Type 1 Diabetes', 30),
  ('type-2-diabetes', 'Type 2 Diabetes', 31),
  ('hypoglycaemia-risk', 'Hypoglycaemia Risk', 32),
  ('hyperthyroidism', 'Hyperthyroidism', 33),
  ('hypothyroidism', 'Hypothyroidism', 34),
  ('adrenal-insufficiency', 'Adrenal Insufficiency', 35),
  ('epilepsy-seizure-disorder', 'Epilepsy / Seizure Disorder', 40),
  ('stroke-history', 'Stroke History', 41),
  ('transient-ischaemic-attack-tia', 'Transient Ischaemic Attack (TIA)', 42),
  ('parkinsons-disease', 'Parkinson''s Disease', 43),
  ('multiple-sclerosis', 'Multiple Sclerosis', 44),
  ('dementia', 'Dementia', 45),
  ('migraine-disorders', 'Migraine Disorders', 46),
  ('sickle-cell-disease', 'Sickle Cell Disease', 50),
  ('haemophilia', 'Haemophilia', 51),
  ('thalassaemia', 'Thalassaemia', 52),
  ('chronic-anaemia', 'Chronic Anaemia', 53),
  ('blood-clotting-disorders', 'Blood Clotting Disorders', 54),
  ('history-of-deep-vein-thrombosis-dvt', 'History of Deep Vein Thrombosis (DVT)', 55),
  ('chronic-kidney-disease', 'Chronic Kidney Disease', 60),
  ('dialysis-patient', 'Dialysis Patient', 61),
  ('kidney-transplant', 'Kidney Transplant', 62),
  ('liver-cirrhosis', 'Liver Cirrhosis', 63),
  ('hepatitis-b', 'Hepatitis B', 64),
  ('hepatitis-c', 'Hepatitis C', 65),
  ('rheumatoid-arthritis', 'Rheumatoid Arthritis', 70),
  ('lupus', 'Lupus', 71),
  ('psoriasis-with-systemic-treatment', 'Psoriasis with Systemic Treatment', 72),
  ('crohns-disease', 'Crohn''s Disease', 73),
  ('ulcerative-colitis', 'Ulcerative Colitis', 74),
  ('severe-depression', 'Severe Depression', 80),
  ('bipolar-disorder', 'Bipolar Disorder', 81),
  ('schizophrenia', 'Schizophrenia', 82),
  ('severe-anxiety-disorders', 'Severe Anxiety Disorders', 83),
  ('ptsd', 'PTSD', 84),
  ('hiv', 'HIV (optional and privacy-controlled)', 90),
  ('tuberculosis-history', 'Tuberculosis History', 91),
  ('active-infectious-disease-alerts', 'Active Infectious Disease Alerts', 92),
  ('active-cancer-treatment', 'Active Cancer Treatment', 100),
  ('chemotherapy', 'Chemotherapy', 101),
  ('radiation-therapy', 'Radiation Therapy', 102),
  ('immunotherapy', 'Immunotherapy', 103)
) AS v(slug, label, sort_order)
WHERE NOT EXISTS (
  SELECT 1 FROM public.profile_conditions pc
  WHERE pc.slug = v.slug AND pc.deleted_at IS NULL
);

COMMIT;
