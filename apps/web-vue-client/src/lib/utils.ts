import { type ClassValue, clsx } from 'clsx'
import { twMerge } from 'tailwind-merge'
import {formatDistanceToNow} from "date-fns";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

export function formatBytes(bytes: number, decimals = 2): string {
  if (bytes === 0) return '0 Bytes';
  const k = 1024;
  const dm = decimals < 0 ? 0 : decimals;
  const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
}

export function formatExpiry(dateString?: string): string {
  if (!dateString) return 'Never';
  const date = new Date(dateString);
  if (date < new Date()) {
    return 'Expired';
  }
  return `Expires in ${formatDistanceToNow(date)}`;
}