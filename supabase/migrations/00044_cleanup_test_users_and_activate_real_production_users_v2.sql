-- 1. Reassign requirements from test buyers to real user (udhayaprakashmyself@gmail.com: 1276d24d-da85-4710-a8ab-1e1c16135fc1)
UPDATE requirements
SET buyer_id = '1276d24d-da85-4710-a8ab-1e1c16135fc1'
WHERE buyer_id IN (
  SELECT id FROM profiles WHERE email IN (
    'testbuyer2026@bulkskart.com',
    'newbuyer_test2026@example.com',
    'newbuyer1789968747433@testmail.com',
    'testbuyer2026@example.com',
    'testbuyer@bulkskart.com',
    'testbuyer@example.com'
  )
);

-- 2. Reassign quotations if any from test suppliers to real user (udhayaprakashmysel@gmail.com: df4687ef-4141-445b-b611-de0180c92c8b)
UPDATE quotations
SET supplier_id = 'df4687ef-4141-445b-b611-de0180c92c8b',
    supplier_company_id = 'd1d8ce5a-9476-4d78-bb0b-3fa6b9491a1f'
WHERE supplier_id IN (
  SELECT id FROM profiles WHERE email IN (
    'testsupplier2026@bulkskart.com',
    'testmfg_2026@example.com',
    'testsupplier1789968933624@testmail.com',
    'testmanufacturer2026@example.com',
    'testmanufacturer@bulkskart.com',
    'testsupplier@example.com'
  )
);

-- 3. Reassign marketplace products attached to test companies to real company INFOPOD MEDIA (d1d8ce5a-9476-4d78-bb0b-3fa6b9491a1f)
UPDATE products
SET company_id = 'd1d8ce5a-9476-4d78-bb0b-3fa6b9491a1f'
WHERE company_id IN (
  '5032cea5-e5ec-42a2-a28c-022e430a371c',
  'aca54579-2b66-4905-bdfc-1ee4436ad182',
  'fd72da4e-e042-4cf9-8325-cf7f5d56e14f',
  '29bca787-4559-4888-9be7-bd0b2c1af652',
  '6b88ae42-604a-4046-b3b5-e95cb44d5423',
  'c45f0f07-6477-4f45-9030-05c9b37ccdfb'
);

-- 4. Delete the test companies
DELETE FROM companies
WHERE id IN (
  '5032cea5-e5ec-42a2-a28c-022e430a371c',
  'aca54579-2b66-4905-bdfc-1ee4436ad182',
  'fd72da4e-e042-4cf9-8325-cf7f5d56e14f',
  '29bca787-4559-4888-9be7-bd0b2c1af652',
  '6b88ae42-604a-4046-b3b5-e95cb44d5423',
  'c45f0f07-6477-4f45-9030-05c9b37ccdfb'
);

-- 5. Delete test profiles
DELETE FROM public.profiles
WHERE email IN (
  'testsupplier2026@bulkskart.com',
  'testbuyer2026@bulkskart.com',
  'testmfg_2026@example.com',
  'newbuyer_test2026@example.com',
  'testsupplier1789968933624@testmail.com',
  'newbuyer1789968747433@testmail.com',
  'testmanufacturer2026@example.com',
  'testbuyer2026@example.com',
  'testmanufacturer@bulkskart.com',
  'testbuyer@bulkskart.com',
  'testsupplier@example.com',
  'testbuyer@example.com'
);

-- 6. Delete test auth.users
DELETE FROM auth.users
WHERE email IN (
  'testsupplier2026@bulkskart.com',
  'testbuyer2026@bulkskart.com',
  'testmfg_2026@example.com',
  'newbuyer_test2026@example.com',
  'testsupplier1789968933624@testmail.com',
  'newbuyer1789968747433@testmail.com',
  'testmanufacturer2026@example.com',
  'testbuyer2026@example.com',
  'testmanufacturer@bulkskart.com',
  'testbuyer@bulkskart.com',
  'testsupplier@example.com',
  'testbuyer@example.com'
);

-- 7. Ensure real production users are fully activated
UPDATE public.profiles
SET status = 'active',
    updated_at = NOW()
WHERE email IN (
  'udhayaprakashmyself@gmail.com',
  'udhayaprakashmysel@gmail.com',
  'kiranudayakumar10@gmail.com',
  'bulkskart@gmail.com'
);

-- 8. Give INFOPOD MEDIA ENTERTAINMENT an active ₹5,000 Business Subscription with AI Product Matching
INSERT INTO public.subscriptions (
  id,
  company_id,
  tier,
  status,
  price_inr,
  billing_cycle,
  starts_at,
  ends_at,
  max_products,
  max_rfq_leads,
  used_rfq_leads,
  created_at,
  updated_at
) VALUES (
  gen_random_uuid(),
  'd1d8ce5a-9476-4d78-bb0b-3fa6b9491a1f',
  'business',
  'active',
  5000.00,
  'monthly',
  NOW() - INTERVAL '1 day',
  NOW() + INTERVAL '30 days',
  50,
  50,
  0,
  NOW(),
  NOW()
)
ON CONFLICT (id) DO NOTHING;