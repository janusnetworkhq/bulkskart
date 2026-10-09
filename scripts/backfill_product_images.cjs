const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');

const SUPABASE_URL = 'https://ewnftvshvsrhawluloty.supabase.co';
const SUPABASE_SERVICE_ROLE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV3bmZ0dnNodnNyaGF3bHVsb3R5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODk1NTEyNjcsImV4cCI6MjEwNTEyNzI2N30.To52QykipRLs2KEyWubItKkDNiXazrW1zVJGmqo9B_8';
const PIXABAY_API_KEY = '40187197-ed92faff565f23611446b233b';

const sb = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

const PRODUCT_NOUNS_CATALOG = [
  {
    noun: 'choker',
    synonyms: ['choker', 'chokers', 'necklace', 'necklaces', 'jewellery', 'jewelry', 'pendant'],
    conflicts: ['ring', 'rings', 'earring', 'earrings', 'bangle', 'bangles', 'bracelet', 'bracelets', 'watch', 'animal', 'bird'],
    iconName: 'Gem',
  },
  {
    noun: 'necklace',
    synonyms: ['necklace', 'necklaces', 'choker', 'chokers', 'pendant', 'pendants', 'locket', 'jewellery', 'jewelry'],
    conflicts: ['ring', 'rings', 'earring', 'earrings', 'bangle', 'bangles', 'bracelet', 'bracelets', 'watch', 'animal', 'bird'],
    iconName: 'Gem',
  },
  {
    noun: 'ring',
    synonyms: ['ring', 'rings', 'finger ring', 'wedding ring', 'diamond ring', 'gold ring', 'band', 'jewellery', 'jewelry'],
    conflicts: ['necklace', 'choker', 'earring', 'earrings', 'bangle', 'bracelet', 'pendant', 'animal', 'lemur', 'parakeet', 'bird'],
    iconName: 'Gem',
  },
  {
    noun: 'chain',
    synonyms: ['chain', 'necklace', 'link chain', 'silver chain', 'gold chain', 'jewellery', 'jewelry'],
    conflicts: ['ring', 'earring', 'bangle', 'chainsaw'],
    iconName: 'Gem',
  },
  {
    noun: 'pendant',
    synonyms: ['pendant', 'pendants', 'necklace', 'locket', 'gemstone', 'jewellery', 'jewelry'],
    conflicts: ['ring', 'rings', 'earring', 'earrings', 'bangle'],
    iconName: 'Gem',
  },
  {
    noun: 'earring',
    synonyms: ['earring', 'earrings', 'ear stud', 'ear studs', 'jhumka', 'jewellery', 'jewelry'],
    conflicts: ['necklace', 'choker', 'ring', 'bangle', 'bracelet'],
    iconName: 'Gem',
  },
  {
    noun: 'bangle',
    synonyms: ['bangle', 'bangles', 'bracelet', 'bracelets', 'wristband', 'jewellery'],
    conflicts: ['necklace', 'choker', 'ring', 'earring'],
    iconName: 'Gem',
  },
  {
    noun: 'bracelet',
    synonyms: ['bracelet', 'bracelets', 'bangle', 'bangles', 'wristband', 'jewellery', 'jewelry'],
    conflicts: ['necklace', 'choker', 'ring', 'earring'],
    iconName: 'Gem',
  },
  {
    noun: 'forklift',
    synonyms: ['forklift', 'fork lift', 'stacker', 'pallet jack', 'warehouse truck', 'reach truck', 'lifting equipment'],
    conflicts: ['car', 'motorcycle', 'airplane', 'bicycle'],
    iconName: 'Cog',
  },
  {
    noun: 'press',
    synonyms: ['hydraulic', 'press machine', 'industrial press', 'machinery', 'stamping'],
    conflicts: ['newspaper', 'news', 'journalism', 'press conference', 'ironing', 'laundry', 'clothes'],
    iconName: 'Cog',
  },
  {
    noun: 'blower',
    synonyms: ['blower', 'industrial blower', 'ventilation fan', 'exhaust fan', 'centrifugal fan', 'blower fan'],
    conflicts: ['leaf blower', 'snow blower'],
    iconName: 'Cog',
  },
  {
    noun: 'pump',
    synonyms: ['pump', 'water pump', 'feed pump', 'centrifugal pump', 'impeller', 'hydraulic pump', 'industrial pump'],
    conflicts: ['shoe', 'shoes', 'high heels', 'heels', 'stiletto', 'fashion'],
    iconName: 'Cog',
  },
  {
    noun: 'motor',
    synonyms: ['motor', 'electric motor', 'engine', 'servo motor', 'gear motor', 'induction motor', 'rotor', 'stator'],
    conflicts: ['scooter', 'motorcycle', 'car', 'vehicle', 'bike', 'moped'],
    iconName: 'Cpu',
  },
  {
    noun: 'transformer',
    synonyms: ['transformer', 'power transformer', 'electrical transformer', 'substation', 'high voltage', 'electrical substation'],
    conflicts: ['robot', 'optimus', 'toy', 'movie', 'autobot', 'decepticon', 'action figure'],
    iconName: 'Cpu',
  },
  {
    noun: 'inverter',
    synonyms: ['inverter', 'vfd', 'frequency converter', 'frequency drive', 'motor drive', 'variable frequency drive', 'electrical drive'],
    conflicts: ['solar panel on roof', 'residential roof'],
    iconName: 'Cpu',
  },
  {
    noun: 'rotor',
    synonyms: ['brake rotor', 'disc brake', 'brake disc', 'rotor', 'brakes', 'caliper'],
    conflicts: ['helicopter', 'drone', 'quadcopter', 'aircraft'],
    iconName: 'Cog',
  },
  {
    noun: 'pipe',
    synonyms: ['pipe', 'pipes', 'tube', 'tubes', 'piping', 'conduit', 'plumbing pipe', 'pvc pipe', 'steel pipe'],
    conflicts: ['smoking', 'tobacco', 'cigar', 'pipe smoking', 'smoker'],
    iconName: 'HardHat',
  },
  {
    noun: 'wire',
    synonyms: ['wire', 'copper wire', 'electrical wire', 'wires', 'cable', 'cables', 'copper cable'],
    conflicts: ['fence', 'barbed wire', 'suspension bridge', 'wire mesh fence'],
    iconName: 'Cpu',
  },
  {
    noun: 'cable',
    synonyms: ['cable', 'cables', 'electrical cable', 'power cable', 'copper wire', 'wire'],
    conflicts: ['suspension bridge', 'cable car', 'ski lift'],
    iconName: 'Cpu',
  },
  {
    noun: 'sensor',
    synonyms: ['sensor', 'electronic sensor', 'proximity sensor', 'transducer', 'detector', 'electronics'],
    conflicts: [],
    iconName: 'Cpu',
  },
  {
    noun: 'switch',
    synonyms: ['switch', 'electrical switch', 'toggle switch', 'push button', 'circuit breaker'],
    conflicts: ['nintendo', 'nintendo switch', 'video game'],
    iconName: 'Cpu',
  },
  {
    noun: 'panel',
    synonyms: ['solar panel', 'solar panels', 'solar module', 'photovoltaic', 'electrical panel'],
    conflicts: ['comic panel'],
    iconName: 'Sun',
  },
  {
    noun: 'fabric',
    synonyms: ['fabric', 'fabrics', 'textile', 'textiles', 'cloth', 'cotton fabric', 'silk fabric', 'material', 'texture', 'weave', 'yarn', 'textile roll'],
    conflicts: ['portrait', 'model', 'sexy', 'woman portrait', 'man portrait', 'face', 'bikini'],
    iconName: 'Shirt',
  },
  {
    noun: 'cloth',
    synonyms: ['cloth', 'fabric', 'textile', 'material', 'cotton cloth', 'texture', 'weave'],
    conflicts: ['portrait', 'model', 'sexy', 'woman face'],
    iconName: 'Shirt',
  },
  {
    noun: 'jersey',
    synonyms: ['jersey', 'cotton jersey', 'fabric', 'textile', 'cloth', 'knit fabric'],
    conflicts: ['football player', 'basketball player', 'soccer', 'sports jersey'],
    iconName: 'Shirt',
  },
  {
    noun: 'curtain',
    synonyms: ['curtain', 'curtains', 'drape', 'drapery', 'drapes', 'window curtain'],
    conflicts: ['shower curtain', 'bed', 'carpet', 'pillow'],
    iconName: 'Box',
  },
  {
    noun: 'shawl',
    synonyms: ['shawl', 'shawls', 'scarf', 'stole', 'wrap', 'wool shawl', 'cashmere'],
    conflicts: ['blanket', 'towel', 'bedsheet'],
    iconName: 'Shirt',
  },
  {
    noun: 'kurta',
    synonyms: ['kurta', 'kurtas', 'tunic', 'shirt', 'clothing', 'apparel', 'ethnic wear'],
    conflicts: ['shoes', 'trousers', 'pants'],
    iconName: 'Shirt',
  },
  {
    noun: 'shoes',
    synonyms: ['shoe', 'shoes', 'footwear', 'leather shoes', 'slippers', 'loafers', 'sandals'],
    conflicts: ['horse', 'horseshoe', 'shirt', 'dress'],
    iconName: 'Shirt',
  },
  {
    noun: 'bed',
    synonyms: ['bed', 'beds', 'bed frame', 'bedroom', 'wooden bed', 'mattress', 'headboard'],
    conflicts: ['hospital bed', 'flower bed', 'river bed', 'chair', 'sofa'],
    iconName: 'Box',
  },
  {
    noun: 'table',
    synonyms: ['table', 'tables', 'dining table', 'wooden table', 'desk', 'furniture'],
    conflicts: ['periodic table', 'table tennis', 'ping pong', 'chair only'],
    iconName: 'Box',
  },
  {
    noun: 'tray',
    synonyms: ['tray', 'trays', 'serving tray', 'wooden tray', 'bamboo tray', 'platter'],
    conflicts: ['ashtray', 'baking tray', 'ice cube tray'],
    iconName: 'Box',
  },
  {
    noun: 'runner',
    synonyms: ['runner', 'table runner', 'tablecloth', 'linen runner', 'dining table'],
    conflicts: ['athlete', 'marathon', 'running', 'jogger', 'runner sprinting'],
    iconName: 'Box',
  },
  {
    noun: 'catcher',
    synonyms: ['dream catcher', 'dreamcatcher', 'feathers', 'craft', 'handmade'],
    conflicts: ['baseball', 'baseball catcher'],
    iconName: 'Sparkles',
  },
  {
    noun: 'sculpture',
    synonyms: ['sculpture', 'sculptures', 'statue', 'statues', 'stone sculpture', 'carving'],
    conflicts: [],
    iconName: 'Sparkles',
  },
  {
    noun: 'coasters',
    synonyms: ['coasters', 'coaster', 'drink coasters', 'cup coasters', 'felt coasters'],
    conflicts: ['roller coaster'],
    iconName: 'Box',
  },
  {
    noun: 'oil',
    synonyms: ['oil', 'sesame oil', 'cooking oil', 'vegetable oil', 'olive oil', 'oil bottle'],
    conflicts: ['motor oil', 'engine oil', 'car oil', 'petrol', 'crude oil', 'oil spill'],
    iconName: 'Wheat',
  },
  {
    noun: 'rice',
    synonyms: ['rice', 'raw rice', 'rice grain', 'grains', 'basmati', 'white rice', 'cereal'],
    conflicts: ['cooked rice', 'fried rice', 'sushi', 'soup', 'bowl of cooked rice'],
    iconName: 'Wheat',
  },
  {
    noun: 'chilli',
    synonyms: ['chilli', 'chili', 'chilli powder', 'red chilli', 'paprika', 'spice', 'spices', 'red pepper'],
    conflicts: ['face powder', 'snow', 'cosmetics'],
    iconName: 'Wheat',
  },
  {
    noun: 'spice',
    synonyms: ['spice', 'spices', 'seasoning', 'coriander', 'cumin', 'cardamom', 'turmeric'],
    conflicts: ['spice girls'],
    iconName: 'Wheat',
  },
  {
    noun: 'cardamom',
    synonyms: ['cardamom', 'cardamon', 'spice', 'spices', 'green cardamom', 'pods'],
    conflicts: [],
    iconName: 'Wheat',
  },
  {
    noun: 'cashew',
    synonyms: ['cashew', 'cashews', 'cashew nuts', 'nut', 'nuts', 'raw cashew'],
    conflicts: [],
    iconName: 'Wheat',
  },
  {
    noun: 'lentils',
    synonyms: ['lentils', 'dal', 'pulses', 'beans', 'legumes', 'grain'],
    conflicts: ['cooked dal', 'soup'],
    iconName: 'Wheat',
  },
  {
    noun: 'flour',
    synonyms: ['flour', 'wheat flour', 'grain flour', 'baking flour', 'cereal'],
    conflicts: ['flower', 'flowers'],
    iconName: 'Wheat',
  },
  {
    noun: 'seeds',
    synonyms: ['seeds', 'seed', 'sesame seed', 'grain', 'planting seeds', 'agriculture'],
    conflicts: [],
    iconName: 'Wheat',
  },
  {
    noun: 'tablets',
    synonyms: ['tablet', 'tablets', 'pill', 'pills', 'medicine', 'medication', 'pharmacy', 'pharmaceutical', 'capsule'],
    conflicts: ['ipad', 'android tablet', 'computer tablet', 'digital tablet', 'graphic tablet', 'screen'],
    iconName: 'FlaskConical',
  },
  {
    noun: 'capsules',
    synonyms: ['capsule', 'capsules', 'softgel', 'softgels', 'pill', 'pills', 'vitamin', 'vitamins', 'supplement'],
    conflicts: ['space capsule', 'time capsule', 'coffee capsule'],
    iconName: 'FlaskConical',
  },
  {
    noun: 'bandage',
    synonyms: ['bandage', 'bandages', 'crepe bandage', 'gauze', 'dressing', 'medical dressing', 'first aid'],
    conflicts: [],
    iconName: 'FlaskConical',
  },
  {
    noun: 'granules',
    synonyms: ['granules', 'plastic granules', 'pellets', 'polymer pellets', 'plastic raw material', 'resin'],
    conflicts: [],
    iconName: 'FlaskConical',
  },
  {
    noun: 'bottle',
    synonyms: ['bottle', 'bottles', 'plastic bottle', 'pet bottle', 'container', 'bottle preform'],
    conflicts: ['wine bottle', 'beer bottle', 'whiskey', 'alcohol'],
    iconName: 'Box',
  },
  {
    noun: 'acid',
    synonyms: ['acid', 'chemical', 'chemicals', 'laboratory', 'liquid flask', 'laboratory chemical'],
    conflicts: ['lsd'],
    iconName: 'FlaskConical',
  },
];

