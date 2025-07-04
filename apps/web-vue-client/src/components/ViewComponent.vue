<script setup lang="ts">
import {computed, onMounted, ref} from "vue";
import {useRoute, useRouter} from "vue-router";
import {toast} from "vue-sonner";
import { Loader2 } from 'lucide-vue-next'

import {FileApiService} from "@/lib/services/file-api.service.ts";
import type {IFileInfoResponse} from "@/lib/models/api-dto.models.ts";

import SecretDialogComponent from "@/components/SecretDialogComponent.vue";
import FileNavbar from "@/components/FileNavbar.vue";
import LockedContent from "@/components/LockedContent.vue";
import ImageViewer from "@/components/ImageViewer.vue";
import VideoPlayer from "@/components/VideoPlayer.vue";

const route = useRoute();
const router = useRouter();

const fileInfo = ref<IFileInfoResponse>();
const secret = ref<string>("");
const contentUrl = ref<string | null>(null);
const isLoading = ref(true);
const openSecretDialog = ref(false);

const isImage = computed(() => fileInfo.value?.contentType.startsWith('image/'));
const isVideo = computed(() => fileInfo.value?.contentType.startsWith('video/'));

function openSecretDialogHandler() {
  openSecretDialog.value = true;
}

async function handlePassword(password: string) {
  secret.value = password;
  await getContent();
}

async function getContent() {
  isLoading.value = true;
  contentUrl.value = null; // Clear previous content

  const id = route.params.id as string;

  try {

    const contentResponse = await FileApiService.getContent(id, secret.value);

    if (contentResponse.success && contentResponse.response?.content) {
      contentUrl.value = contentResponse.response.content; // Assuming it returns a direct URL or blob URL
      openSecretDialog.value = false;
      if(fileInfo.value?.secure)
        toast.success("Content unlocked!");
    } else {
      toast.error(contentResponse.error ?? "Failed to load content. The password might be incorrect.");
      secret.value = "";
    }

  } catch (e: any) {
    toast.error(e.message ?? "An error occurred while fetching content.");
  } finally {
    isLoading.value = false;
  }
}

onMounted(async () => {
  const id = route.params.id as string;
  if (!id) {
    toast.error("Failed to identify the content!")
    return;
  }

  const info = await FileApiService.getInfo(id);
  if (!info.success) {
    toast.error(info.error ?? "File not found or access denied.", {
      description: "You will be redirected to the homepage.",
    });
    setTimeout(() => router.push({ path: '/' }), 5000);
    return;
  }
  fileInfo.value = info.response!;

  if (fileInfo.value.secure) {
    isLoading.value = false;
    openSecretDialog.value = false;
  } else {
    await getContent();
  }
});
</script>

<template>
  <div class="flex flex-col w-full h-full ">
    <FileNavbar
      :name="fileInfo?.name"
      :size="fileInfo?.size"
      :expires-at="fileInfo?.expiration?.toString()"
    />

    <main class="flex-grow flex items-center justify-center w-full h-full">
      <div v-if="isLoading" class="flex items-center gap-2">
        <Loader2 class="w-6 h-6 animate-spin text-muted-foreground" />
        <span class="text-muted-foreground">Loading content...</span>
      </div>

      <template v-else>
        <ImageViewer
          c
          v-if="contentUrl && isImage"
          :src="contentUrl"
          :alt="fileInfo?.name"
        />
        <div v-else-if="!contentUrl" class="text-center text-muted-foreground">
          <p>This file type is not supported for direct preview.</p>
          <p class="text-sm">Try downloading the file instead.</p>
        </div>
      </template>

    </main>

    <SecretDialogComponent
      v-if="fileInfo"
      v-model:open="openSecretDialog"
      :name="fileInfo.name"
      @submit="handlePassword"
    />
  </div>
</template>

<style scoped>
/* Scoped styles if you need any */
</style>