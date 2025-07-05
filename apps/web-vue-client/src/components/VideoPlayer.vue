<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue';
import { toast } from 'vue-sonner';

const props = defineProps<{
  fileId: string;
  secret?: string;
}>();

// --- Refs and State ---
const videoRef = ref<HTMLVideoElement | null>(null);
const baseUrl = new URL(`/api/v1/file/${props.fileId}/content`, window.location.origin);

let currentStart = 0;
const chunkSize = 1 * 1024 * 1024; // 1 MB chunks
let fileSize = 0;

onMounted(() => {
  if (!videoRef.value) {
    console.error("Video element not found on mount.");
    return;
  }

  if (!('MediaSource' in window)) {
    toast.error("Your browser does not support Media Source Extensions.");
    return;
  }

  videoRef.value.addEventListener('error', () => console.error('Video Element Error:', videoRef.value?.error));
  videoRef.value.addEventListener('waiting', () => console.log('... Video player is waiting for more data ...'));
  videoRef.value.addEventListener('playing', () => console.log('▶️ Video is playing.'));

  videoRef.value.src = baseUrl.toString();
});


</script>

<template>
  <video
    ref="videoRef"
    controls
    muted
    class="rounded-xl w-full h-auto shadow"
  />
</template>