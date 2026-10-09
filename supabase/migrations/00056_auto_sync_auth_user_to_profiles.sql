-- Function to automatically handle new users and create a profile in public.profiles
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
  -- Extract role from raw_user_meta_data if provided
  raw_role := NEW.raw_user_meta_data->>'role';
  IF raw_role = 'supplier' THEN
    chosen_role := 'supplier'::public.user_role;
  ELSIF raw_role = 'admin' THEN
    chosen_role := 'admin'::public.user_role;
  ELSE
    chosen_role := 'buyer'::public.user_role;
  END IF;

  meta_full_name := COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1));

  -- Insert profile if not exists, or update on conflict
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
    'active'::public.user_status,
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    full_name = COALESCE(public.profiles.full_name, EXCLUDED.full_name),
    updated_at = NOW();

  RETURN NEW;
END;
$$;

-- Drop trigger if exists and recreate
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();
