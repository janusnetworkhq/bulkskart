-- Ensure signup role from auth metadata is always persisted (including ON CONFLICT)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
DECLARE
  chosen_role public.user_role := 'buyer'::public.user_role;
  raw_role text;
  meta_full_name text;
BEGIN
  raw_role := lower(coalesce(NEW.raw_user_meta_data->>'role', ''));
  IF raw_role IN ('supplier', 'manufacturer', 'seller') THEN
    chosen_role := 'supplier'::public.user_role;
  ELSIF raw_role = 'admin' THEN
    chosen_role := 'admin'::public.user_role;
  ELSE
    chosen_role := 'buyer'::public.user_role;
  END IF;

  meta_full_name := COALESCE(
    NULLIF(NEW.raw_user_meta_data->>'full_name', ''),
    NULLIF(NEW.raw_user_meta_data->>'name', ''),
    split_part(NEW.email, '@', 1)
  );

  INSERT INTO public.profiles (
    id,
    email,
    full_name,
    role,
    status,
    created_at,
    updated_at
  )
  VALUES (
    NEW.id,
    NEW.email,
    meta_full_name,
    chosen_role,
    'active',
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    full_name = COALESCE(NULLIF(public.profiles.full_name, ''), EXCLUDED.full_name),
    -- Always honor signup metadata role when it is supplier/admin
    role = CASE
      WHEN EXCLUDED.role IN ('supplier'::public.user_role, 'admin'::public.user_role)
        THEN EXCLUDED.role
      ELSE public.profiles.role
    END,
    updated_at = NOW();

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- Repair: company owners incorrectly stored as buyers
UPDATE public.profiles p
SET role = 'supplier'::public.user_role,
    updated_at = NOW()
WHERE p.role = 'buyer'::public.user_role
  AND EXISTS (
    SELECT 1 FROM public.companies c WHERE c.owner_id = p.id
  );
