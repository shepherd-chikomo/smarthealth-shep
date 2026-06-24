'use client';

import { useCallback, useRef, useState, type DragEvent } from 'react';
import { FileText, Image as ImageIcon, Upload, X } from 'lucide-react';
import clsx from 'clsx';

export interface UploadedFile {
  id: string;
  name: string;
  type: string;
  size: number;
  previewUrl?: string;
  dataUrl?: string;
}

interface FileUploadZoneProps {
  files: UploadedFile[];
  onChange: (files: UploadedFile[]) => void;
  accept?: string;
  maxFiles?: number;
  label?: string;
  hint?: string;
}

function readFileAsDataUrl(file: File): Promise<string> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => resolve(String(reader.result));
    reader.onerror = reject;
    reader.readAsDataURL(file);
  });
}

export function FileUploadZone({
  files,
  onChange,
  accept = 'image/*,application/pdf',
  maxFiles = 5,
  label = 'Upload proof documents',
  hint = 'Drag and drop files here, or tap to browse. Images and PDFs accepted.',
}: FileUploadZoneProps) {
  const inputRef = useRef<HTMLInputElement>(null);
  const [dragOver, setDragOver] = useState(false);

  const addFiles = useCallback(
    async (incoming: FileList | File[]) => {
      const list = Array.from(incoming);
      const remaining = maxFiles - files.length;
      if (remaining <= 0) return;

      const toAdd = list.slice(0, remaining);
      const uploaded: UploadedFile[] = [];

      for (const file of toAdd) {
        const isImage = file.type.startsWith('image/');
        const isPdf = file.type === 'application/pdf';
        if (!isImage && !isPdf) continue;

        const dataUrl = await readFileAsDataUrl(file);
        uploaded.push({
          id: crypto.randomUUID(),
          name: file.name,
          type: file.type,
          size: file.size,
          previewUrl: isImage ? dataUrl : undefined,
          dataUrl,
        });
      }

      if (uploaded.length) onChange([...files, ...uploaded]);
    },
    [files, maxFiles, onChange],
  );

  function onDrop(e: DragEvent) {
    e.preventDefault();
    setDragOver(false);
    if (e.dataTransfer.files.length) void addFiles(e.dataTransfer.files);
  }

  function removeFile(id: string) {
    onChange(files.filter((f) => f.id !== id));
  }

  return (
    <div className="space-y-3">
      <div>
        <p className="text-sm font-medium">{label}</p>
        {hint && <p className="mt-0.5 text-xs text-[var(--muted)]">{hint}</p>}
      </div>

      <div
        role="button"
        tabIndex={0}
        onKeyDown={(e) => {
          if (e.key === 'Enter' || e.key === ' ') inputRef.current?.click();
        }}
        onClick={() => inputRef.current?.click()}
        onDragOver={(e) => {
          e.preventDefault();
          setDragOver(true);
        }}
        onDragLeave={() => setDragOver(false)}
        onDrop={onDrop}
        className={clsx(
          'flex cursor-pointer flex-col items-center justify-center rounded-xl border-2 border-dashed px-4 py-10 transition-colors',
          dragOver
            ? 'border-teal-500 bg-teal-50/50 dark:bg-teal-950/30'
            : 'border-[var(--border)] hover:border-teal-400/60',
        )}
      >
        <Upload className="mb-2 h-8 w-8 text-teal-600" />
        <p className="text-sm font-medium">Drop files here</p>
        <p className="mt-1 text-xs text-[var(--muted)]">or tap to upload from your device</p>
        <input
          ref={inputRef}
          type="file"
          className="hidden"
          accept={accept}
          multiple
          capture="environment"
          onChange={(e) => {
            if (e.target.files?.length) void addFiles(e.target.files);
            e.target.value = '';
          }}
        />
      </div>

      {files.length > 0 && (
        <ul className="grid gap-2 sm:grid-cols-2">
          {files.map((file) => (
            <li
              key={file.id}
              className="flex items-center gap-3 rounded-lg border border-[var(--border)] bg-[var(--card)] p-2"
            >
              {file.previewUrl ? (
                // eslint-disable-next-line @next/next/no-img-element
                <img
                  src={file.previewUrl}
                  alt={file.name}
                  className="h-12 w-12 shrink-0 rounded object-cover"
                />
              ) : (
                <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded bg-slate-100 dark:bg-slate-800">
                  {file.type === 'application/pdf' ? (
                    <FileText className="h-5 w-5 text-red-500" />
                  ) : (
                    <ImageIcon className="h-5 w-5 text-[var(--muted)]" />
                  )}
                </div>
              )}
              <div className="min-w-0 flex-1">
                <p className="truncate text-sm font-medium">{file.name}</p>
                <p className="text-xs text-[var(--muted)]">
                  {(file.size / 1024).toFixed(0)} KB
                </p>
              </div>
              <button
                type="button"
                className="rounded p-1 text-[var(--muted)] hover:bg-slate-100 hover:text-red-600 dark:hover:bg-slate-800"
                onClick={(e) => {
                  e.stopPropagation();
                  removeFile(file.id);
                }}
                aria-label={`Remove ${file.name}`}
              >
                <X className="h-4 w-4" />
              </button>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
