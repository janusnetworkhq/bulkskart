CREATE TABLE IF NOT EXISTS _backup_products_20261001 AS SELECT *
FROM products; CREATE TABLE IF NOT EXISTS _backup_auth_users_20261001 AS SELECT
  id,
  email,
  created_at,
  role
FROM auth.users;