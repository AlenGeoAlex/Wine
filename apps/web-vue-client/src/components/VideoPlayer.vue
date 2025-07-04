<script setup lang="ts">
// import { ref, onMounted, onBeforeUnmount, watch } from 'vue'
// import videojs from 'video.js'
// import type Player from 'video.js/dist/types/player'
// import 'video.js/dist/video-js.css'
//
// const props = defineProps<{
//   src: string
//   // Pass the secret if the backend streams directly and requires a header
//   secret?: string | null
// }>()
//
// const videoPlayer = ref<HTMLVideoElement | null>(null)
// let player: Player | null = null
//
// // This function modifies the request to add the secret header if needed.
// // It's a powerful feature of video.js's HTTP streaming (VHS).
// function initializePlayer() {
//   if (!videoPlayer.value) return
//
//   // If a secret is provided, we configure the request hook
//   if (props.secret && videojs.Vhs) {
//     videojs.Vhs.xhr.beforeRequest = (options) => {
//       options.headers = options.headers || {}
//       options.headers['X-Secret-Key'] = props.secret!
//       return options
//     }
//   }
//
//   const options = {
//     autoplay: true,
//     controls: true,
//     responsive: true,
//     fluid: true,
//     sources: [
//       {
//         src: props.src,
//         // The type might need to be dynamic based on fileInfo
//         type: 'application/x-mpegURL' // for HLS streams
//         // type: 'video/mp4' // for MP4 files
//       },
//     ],
//   }
//
//   player = videojs(videoPlayer.value, options, () => {
//     console.log('Player is ready')
//   })
// }
//
// onMounted(() => {
//   initializePlayer()
// })
//
// onBeforeUnmount(() => {
//   if (player) {
//     player.dispose()
//     player = null
//   }
//   // Reset the hook when the component is destroyed
//   if (videojs.Vhs) {
//     videojs.Vhs.xhr.beforeRequest = undefined;
//   }
// })
//
// // Watch for src changes if the component is reused
// watch(() => props.src, (newSrc) => {
//   if (player && newSrc) {
//     player.src({ src: newSrc, type: 'application/x-mpegURL' })
//   }
// })

</script>

<template>
<!--  <div class="w-full h-full flex items-center justify-center p-4">-->
<!--    <video ref="videoPlayer" class="video-js vjs-big-play-centered w-full h-full" />-->
<!--  </div>-->
</template>