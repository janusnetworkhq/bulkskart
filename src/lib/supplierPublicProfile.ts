export function supplierPublicPath(slug: string): string {
  return `/companies/${encodeURIComponent(slug)}`;
}

export function supplierPublicUrl(slug: string): string {
  const origin = typeof window !== 'undefined' ? window.location.origin : 'https://www.bulkskart.com';
  return `${origin}${supplierPublicPath(slug)}`;
}

export function buyerPublicPath(slug: string): string {
  return `/buyers/${encodeURIComponent(slug)}`;
}

export function buyerPublicUrl(slug: string): string {
  const origin = typeof window !== 'undefined' ? window.location.origin : 'https://www.bulkskart.com';
  return `${origin}${buyerPublicPath(slug)}`;
}

export async function copyText(value: string): Promise<boolean> {
  try {
    if (navigator.clipboard?.writeText) {
      await navigator.clipboard.writeText(value);
      return true;
    }
  } catch {
    // Fall through to the selection fallback for older mobile browsers.
  }
  try {
    const field = document.createElement('textarea');
    field.value = value;
    field.setAttribute('readonly', '');
    field.style.position = 'fixed';
    field.style.left = '-9999px';
    document.body.appendChild(field);
    field.select();
    const ok = document.execCommand('copy');
    field.remove();
    return ok;
  } catch {
    return false;
  }
}

export function waLink(raw: string): string {
  const digits = raw.replace(/\D/g, '');
  return `https://wa.me/${digits}`;
}

export function telLink(raw: string): string {
  return `tel:${raw.replace(/[^\d+]/g, '')}`;
}
