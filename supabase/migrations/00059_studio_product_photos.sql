-- Replace broken representative photos with licensed square catalog photos.
-- Seller-uploaded images are left unchanged.

CREATE OR REPLACE FUNCTION public.studio_product_photo(product_name text, product_id uuid)
RETURNS text
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
  n text := lower(coalesce(product_name, ''));
  urls text[];
  pick int;
BEGIN
  IF n ~ 'necklace|pendant|bracelet|bangle|jewel|earring' THEN
    urls := ARRAY[
      'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?auto=format&fit=crop&w=640&h=640&q=75&fm=webp',
      'https://images.unsplash.com/photo-1605100804763-247f67b3557e?auto=format&fit=crop&w=640&h=640&q=75&fm=webp'
    ];
  ELSIF n ~ 'tablet|capsule|pharma|medicine' THEN
    urls := ARRAY[
      'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&w=640&h=640&q=75&fm=webp',
      'https://images.unsplash.com/photo-1532187863486-abf9dbad1b69?auto=format&fit=crop&w=640&h=640&q=75&fm=webp'
    ];
  ELSIF n ~ 'denim' THEN
    urls := ARRAY[
      'https://images.unsplash.com/photo-1542272604-787c3835535d?auto=format&fit=crop&w=640&h=640&q=75&fm=webp',
      'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?auto=format&fit=crop&w=640&h=640&q=75&fm=webp'
    ];
  ELSIF n ~ 'fabric|cotton|cloth|weave|silk|yarn|textile|garment' THEN
    urls := ARRAY[
      'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?auto=format&fit=crop&w=640&h=640&q=75&fm=webp',
      'https://images.unsplash.com/photo-1558611848-73f7eb4001a1?auto=format&fit=crop&w=640&h=640&q=75&fm=webp',
      'https://images.unsplash.com/photo-1610030469983-98e550d6193c?auto=format&fit=crop&w=640&h=640&q=75&fm=webp'
    ];
  ELSIF n ~ 'solar|battery|charger|inverter' THEN
    urls := ARRAY[
      'https://images.unsplash.com/photo-1509391366360-2e959784a276?auto=format&fit=crop&w=640&h=640&q=75&fm=webp',
      'https://images.unsplash.com/photo-1613665813446-82a78c468a1d?auto=format&fit=crop&w=640&h=640&q=75&fm=webp',
      'https://images.unsplash.com/photo-1593941707882-a5bba14938c7?auto=format&fit=crop&w=640&h=640&q=75&fm=webp'
    ];
  ELSIF n ~ 'box|pouch|carton|packaging|wrap|corrugat' THEN
    urls := ARRAY[
      'https://images.unsplash.com/photo-1607166452427-7e4477079cb9?auto=format&fit=crop&w=640&h=640&q=75&fm=webp',
      'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?auto=format&fit=crop&w=640&h=640&q=75&fm=webp',
      'https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&w=640&h=640&q=75&fm=webp'
    ];
  ELSIF n ~ 'rice|wheat|seed|spice|grain|tea|coffee|cashew' THEN
    urls := ARRAY[
      'https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&w=640&h=640&q=75&fm=webp',
      'https://images.unsplash.com/photo-1508747703725-719777637510?auto=format&fit=crop&w=640&h=640&q=75&fm=webp',
      'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=640&h=640&q=75&fm=webp',
      'https://images.unsplash.com/photo-1464226184884-fa280b87c399?auto=format&fit=crop&w=640&h=640&q=75&fm=webp'
    ];
  ELSIF n ~ 'granule|polymer|resin|chemical|sodium|hdpe|plastic' THEN
    urls := ARRAY[
      'https://images.unsplash.com/photo-1611273426858-450d8e3c9fce?auto=format&fit=crop&w=640&h=640&q=75&fm=webp',
      'https://images.unsplash.com/photo-1532187863486-abf9dbad1b69?auto=format&fit=crop&w=640&h=640&q=75&fm=webp'
    ];
  ELSIF n ~ 'sensor|circuit|cable|wire|led|electronic|pcb' THEN
    urls := ARRAY[
      'https://images.unsplash.com/photo-1518770660439-4636190af475?auto=format&fit=crop&w=640&h=640&q=75&fm=webp',
      'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=640&h=640&q=75&fm=webp',
      'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?auto=format&fit=crop&w=640&h=640&q=75&fm=webp',
      'https://images.unsplash.com/photo-1621905252507-b35492cc74b4?auto=format&fit=crop&w=640&h=640&q=75&fm=webp'
    ];
  ELSIF n ~ 'filter|valve|pump|bearing|hydraulic|motor|machine|brake|gear|flange' THEN
    urls := ARRAY[
      'https://images.unsplash.com/photo-1565793298595-6a879b1d9492?auto=format&fit=crop&w=640&h=640&q=75&fm=webp',
      'https://images.unsplash.com/photo-1565043589221-1a6fd9ae45c7?auto=format&fit=crop&w=640&h=640&q=75&fm=webp',
      'https://images.unsplash.com/photo-1581094794329-c8112a89af12?auto=format&fit=crop&w=640&h=640&q=75&fm=webp',
      'https://images.unsplash.com/photo-1581092162384-8987c1d64718?auto=format&fit=crop&w=640&h=640&q=75&fm=webp',
      'https://images.unsplash.com/photo-1581092918056-0c4c3acd3789?auto=format&fit=crop&w=640&h=640&q=75&fm=webp',
      'https://images.unsplash.com/photo-1530587191325-3db32d826c18?auto=format&fit=crop&w=640&h=640&q=75&fm=webp'
    ];
  ELSIF n ~ 'ceramic|tile|cement|brick|scaffold' THEN
    urls := ARRAY[
      'https://images.unsplash.com/photo-1503387762-592deb58ef4e?auto=format&fit=crop&w=640&h=640&q=75&fm=webp',
      'https://images.unsplash.com/photo-1504307651254-35680f356dfd?auto=format&fit=crop&w=640&h=640&q=75&fm=webp'
    ];
  ELSIF n ~ 'steel|sheet|pipe|metal|rebar' THEN
    urls := ARRAY[
      'https://images.unsplash.com/photo-1504328345606-18bbc8c9d7d1?auto=format&fit=crop&w=640&h=640&q=75&fm=webp',
      'https://images.unsplash.com/photo-1504307651254-35680f356dfd?auto=format&fit=crop&w=640&h=640&q=75&fm=webp',
      'https://images.unsplash.com/photo-1503387762-592deb58ef4e?auto=format&fit=crop&w=640&h=640&q=75&fm=webp'
    ];
  ELSIF n ~ 'chair|furniture|sofa' OR n ~ '(^|[^a-z])table([^a-z]|$)' THEN
    urls := ARRAY[
      'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?auto=format&fit=crop&w=640&h=640&q=75&fm=webp',
      'https://images.unsplash.com/photo-1567538096630-e0c55bd6374c?auto=format&fit=crop&w=640&h=640&q=75&fm=webp'
    ];
  ELSIF n ~ 'cosmetic|serum|cream|beauty|essential oil' THEN
    urls := ARRAY[
      'https://images.unsplash.com/photo-1608571423902-eed4a5ad8108?auto=format&fit=crop&w=640&h=640&q=75&fm=webp',
      'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?auto=format&fit=crop&w=640&h=640&q=75&fm=webp'
    ];
  ELSIF n ~ 'powder' THEN
    urls := ARRAY[
      'https://images.unsplash.com/photo-1464226184884-fa280b87c399?auto=format&fit=crop&w=640&h=640&q=75&fm=webp',
      'https://images.unsplash.com/photo-1611273426858-450d8e3c9fce?auto=format&fit=crop&w=640&h=640&q=75&fm=webp',
      'https://images.unsplash.com/photo-1532187863486-abf9dbad1b69?auto=format&fit=crop&w=640&h=640&q=75&fm=webp'
    ];
  ELSIF n ~ 'board|panel' THEN
    urls := ARRAY[
      'https://images.unsplash.com/photo-1518770660439-4636190af475?auto=format&fit=crop&w=640&h=640&q=75&fm=webp',
      'https://images.unsplash.com/photo-1473341304170-971dccb5ac1e?auto=format&fit=crop&w=640&h=640&q=75&fm=webp',
      'https://images.unsplash.com/photo-1621905252507-b35492cc74b4?auto=format&fit=crop&w=640&h=640&q=75&fm=webp'
    ];
  ELSE
    urls := ARRAY[
      'https://images.unsplash.com/photo-1565793298595-6a879b1d9492?auto=format&fit=crop&w=640&h=640&q=75&fm=webp',
      'https://images.unsplash.com/photo-1581094794329-c8112a89af12?auto=format&fit=crop&w=640&h=640&q=75&fm=webp',
      'https://images.unsplash.com/photo-1581092162384-8987c1d64718?auto=format&fit=crop&w=640&h=640&q=75&fm=webp',
      'https://images.unsplash.com/photo-1504328345606-18bbc8c9d7d1?auto=format&fit=crop&w=640&h=640&q=75&fm=webp',
      'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?auto=format&fit=crop&w=640&h=640&q=75&fm=webp',
      'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?auto=format&fit=crop&w=640&h=640&q=75&fm=webp'
    ];
  END IF;

  pick := 1 + (get_byte(decode(md5(product_id::text), 'hex'), 0) % cardinality(urls));
  RETURN urls[pick];
END;
$$;

UPDATE public.products
SET
  images = ARRAY[public.studio_product_photo(name, id)],
  representative_storage_url = public.studio_product_photo(name, id),
  is_representative_image = true,
  updated_at = now()
WHERE COALESCE(has_seller_images, false) = false
  AND (
    COALESCE(images[1], '') = ''
    OR images[1] LIKE '%ewnftvshvsrhawluloty%'
    OR images[1] LIKE '%/product-images/representative/%'
  );
