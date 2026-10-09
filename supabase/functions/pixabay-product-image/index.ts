import { createClient } from 'jsr:@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

function ok(data: unknown) {
  return new Response(JSON.stringify({ code: 'SUCCESS', data }), {
    status: 200,
    headers: { 'Content-Type': 'application/json', ...corsHeaders },
  });
}

function fail(msg: string, code = 400) {
  return new Response(JSON.stringify({ code: 'FAIL', message: msg }), {
    status: code,
    headers: { 'Content-Type': 'application/json', ...corsHeaders },
  });
}

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
);

// Rate-limiting queue: safe throttle for Pixabay API
const RATE_LIMIT_WINDOW_MS = 60000;
const MAX_REQUESTS_PER_WINDOW = 90;
let requestTimestamps: number[] = [];

async function throttlePixabayRequest(): Promise<void> {
  const now = Date.now();
  requestTimestamps = requestTimestamps.filter((t) => now - t < RATE_LIMIT_WINDOW_MS);

  if (requestTimestamps.length >= MAX_REQUESTS_PER_WINDOW) {
    const oldest = requestTimestamps[0];
    const waitTime = oldest + RATE_LIMIT_WINDOW_MS - now + 100;
    if (waitTime > 0) {
      await new Promise((resolve) => setTimeout(resolve, waitTime));
    }
  }
  requestTimestamps.push(Date.now());
}

function hashString(str: string): number {
  let hash = 0;
  for (let i = 0; i < str.length; i++) {
    const char = str.charCodeAt(i);
    hash = (hash << 5) - hash + char;
    hash |= 0;
  }
  return Math.abs(hash);
}

interface NounDefinition {
  noun: string;
  synonyms: string[];
  conflicts: string[];
  preferredAdjective?: string;
  iconName?: string;
}

