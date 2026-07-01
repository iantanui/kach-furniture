"use client";

import { useState, useCallback } from "react";
import Image from "next/image";
import { X, Upload, Loader2 } from "lucide-react";

export interface UploadedImage {
  url: string;
  publicId: string;
}

interface Props {
  images: UploadedImage[];
  onChange: (images: UploadedImage[]) => void;
  maxImages?: number;
}

export function ImageUploader({ images, onChange, maxImages = 8 }: Props) {
  const [uploading, setUploading] = useState(false);
  const [progress, setProgress] = useState(0);

  const uploadFiles = useCallback(
    async (files: FileList) => {
      if (images.length + files.length > maxImages) {
        alert(`Max ${maxImages} images allowed`);
        return;
      }
      setUploading(true);
      try {
        const sigRes = await fetch("/api/upload");
        const { signature, timestamp, folder, apiKey, cloudName } = await sigRes.json();
        const uploaded: UploadedImage[] = [];

        for (let i = 0; i < files.length; i++) {
          const formData = new FormData();
          formData.append("file", files[i]);
          formData.append("api_key", apiKey);
          formData.append("timestamp", timestamp);
          formData.append("signature", signature);
          formData.append("folder", folder);

          const res = await fetch(
            `https://api.cloudinary.com/v1_1/${cloudName}/image/upload`,
            { method: "POST", body: formData }
          );
          const data = await res.json();
          uploaded.push({ url: data.secure_url, publicId: data.public_id });
          setProgress(Math.round(((i + 1) / files.length) * 100));
        }
        onChange([...images, ...uploaded]);
      } catch (err) {
        console.error("Upload failed", err);
        alert("Image upload failed. Try again.");
      } finally {
        setUploading(false);
        setProgress(0);
      }
    },
    [images, maxImages, onChange]
  );

  const removeImage = (publicId: string) =>
    onChange(images.filter((img) => img.publicId !== publicId));

  return (
    <div className="space-y-3">
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
        {images.map((img, idx) => (
          <div
            key={img.publicId}
            className="relative aspect-square rounded-lg overflow-hidden border border-border group"
          >
            <Image src={img.url} alt={`Product ${idx + 1}`} fill className="object-cover" />
            <button
              type="button"
              onClick={() => removeImage(img.publicId)}
              className="absolute top-1 right-1 bg-black/60 text-white rounded-full p-1 opacity-0 group-hover:opacity-100 transition-opacity"
            >
              <X className="w-3 h-3" />
            </button>
            {idx === 0 && (
              <span className="absolute bottom-1 left-1 text-xs bg-primary text-primary-foreground px-2 py-0.5 rounded">
                Cover
              </span>
            )}
          </div>
        ))}

        {images.length < maxImages && (
          <label className="aspect-square rounded-lg border-2 border-dashed border-border flex flex-col items-center justify-center cursor-pointer hover:border-primary transition-colors">
            {uploading ? (
              <>
                <Loader2 className="w-5 h-5 animate-spin mb-1 text-muted-foreground" />
                <span className="text-xs text-muted-foreground">{progress}%</span>
              </>
            ) : (
              <>
                <Upload className="w-5 h-5 mb-1 text-muted-foreground" />
                <span className="text-xs text-muted-foreground">Add photos</span>
              </>
            )}
            <input
              type="file"
              accept="image/*"
              multiple
              className="hidden"
              disabled={uploading}
              onChange={(e) => e.target.files && uploadFiles(e.target.files)}
            />
          </label>
        )}
      </div>
      <p className="text-xs text-muted-foreground">First image is the cover photo. Max {maxImages} images.</p>
    </div>
  );
}
