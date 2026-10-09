import { supabase } from '@/db/supabase';

export interface CompressionResult {
  file: File;
  compressed: boolean;
  originalSize: number;
  newSize: number;
}

/**
 * Compresses an image client-side to WEBP format, max 1080p resolution, with iterative quality reduction if needed.
 */
export async function compressImage(
  file: File,
  options: {
    maxWidth?: number;
    maxHeight?: number;
    initialQuality?: number;
    maxSizeBytes?: number;
  } = {}
): Promise<CompressionResult> {
  const {
    maxWidth = 1920,
    maxHeight = 1080,
    initialQuality = 0.82,
    maxSizeBytes = 1024 * 1024, // 1MB
  } = options;

  // Don't compress non-image or SVG/GIF files
  if (!file.type.startsWith('image/') || file.type === 'image/svg+xml' || file.type === 'image/gif') {
    return { file, compressed: false, originalSize: file.size, newSize: file.size };
  }

  // If already under 800KB and in a modern format, keep as is unless resizing needed
  if (file.size <= 800 * 1024 && (file.type === 'image/webp' || file.type === 'image/png')) {
    return { file, compressed: false, originalSize: file.size, newSize: file.size };
  }

  return new Promise((resolve) => {
    const img = new Image();
    const objectUrl = URL.createObjectURL(file);

    img.onload = async () => {
      URL.revokeObjectURL(objectUrl);
      let width = img.width;
      let height = img.height;

      // Scale to fit within maxWidth x maxHeight while keeping aspect ratio
      if (width > maxWidth || height > maxHeight) {
        const ratio = Math.min(maxWidth / width, maxHeight / height);
        width = Math.round(width * ratio);
        height = Math.round(height * ratio);
      }

      const canvas = document.createElement('canvas');
      canvas.width = width;
      canvas.height = height;
      const ctx = canvas.getContext('2d');

      if (!ctx) {
        resolve({ file, compressed: false, originalSize: file.size, newSize: file.size });
        return;
      }

      // Fill white background for transparent PNGs converted to JPEG/WEBP if needed
      ctx.fillStyle = '#FFFFFF';
      ctx.fillRect(0, 0, width, height);
      ctx.drawImage(img, 0, 0, width, height);

      let quality = initialQuality;
      let blob: Blob | null = null;

      // Try WEBP first, fallback to JPEG
      const mimeType = 'image/webp';

      const exportBlob = (q: number): Promise<Blob | null> => {
        return new Promise((res) => {
          canvas.toBlob((b) => res(b), mimeType, q);
        });
      };

      blob = await exportBlob(quality);

      // Iteratively reduce quality if still over maxSizeBytes
      let attempts = 0;
      while (blob && blob.size > maxSizeBytes && quality > 0.4 && attempts < 4) {
        quality -= 0.15;
        attempts++;
        blob = await exportBlob(quality);
      }

      if (blob && (blob.size < file.size || width < img.width || height < img.height)) {
        const sanitizedName = file.name
          .replace(/\.[^/.]+$/, '')
          .replace(/[^a-zA-Z0-9]/g, '_')
          .slice(0, 30);
        const newFile = new File([blob], `${sanitizedName}.webp`, { type: 'image/webp' });
        resolve({
          file: newFile,
          compressed: true,
          originalSize: file.size,
          newSize: newFile.size,
        });
      } else {
        resolve({ file, compressed: false, originalSize: file.size, newSize: file.size });
      }
    };

    img.onerror = () => {
      URL.revokeObjectURL(objectUrl);
      resolve({ file, compressed: false, originalSize: file.size, newSize: file.size });
    };

    img.src = objectUrl;
  });
}

/**
 * Format bytes to readable string (e.g., "450 KB", "1.2 MB")
 */
export function formatBytes(bytes: number, decimals = 1): string {
  if (bytes === 0) return '0 B';
  const k = 1024;
  const dm = decimals < 0 ? 0 : decimals;
  const sizes = ['B', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
}

export type StorageBucket = 'product-images' | 'company-assets' | 'rfq-images' | 'avatars' | 'verification-docs' | 'attachments';

export interface UploadOptions {
  bucket?: StorageBucket;
  folder?: string;
  autoCompress?: boolean;
  maxSizeBytes?: number;
  onProgress?: (percentage: number) => void;
}

export interface UploadResult {
  url: string;
  path: string;
  compressed: boolean;
  originalSize: number;
  newSize: number;
}

/**
 * Upload an image to Supabase Storage with automatic compression and public URL generation
 */
export async function uploadImage(
  file: File,
  options: UploadOptions = {}
): Promise<UploadResult> {
  const {
    bucket = 'product-images',
    folder = '',
    autoCompress = true,
    maxSizeBytes = 1024 * 1024 * 5, // 5MB max raw
  } = options;

  // Validate format
  const validTypes = ['image/jpeg', 'image/png', 'image/webp', 'image/gif', 'image/avif', 'image/svg+xml'];
  if (!validTypes.includes(file.type)) {
    throw new Error('Unsupported image format. Please upload JPG, PNG, WEBP, or GIF.');
  }

  if (file.size > maxSizeBytes) {
    throw new Error(`File is too large (${formatBytes(file.size)}). Max allowed is ${formatBytes(maxSizeBytes)}.`);
  }

  // Compress if needed
  let fileToUpload = file;
  let wasCompressed = false;
  const originalSize = file.size;
  let newSize = file.size;

  if (autoCompress && file.type !== 'image/svg+xml') {
    const comp = await compressImage(file);
    fileToUpload = comp.file;
    wasCompressed = comp.compressed;
    newSize = comp.newSize;
  }

  // Generate safe filename
  const cleanBase = fileToUpload.name
    .replace(/\.[^/.]+$/, '')
    .replace(/[^a-zA-Z0-9]/g, '_')
    .slice(0, 30);
  const ext = fileToUpload.name.split('.').pop()?.toLowerCase() || 'webp';
  const timestamp = Date.now();
  const randomStr = Math.random().toString(36).substring(2, 8);
  const filePath = folder
    ? `${folder.replace(/^\/+|\/+$/g, '')}/${cleanBase}_${timestamp}_${randomStr}.${ext}`
    : `${cleanBase}_${timestamp}_${randomStr}.${ext}`;

  // Upload to Supabase
  const { error: uploadError } = await supabase.storage
    .from(bucket)
    .upload(filePath, fileToUpload, {
      cacheControl: '31536000',
      upsert: true,
    });

  if (uploadError) {
    console.error('Storage upload error:', uploadError);
    throw new Error(uploadError.message || 'Failed to upload image to storage.');
  }

  // Retrieve public URL
  const { data: publicData } = supabase.storage.from(bucket).getPublicUrl(filePath);

  return {
    url: publicData.publicUrl,
    path: filePath,
    compressed: wasCompressed,
    originalSize,
    newSize,
  };
}
