<script setup lang="ts">
import { RouterView } from 'vue-router'
import {useDark} from "@vueuse/core";
import { Toaster } from '@/components/ui/sonner'
import 'vue-sonner/style.css'
// import 'viewerjs/dist/viewer.css'

useDark();
</script>
<template>
  <div class="h-full w-full bg-background text-foreground">
    <RouterView class="w-full h-full"></RouterView>
    <Toaster />
  </div>
</template>