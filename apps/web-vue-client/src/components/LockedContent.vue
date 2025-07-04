<script setup lang="ts">
import { Button } from '@/components/ui/button'
import { Lock } from 'lucide-vue-next'
import {Card, CardContent, CardDescription, CardHeader, CardTitle} from "@/components/ui/card";

const emit = defineEmits(['unlock'])
</script>

<template>
  <div class="flex items-center justify-center flex-grow">
    <Card class="w-full max-w-sm text-center">
      <CardHeader>
        <div class="mx-auto bg-secondary rounded-full p-3 w-fit mb-4">
          <Lock class="w-8 h-8 text-secondary-foreground" />
        </div>
        <CardTitle>Content Locked</CardTitle>
        <CardDescription>This file is password protected. Please unlock it to view the content.</CardDescription>
      </CardHeader>
      <CardContent>
        <Button @click="emit('unlock')" class="w-full">
          Unlock Content
        </Button>
      </CardContent>
    </Card>
  </div>
</template>