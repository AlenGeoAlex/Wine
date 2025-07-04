<script setup lang="ts">
import { Button } from '@/components/ui/button'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import { MoreHorizontal } from 'lucide-vue-next'
import { formatBytes, formatExpiry } from '@/lib/utils'

defineProps<{
  name?: string
  size?: number
  expiresAt?: string
}>()
</script>

<template>
  <header class="flex items-center justify-between w-full p-4 border-b border-border">
    <div>
      <h1 class="text-2xl font-bold truncate">
        {{ name ?? 'Loading...' }}
      </h1>

      <p v-if="size || expiresAt" class="flex items-center gap-2 mt-1 text-sm text-muted-foreground">
        <span v-if="size">
          {{ formatBytes(size) }}
        </span>

        <span v-if="size && expiresAt" class="text-xs">·</span>

        <span v-if="expiresAt">
          {{ formatExpiry(expiresAt) }}
        </span>
        <span v-else>
          Expires Never
        </span>
      </p>
    </div>

    <DropdownMenu>
      <DropdownMenuTrigger as-child>
        <Button variant="ghost" size="icon">
          <MoreHorizontal class="w-5 h-5" />
          <span class="sr-only">More options</span>
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent>
        <DropdownMenuItem>Download</DropdownMenuItem>
        <DropdownMenuItem>Copy Link</DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  </header>
</template>