function hashString(str) {
  let hash = 0;
  for (let i = 0; i < str.length; i++) {
    const char = str.charCodeAt(i);
    hash = (hash << 5) - hash + char;
    hash |= 0;
  }
  return Math.abs(hash);
}

function cleanProductTitle(rawTitle) {
  if (!rawTitle) return '';
  return rawTitle
    .replace(/\b(batch|lot|ref|sku|code|art|model|pno|cat|part)\s*#?[a-z0-9_-]+/gi, ' ')
    .replace(/\b(p|mk|fl)\s*#?\d+[a-z0-9_-]*/gi, ' ')
    .replace(/#\s*\d+/gi, ' ')
    .replace(/\b\d+(\.\d+)?\s*(mm|cm|m|meter|meters|inch|inches|kg|g|gm|mg|ton|tons|tonne|hp|kw|kva|w|watt|watts|v|volt|volts|a|amp|amps|ah|mah|nm|ml|l|ltr|oz|lb|lbs|psi|bar|rpm|gsm|sq|deg|gauge)\b/gi, ' ')
    .replace(/\b\d+x\d+(\w+)?\b/gi, ' ')
    .replace(/\b\d+%\b/gi, ' ')
    .replace(/\b\d+\b/gi, ' ')
    .replace(/\b(grade|pure|virgin|raw|heavy|duty|industrial|commercial|high|quality|premium|wholesale|bulk|pack|lot|set|piece|pieces|pcs|custom|standard|export|domestic|brand|new|genuine|best|fine|seater|king|queen|double|single|size|extra|bold|top|style|look|hand-loomed|cold pressed|vented|adjustable)\b/gi, ' ')
    .replace(/[^\w\s-]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

function buildQueries(title) {
  const cleaned = cleanProductTitle(title);
  const lowerTitle = title.toLowerCase();

  let matchedDef = null;
  for (const def of PRODUCT_NOUNS_CATALOG) {
    const regex = new RegExp(`\\b${def.noun}s?\\b`, 'i');
    if (regex.test(lowerTitle)) {
      matchedDef = def;
      break;
    }
  }

  if (!matchedDef) {
    const cleanedWords = cleaned.split(' ').filter(w => w.length > 2);
    const fallbackNoun = cleanedWords.length > 0 ? cleanedWords[cleanedWords.length - 1].toLowerCase() : 'product';
    matchedDef = {
      noun: fallbackNoun,
      synonyms: [fallbackNoun],
      conflicts: [],
      iconName: 'Package',
    };
  }

  const coreNoun = matchedDef.noun;
  const coreNounWords = coreNoun.split(' ');
  const cleanedWords = cleaned.split(' ').filter(w => w.length > 1);

  const priorityAdjectives = ['diamond', 'gold', 'choker', 'hydraulic', 'electric', 'servo', 'sesame', 'cotton', 'silk', 'conduit', 'diesel', 'solar', 'teak'];
  let chosenAdj = '';
  for (const padj of priorityAdjectives) {
    if (lowerTitle.includes(padj) && padj !== coreNoun) {
      chosenAdj = padj;
      break;
    }
  }

  if (!chosenAdj) {
    const remainingAdjectives = cleanedWords.filter(
      w => !coreNounWords.includes(w.toLowerCase()) && w.toLowerCase() !== coreNoun
    );
    if (remainingAdjectives.length > 0) {
      chosenAdj = remainingAdjectives[0].toLowerCase();
    }
  }

  const specificQuery = chosenAdj ? `${chosenAdj} ${coreNoun}`.trim() : coreNoun;
  const coreNounQuery = coreNoun;

  return {
    specificQuery,
    coreNounQuery,
    coreNoun,
    definition: matchedDef,
  };
}

function checkHitRelevance(tagsString, definition) {
  if (!tagsString) {
    return { isMatch: false, matchedTag: null, score: 0, rejectionReason: 'empty_tags' };
  }

  const rawTags = tagsString
    .toLowerCase()
    .split(',')
    .map(t => t.trim())
    .filter(Boolean);

  const allTagWords = rawTags.flatMap(t => t.split(/\s+/));

  for (const conflict of definition.conflicts) {
    const lowerConflict = conflict.toLowerCase().trim();
    if (lowerConflict.includes(' ')) {
      if (tagsString.toLowerCase().includes(lowerConflict)) {
        return { isMatch: false, matchedTag: null, score: -100, rejectionReason: `conflicting_type:${conflict}` };
      }
    } else {
      if (allTagWords.includes(lowerConflict) || rawTags.includes(lowerConflict)) {
        if (definition.noun !== lowerConflict && !definition.synonyms.includes(lowerConflict)) {
          return { isMatch: false, matchedTag: null, score: -100, rejectionReason: `conflicting_type:${conflict}` };
        }
      }
    }
  }

  let matchedTag = null;
  let score = 0;

  for (const syn of definition.synonyms) {
    const lowerSyn = syn.toLowerCase().trim();
    if (rawTags.includes(lowerSyn)) {
      matchedTag = lowerSyn;
      score += 50;
      break;
    }
  }

  if (!matchedTag) {
    for (const syn of definition.synonyms) {
      const lowerSyn = syn.toLowerCase().trim();
      if (allTagWords.includes(lowerSyn)) {
        matchedTag = lowerSyn;
        score += 30;
        break;
      }
    }
  }

  if (!matchedTag) {
    for (const syn of definition.synonyms) {
      const lowerSyn = syn.toLowerCase().trim();
      if (tagsString.toLowerCase().includes(lowerSyn)) {
        matchedTag = lowerSyn;
        score += 20;
        break;
      }
    }
  }

  if (!matchedTag) {
    return { isMatch: false, matchedTag: null, score: 0, rejectionReason: `missing_core_noun:${definition.noun}` };
  }

  return { isMatch: true, matchedTag, score };
}

const searchCache = new Map();

async function searchPixabay(query) {
  const q = query.toLowerCase().trim();
  if (searchCache.has(q)) {
    return searchCache.get(q);
  }

  await new Promise(r => setTimeout(r, 650));

  const url = `https://pixabay.com/api/?key=${PIXABAY_API_KEY}&q=${encodeURIComponent(q)}&image_type=photo&safesearch=true&per_page=30`;
  const res = await fetch(url);
  if (!res.ok) {
    console.error(`Pixabay search failed for "${q}": HTTP ${res.status}`);
    return [];
  }

  const json = await res.json();
  const hits = json.hits || [];
  searchCache.set(q, hits);
  return hits;
}

// Download image binary by hit.id and store in Supabase Storage
// Map of hitId -> storageUrl to eliminate redundant storage uploads!
const storageUrlCache = new Map();

async function getOrStoreImage(hit) {
  if (storageUrlCache.has(hit.id)) {
    return storageUrlCache.get(hit.id);
  }

  const imageUrl = hit.largeImageURL || hit.webformatURL;
  const imgRes = await fetch(imageUrl);
  if (!imgRes.ok) throw new Error(`Fetch image failed: ${imgRes.status}`);

  const buffer = await imgRes.arrayBuffer();
  const fileBytes = Buffer.from(buffer);
  const contentType = imgRes.headers.get('content-type') || 'image/jpeg';
  const ext = contentType.includes('png') ? 'png' : 'jpg';
  const filePath = `representative/pixabay_${hit.id}.${ext}`;

  const { error: uploadError } = await sb.storage
    .from('product-images')
    .upload(filePath, fileBytes, {
      contentType,
      upsert: true,
    });

  if (uploadError) throw uploadError;

  const { data: urlData } = sb.storage
    .from('product-images')
    .getPublicUrl(filePath);

  storageUrlCache.set(hit.id, urlData.publicUrl);
  return urlData.publicUrl;
}

async function runBackfill() {
  console.log('--- Starting BulkSkart Fast Backfill ---');

  const { data: products, error } = await sb
    .from('products')
    .select('id, name, has_seller_images, images, representative_storage_url, is_representative_image')
    .order('created_at', { ascending: false });

  if (error) {
    console.error('Error fetching products:', error);
    process.exit(1);
  }

  console.log(`Fetched ${products.length} products to evaluate.`);

  // 1. Collect all required search queries across products
  const querySet = new Set();
  const productPlan = [];

  for (const prod of products) {
    if (prod.has_seller_images && prod.images && prod.images.length > 0) {
      productPlan.push({ prod, skip: true });
      continue;
    }

    const { specificQuery, coreNounQuery, definition } = buildQueries(prod.name);
    querySet.add(specificQuery);
    if (coreNounQuery !== specificQuery) querySet.add(coreNounQuery);

    productPlan.push({
      prod,
      skip: false,
      specificQuery,
      coreNounQuery,
      definition,
    });
  }

  console.log(`Found ${querySet.size} unique Pixabay queries across all products.`);

  // 2. Pre-fetch queries with Pixabay API rate limiting
  let qIdx = 0;
  for (const q of querySet) {
    qIdx++;
    process.stdout.write(`Fetching queries: ${qIdx}/${querySet.size} ("${q}")\r`);
    await searchPixabay(q);
  }
  console.log(`\nAll ${querySet.size} queries successfully fetched & cached.`);

  const debugSampleProducts = [
    'Meenakari Choker Necklace SKU155',
    'Polki Diamond Look Ring SKU66',
    'Electric Motor 1HP #296',
    'Hydraulic Press 50 Ton Mk121',
    'Conduit Pipe 25mm #119',
    'Sesame Oil Cold Pressed Batch164',
    'Solid Wood Dining Table 6 Seater #30',
    'Sona Masoori Rice Bulk Batch211',
    'Ibuprofen 400mg Tablets Batch7',
    'Forklift Diesel 3 Ton FL-30',
  ];
  const debugReport = [];

  let updatedCount = 0;
  let placeholderCount = 0;
  let skippedSellerCount = 0;

  // 3. Process products in parallel batches of 25
  const BATCH_SIZE = 25;
  for (let i = 0; i < productPlan.length; i += BATCH_SIZE) {
    const chunk = productPlan.slice(i, i + BATCH_SIZE);

    await Promise.all(
      chunk.map(async (item) => {
        if (item.skip) {
          skippedSellerCount++;
          return;
        }

        const { prod, specificQuery, coreNounQuery, definition } = item;
        const queries = [specificQuery];
        if (coreNounQuery !== specificQuery) queries.push(coreNounQuery);

        let chosenHit = null;
        let chosenTag = null;
        let chosenQuery = specificQuery;
        let top3ForDebug = [];

        for (const q of queries) {
          const hits = searchCache.get(q.toLowerCase().trim()) || [];
          const passing = [];

          for (const h of hits) {
            const check = checkHitRelevance(h.tags, definition);
            if (check.isMatch && check.matchedTag) {
              let score = check.score;
              const w = h.imageWidth || 800;
              const hgt = h.imageHeight || 600;
              const aspect = w / hgt;
              if (aspect >= 1.2 && aspect <= 1.8) score += 10;
              if (h.likes) score += Math.min(10, Math.log10(h.likes + 1) * 2);
              passing.push({ hit: h, matchedTag: check.matchedTag, score });
            }
          }

          if (top3ForDebug.length === 0) {
            top3ForDebug = hits.slice(0, 3).map(h => ({
              id: h.id,
              tags: h.tags,
              check: checkHitRelevance(h.tags, definition),
            }));
          }

          if (passing.length > 0) {
            passing.sort((a, b) => b.score - a.score);
            const topScore = passing[0].score;
            const topTier = passing.filter(p => topScore - p.score <= 5);
            const hash = hashString(prod.id);
            const selected = topTier[hash % topTier.length];

            chosenHit = selected.hit;
            chosenTag = selected.matchedTag;
            chosenQuery = q;
            break;
          }
        }

        const isSample = debugSampleProducts.some(sample => prod.name.toLowerCase().includes(sample.toLowerCase().slice(0, 15)));
        if (isSample && debugReport.length < 10) {
          debugReport.push({
            productId: prod.id,
            title: prod.name,
            queryUsed: chosenHit ? chosenQuery : specificQuery,
            top3Hits: top3ForDebug.map(t => ({
              id: t.id,
              tags: (t.tags || '').slice(0, 80) + '...',
              isMatch: t.check.isMatch,
              matchedTag: t.check.matchedTag,
              rejection: t.check.rejectionReason,
            })),
            chosenHitId: chosenHit ? chosenHit.id : 'NONE (Placeholder)',
            matchedTag: chosenTag || 'N/A',
          });
        }

        if (chosenHit && chosenTag) {
          try {
            const storedUrl = await getOrStoreImage(chosenHit);

            await sb
              .from('products')
              .update({
                images: [storedUrl],
                representative_storage_url: storedUrl,
                is_representative_image: true,
                pixabay_asset_id: String(chosenHit.id),
                pixabay_search_query: chosenQuery,
                matched_tag: chosenTag,
              })
              .eq('id', prod.id);

            updatedCount++;
          } catch (err) {
            console.error(`Error saving image for product ${prod.id}:`, err.message);
          }
        } else {
          await sb
            .from('products')
            .update({
              images: [],
              representative_storage_url: null,
              is_representative_image: false,
              pixabay_asset_id: null,
              pixabay_search_query: specificQuery,
              matched_tag: null,
            })
            .eq('id', prod.id);

          placeholderCount++;
        }
      })
    );

    process.stdout.write(`Database updated: ${Math.min(i + BATCH_SIZE, productPlan.length)}/${productPlan.length}\r`);
  }

  console.log('\n\n--- Backfill Finished Successfully ---');
  console.log(`Total products: ${products.length}`);
  console.log(`Updated with verified Pixabay stored images: ${updatedCount}`);
  console.log(`Neutral placeholder ("Photo coming soon"): ${placeholderCount}`);
  console.log(`Skipped seller images: ${skippedSellerCount}`);

  fs.writeFileSync('./debug_sample_report.json', JSON.stringify(debugReport, null, 2));
  console.log('Saved debug sample report to ./debug_sample_report.json');
}

runBackfill();
