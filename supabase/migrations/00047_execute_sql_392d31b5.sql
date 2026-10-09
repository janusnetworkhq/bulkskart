CREATE OR REPLACE FUNCTION bulk_update_product_images(
  updates jsonb
) RETURNS int LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  updated_count int;
BEGIN
  WITH data AS (
    SELECT 
      (elem->>'id')::uuid AS id,
      ARRAY(SELECT jsonb_array_elements_text(elem->'images'))::text[] AS images
    FROM jsonb_array_elements(updates) AS elem
  ),
  upd AS (
    UPDATE products AS p
    SET images = d.images
    FROM data AS d
    WHERE p.id = d.id
    RETURNING p.id
  )
  SELECT count(*) INTO updated_count FROM upd;
  
  RETURN updated_count;
END;
$$; GRANT EXECUTE ON FUNCTION bulk_update_product_images(jsonb) TO anon, authenticated, service_role;