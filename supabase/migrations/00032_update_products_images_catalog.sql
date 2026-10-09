-- Update products with valid high-resolution category images array
UPDATE products SET images = ARRAY['https://miaoda-site-img.s3cdn.medo.dev/images/KLing_19173084-f8d1-4d6c-a8e1-71aad2b17bb7.jpg', 'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_2e96d1eb-1250-4ba3-ab8c-e6669919f2ba.jpg']
WHERE category_id = '158f4042-7fcc-4c77-bcbc-34474341b979' AND (images IS NULL OR array_length(images, 1) = 0 OR images[1] LIKE '%placeholder%');

UPDATE products SET images = ARRAY['https://miaoda-site-img.s3cdn.medo.dev/images/KLing_206d733c-1a07-4864-831d-8d0b40e8d664.jpg', 'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_e1eaec61-9c17-43cf-bf2a-c21d8b67117a.jpg']
WHERE category_id = '1c2f47fd-f313-4d74-932f-c845879987b5' AND (images IS NULL OR array_length(images, 1) = 0 OR images[1] LIKE '%placeholder%');

UPDATE products SET images = ARRAY['https://miaoda-site-img.s3cdn.medo.dev/images/KLing_474d3681-1220-4d6e-81db-de12264ff63a.jpg', 'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_788afc34-8703-44d6-840e-cd5895904a4f.jpg']
WHERE category_id = '4e2b20b8-1d5b-402e-88a9-1c74bd5bcf05' AND (images IS NULL OR array_length(images, 1) = 0 OR images[1] LIKE '%placeholder%');

UPDATE products SET images = ARRAY['https://miaoda-site-img.s3cdn.medo.dev/images/KLing_3dd25eca-4769-4842-bd0b-792905f3b2f3.jpg', 'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_06e7b00f-f9de-49db-a3f9-93c49e1cd41a.jpg']
WHERE category_id = 'd3aafda1-051e-4541-a5bb-20a3b813b2ca' AND (images IS NULL OR array_length(images, 1) = 0 OR images[1] LIKE '%placeholder%');

UPDATE products SET images = ARRAY['https://miaoda-site-img.s3cdn.medo.dev/images/KLing_d6f9b3ff-984e-42e1-a38f-ba8c1a2c5776.jpg', 'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_0fd5c97f-69b3-43ce-af7f-a4fa1212e785.jpg']
WHERE category_id = '96ca9ba3-18d4-4c5a-9955-1d7b941378f2' AND (images IS NULL OR array_length(images, 1) = 0 OR images[1] LIKE '%placeholder%');

UPDATE products SET images = ARRAY['https://miaoda-site-img.s3cdn.medo.dev/images/KLing_ba175bf8-9522-42e1-8d07-eb1a54b79101.jpg', 'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_939772f4-cebe-405f-ad01-e928e119fa36.jpg']
WHERE category_id = 'cb8c4ef8-c360-4e8c-a4fe-32950e554cd7' AND (images IS NULL OR array_length(images, 1) = 0 OR images[1] LIKE '%placeholder%');

UPDATE products SET images = ARRAY['https://miaoda-site-img.s3cdn.medo.dev/images/KLing_7610e66a-3949-479c-8b48-643cc7d2b63f.jpg', 'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_a3c06a3e-6fb3-4ee6-9d59-d44b5fe99f43.jpg']
WHERE category_id = '032caf21-7245-4424-91ad-29c8dd612e4a' AND (images IS NULL OR array_length(images, 1) = 0 OR images[1] LIKE '%placeholder%');

UPDATE products SET images = ARRAY['https://miaoda-site-img.s3cdn.medo.dev/images/KLing_4af11ca3-de8c-4a91-b0d5-7d8e44f2bcbc.jpg', 'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_206d733c-1a07-4864-831d-8d0b40e8d664.jpg']
WHERE category_id = 'f01ebc60-18c5-4e4f-af6f-324020f63252' AND (images IS NULL OR array_length(images, 1) = 0 OR images[1] LIKE '%placeholder%');

UPDATE products SET images = ARRAY['https://miaoda-site-img.s3cdn.medo.dev/images/KLing_22110305-fbda-41c4-a0cc-f053d4a509c6.jpg', 'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_3dd25eca-4769-4842-bd0b-792905f3b2f3.jpg']
WHERE category_id = 'e6fc9bb9-9e94-4ad3-a3d6-2996d9cbd1c5' AND (images IS NULL OR array_length(images, 1) = 0 OR images[1] LIKE '%placeholder%');

UPDATE products SET images = ARRAY['https://miaoda-site-img.s3cdn.medo.dev/images/KLing_06e7b00f-f9de-49db-a3f9-93c49e1cd41a.jpg', 'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_3dd25eca-4769-4842-bd0b-792905f3b2f3.jpg']
WHERE category_id = '99c7dcf5-9dd4-4233-955f-1477c07ff078' AND (images IS NULL OR array_length(images, 1) = 0 OR images[1] LIKE '%placeholder%');

UPDATE products SET images = ARRAY['https://miaoda-site-img.s3cdn.medo.dev/images/KLing_788afc34-8703-44d6-840e-cd5895904a4f.jpg', 'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_0fd5c97f-69b3-43ce-af7f-a4fa1212e785.jpg']
WHERE category_id = 'ede57bc5-1ac8-4fa7-862a-98ac327f3744' AND (images IS NULL OR array_length(images, 1) = 0 OR images[1] LIKE '%placeholder%');

UPDATE products SET images = ARRAY['https://miaoda-site-img.s3cdn.medo.dev/images/KLing_8f7ff817-c708-4f46-993b-c0121cd83e68.jpg', 'https://miaoda-site-img.s3cdn.medo.dev/images/KLing_939772f4-cebe-405f-ad01-e928e119fa36.jpg']
WHERE category_id = '18bd87c0-fa1a-4ef1-93a4-ca10638cf799' AND (images IS NULL OR array_length(images, 1) = 0 OR images[1] LIKE '%placeholder%');