const PRODUCT_NOUNS_CATALOG: NounDefinition[] = [
  // ── JEWELLERY & GEMS ──────────────────────────────────────────────────
  {
    noun: 'choker',
    synonyms: ['choker', 'chokers', 'necklace', 'necklaces', 'jewellery', 'jewelry', 'pendant'],
    conflicts: ['ring', 'rings', 'earring', 'earrings', 'bangle', 'bangles', 'bracelet', 'bracelets', 'watch'],
    iconName: 'Gem',
  },
  {
    noun: 'necklace',
    synonyms: ['necklace', 'necklaces', 'choker', 'chokers', 'pendant', 'pendants', 'locket', 'jewellery', 'jewelry'],
    conflicts: ['ring', 'rings', 'earring', 'earrings', 'bangle', 'bangles', 'bracelet', 'bracelets', 'watch'],
    iconName: 'Gem',
  },
  {
    noun: 'ring',
    synonyms: ['ring', 'rings', 'finger ring', 'wedding ring', 'diamond ring', 'band', 'jewellery', 'jewelry'],
    conflicts: ['necklace', 'choker', 'earring', 'earrings', 'bangle', 'bracelet', 'pendant'],
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

  // ── MACHINERY, INDUSTRIAL & TOOLS ─────────────────────────────────────
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

  // ── HARDWARE & ELECTRICAL ─────────────────────────────────────────────
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

  // ── TEXTILES & APPAREL ────────────────────────────────────────────────
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

  // ── FURNITURE & HOME ──────────────────────────────────────────────────
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

  // ── FOOD & AGRI ───────────────────────────────────────────────────────
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

  // ── PHARMA & CHEMICALS ────────────────────────────────────────────────
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

function cleanProductTitle(rawTitle: string): string {
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

function buildQueries(title: string): { specificQuery: string; coreNounQuery: string; coreNoun: string; definition: NounDefinition } {
  const cleaned = cleanProductTitle(title);
  const lowerTitle = title.toLowerCase();

  let matchedDef: NounDefinition | undefined;
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

  const remainingAdjectives = cleanedWords.filter(
    w => !coreNounWords.includes(w.toLowerCase()) && w.toLowerCase() !== coreNoun
  );

  let adjective = '';
  if (remainingAdjectives.length > 0) {
    adjective = remainingAdjectives[0].toLowerCase();
  } else if (matchedDef.preferredAdjective) {
    adjective = matchedDef.preferredAdjective;
  }

  const specificQuery = adjective ? `${adjective} ${coreNoun}`.trim() : coreNoun;
  const coreNounQuery = coreNoun;

  return {
    specificQuery,
    coreNounQuery,
    coreNoun,
    definition: matchedDef,
  };
}

interface PixabayHit {
  id: number;
  pageURL?: string;
  type?: string;
  tags: string;
  previewURL?: string;
  webformatURL: string;
  largeImageURL?: string;
  user?: string;
  views?: number;
  downloads?: number;
  likes?: number;
  imageWidth?: number;
  imageHeight?: number;
}

function checkHitRelevance(
  tagsString: string,
  definition: NounDefinition
): { isMatch: boolean; matchedTag: string | null; score: number; rejectionReason?: string } {
  if (!tagsString) {
    return { isMatch: false, matchedTag: null, score: 0, rejectionReason: 'empty_tags' };
  }

  const rawTags = tagsString
    .toLowerCase()
    .split(',')
    .map(t => t.trim())
    .filter(Boolean);

  const allTagWords = rawTags.flatMap(t => t.split(/\s+/));

  // 1. Check conflict tags (Reject hits whose tags contain a different product type)
  for (const conflict of definition.conflicts) {
    const lowerConflict = conflict.toLowerCase().trim();
    if (lowerConflict.includes(' ')) {
      if (tagsString.toLowerCase().includes(lowerConflict)) {
        return {
          isMatch: false,
          matchedTag: null,
          score: -100,
          rejectionReason: `conflicting_type:${conflict}`,
        };
      }
    } else {
      if (allTagWords.includes(lowerConflict) || rawTags.includes(lowerConflict)) {
        if (definition.noun !== lowerConflict && !definition.synonyms.includes(lowerConflict)) {
          return {
            isMatch: false,
            matchedTag: null,
            score: -100,
            rejectionReason: `conflicting_type:${conflict}`,
          };
        }
      }
    }
  }

  // 2. Check for core noun or synonym match in tags
  let matchedTag: string | null = null;
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
    return {
      isMatch: false,
      matchedTag: null,
      score: 0,
      rejectionReason: `missing_core_noun:${definition.noun}`,
    };
  }

  return { isMatch: true, matchedTag, score };
}

// Fetch Pixabay with caching
async function fetchPixabayWithCache(query: string, apiKey: string): Promise<PixabayHit[]> {
  const queryHash = `q_${encodeURIComponent(query.toLowerCase())}`;

  const { data: cached } = await supabase
    .from('pixabay_search_cache')
    .select('results, expires_at')
    .eq('query_hash', queryHash)
    .single();

  if (cached && new Date(cached.expires_at).getTime() > Date.now()) {
    return cached.results as PixabayHit[];
  }

  await throttlePixabayRequest();

  // Use image_type=photo, safesearch=true, per_page=30 as required
  const url = new URL('https://pixabay.com/api/');
  url.searchParams.set('key', apiKey);
  url.searchParams.set('q', query);
  url.searchParams.set('image_type', 'photo');
  url.searchParams.set('safesearch', 'true');
  url.searchParams.set('per_page', '30');

  const resp = await fetch(url.toString());
  if (!resp.ok) {
    throw new Error(`Pixabay API error: ${resp.status}`);
  }

  const json = await resp.json();
  const hits: PixabayHit[] = json.hits || [];

  const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString();
  await supabase
    .from('pixabay_search_cache')
    .upsert({
      query_hash: queryHash,
      query: query,
      results: hits,
      created_at: new Date().toISOString(),
      expires_at: expiresAt,
    });

  return hits;
}

// Download image binary from Pixabay CDN and upload to Supabase Storage
async function downloadAndStoreImage(imageUrl: string, productId: string, hitId: number): Promise<string> {
  const imgRes = await fetch(imageUrl);
  if (!imgRes.ok) {
    throw new Error(`Failed to download Pixabay image: ${imgRes.status}`);
  }

  const arrayBuffer = await imgRes.arrayBuffer();
  const fileBytes = new Uint8Array(arrayBuffer);
  const contentType = imgRes.headers.get('content-type') || 'image/jpeg';
  const ext = contentType.includes('png') ? 'png' : 'jpg';

  const filePath = `representative/${productId}_${hitId}.${ext}`;

  const { error: uploadError } = await supabase.storage
    .from('product-images')
    .upload(filePath, fileBytes, {
      contentType,
      upsert: true,
    });

  if (uploadError) {
    console.error('Storage upload error:', uploadError);
    throw uploadError;
  }

  const { data: urlData } = supabase.storage
    .from('product-images')
    .getPublicUrl(filePath);

  return urlData.publicUrl;
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  if (req.method !== 'POST') return new Response('Method not allowed', { status: 405 });

  const apiKey = Deno.env.get('PIXABAY_API_KEY');
  if (!apiKey) {
    return fail('PIXABAY_API_KEY environment variable is not configured on the backend', 500);
  }

  try {
    const body = await req.json();
    const { action = 'resolve_product_image', product_id, product_name, exclude_urls = [] } = body;

    // Action 1: Search Pixabay
    if (action === 'search_pixabay') {
      const q = cleanProductTitle(product_name || 'industrial');
      const hits = await fetchPixabayWithCache(q, apiKey);
      return ok({
        query: q,
        hits: hits.map(h => ({
          id: h.id,
          previewURL: h.previewURL,
          webformatURL: h.webformatURL,
          largeImageURL: h.largeImageURL,
          tags: h.tags,
          user: h.user,
        })),
        total: hits.length,
      });
    }

    // Action 2: Resolve single product image with strict relevance checking
    if (action === 'resolve_product_image') {
      if (!product_id) return fail('Missing product_id');

      const { data: product } = await supabase
        .from('products')
        .select('id, name, representative_storage_url, is_representative_image, has_seller_images, images, pixabay_asset_id, matched_tag')
        .eq('id', product_id)
        .single();

      // Rule: Never overwrite seller-uploaded photos
      if (product?.has_seller_images && product?.images && product.images.length > 0) {
        return ok({
          source: 'seller',
          url: product.images[0],
          is_representative: false,
          has_image: true,
        });
      }

      // If already stored in storage with verified match tag, return it directly
      if (product?.representative_storage_url && product?.matched_tag) {
        return ok({
          source: 'storage',
          url: product.representative_storage_url,
          pixabay_asset_id: product.pixabay_asset_id,
          matched_tag: product.matched_tag,
          is_representative: true,
          has_image: true,
        });
      }

      const rawTitle = product_name || product?.name || '';
      const { specificQuery, coreNounQuery, definition } = buildQueries(rawTitle);

      const excludeSet = new Set(exclude_urls);

      // Try in order: specific query, then core noun only. Stop at the first result that passes step 2.
      const queriesToTry = [specificQuery];
      if (coreNounQuery !== specificQuery) {
        queriesToTry.push(coreNounQuery);
      }

      let chosenHit: PixabayHit | null = null;
      let chosenTag: string | null = null;
      let chosenQuery: string = specificQuery;

      for (const q of queriesToTry) {
        const hits = await fetchPixabayWithCache(q, apiKey);
        const passingHits: { hit: PixabayHit; matchedTag: string; score: number }[] = [];

        for (const hit of hits) {
          if (excludeSet.has(hit.webformatURL)) continue;

          const res = checkHitRelevance(hit.tags, definition);
          if (res.isMatch && res.matchedTag) {
            let score = res.score;
            const w = hit.imageWidth || 800;
            const h = hit.imageHeight || 600;
            const aspect = w / h;
            if (aspect >= 1.2 && aspect <= 1.8) score += 10;
            if (hit.likes) score += Math.min(10, Math.log10(hit.likes + 1) * 2);
            passingHits.push({ hit, matchedTag: res.matchedTag, score });
          }
        }

        if (passingHits.length > 0) {
          passingHits.sort((a, b) => b.score - a.score);
          const topScore = passingHits[0].score;
          const topTier = passingHits.filter(h => topScore - h.score <= 5);

          // Deterministic pick by hash(product ID)
          const hash = hashString(product_id);
          const selected = topTier[hash % topTier.length];

          chosenHit = selected.hit;
          chosenTag = selected.matchedTag;
          chosenQuery = q;
          break; // Stop at the first query that passes step 2!
        }
      }

      // If no hit passes, show neutral placeholder with product-type icon and "Photo coming soon"
      if (!chosenHit || !chosenTag) {
        return ok({
          source: 'placeholder',
          has_image: false,
          reason: 'no_relevant_hits_passed',
          title: rawTitle,
          query: specificQuery,
        });
      }

      // Download and store in our own Supabase storage
      const downloadTarget = chosenHit.largeImageURL || chosenHit.webformatURL;
      const storedUrl = await downloadAndStoreImage(downloadTarget, product_id, chosenHit.id);

      // Save the result in the database against the product ID
      await supabase
        .from('products')
        .update({
          representative_storage_url: storedUrl,
          is_representative_image: true,
          pixabay_search_query: chosenQuery,
          pixabay_asset_id: String(chosenHit.id),
          matched_tag: chosenTag,
          images: [storedUrl],
        })
        .eq('id', product_id);

      return ok({
        source: 'pixabay_stored',
        url: storedUrl,
        pixabay_asset_id: String(chosenHit.id),
        matched_tag: chosenTag,
        query: chosenQuery,
        is_representative: true,
        has_image: true,
      });
    }

    // Action 3: Debug sample products (for requirement 4)
    if (action === 'debug_sample_products') {
      const { sample_titles = [] } = body;
      const sampleResults = [];

      for (const title of sample_titles) {
        const { specificQuery, coreNounQuery, definition } = buildQueries(title);
        const queries = [specificQuery];
        if (coreNounQuery !== specificQuery) queries.push(coreNounQuery);

        let queryUsed = specificQuery;
        let hits = await fetchPixabayWithCache(specificQuery, apiKey);
        let top3 = hits.slice(0, 3).map(h => ({
          id: h.id,
          tags: h.tags,
          relevance: checkHitRelevance(h.tags, definition),
        }));

        let chosen = null;
        let matchedTag = null;

        // Check hits for specific query
        const passing = top3.filter(h => h.relevance.isMatch);
        if (passing.length > 0) {
          chosen = passing[0];
          matchedTag = passing[0].relevance.matchedTag;
        } else if (coreNounQuery !== specificQuery) {
          // Try core noun query
          queryUsed = coreNounQuery;
          const hits2 = await fetchPixabayWithCache(coreNounQuery, apiKey);
          top3 = hits2.slice(0, 3).map(h => ({
            id: h.id,
            tags: h.tags,
            relevance: checkHitRelevance(h.tags, definition),
          }));
          const passing2 = top3.filter(h => h.relevance.isMatch);
          if (passing2.length > 0) {
            chosen = passing2[0];
            matchedTag = passing2[0].relevance.matchedTag;
          }
        }

        sampleResults.push({
          title,
          queryUsed,
          top3Hits: top3.map(h => ({
            id: h.id,
            tags: h.tags.slice(0, 100) + '...',
            isMatch: h.relevance.isMatch,
            matchedTag: h.relevance.matchedTag,
            rejection: h.relevance.rejectionReason,
          })),
          chosenHitId: chosen ? chosen.id : 'NONE (Placeholder)',
          matchedTag: matchedTag || 'N/A',
        });
      }

      return ok({ sampleResults });
    }

    return fail('Unknown action', 400);
  } catch (err: any) {
    console.error('pixabay-product-image error:', err);
    return fail(err.message || 'Server error', 500);
  }
});
