<script setup lang="ts">
const props = defineProps<{
  src: string
  alt?: string
}>()

const options = {
  inline: true,
  button: true,
  navbar: true,
  title: false,
  toolbar: true,
  tooltip: true,
  movable: true,
  zoomable: true,
  rotatable: true,
  scalable: true,
  transition: true,
  fullscreen: true,
  keyboard: true,
}
</script>

<template>
  <div class="flex items-center justify-center flex-grow w-full h-full p-4">
    <div v-viewer="options" class="w-full h-full">
      <img :src="props.src" :alt="props.alt ?? 'Image content'" class="hidden" />
    </div>
  </div>
</template>

<style>
.viewer-container {
  width: 100%;
  height: 100%;
}
</style>