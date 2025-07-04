<script setup lang="ts">
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { ref } from 'vue'

const model = defineModel<boolean>()

const props = defineProps<{
  name?: string
}>()

const emits = defineEmits<{
  (e: 'submit', value: string): void
}>()

let password = ref('')

const submit = () => {
  emits('submit', password.value)
  model.value = false
}
</script>

<template>
  <Dialog v-model:open="model" >
    <DialogContent class="sm:max-w-[425px]" @interact-outside.prevent>
      <DialogHeader>
        <DialogTitle>Unlock {{ props.name ?? "File" }}</DialogTitle>
        <DialogDescription>
          This content is protected. Please provide the secret key.
        </DialogDescription>
      </DialogHeader>

      <div class="grid gap-4 py-4">
        <div class="grid grid-cols-4 items-center gap-4">
          <Label for="password" class="text-right">
            Secret Key
          </Label>
          <Input id="password" type="password" v-model="password" class="col-span-3" @keyup.enter="submit" />
        </div>
      </div>

      <DialogFooter>
        <Button @click="submit" type="submit" variant="secondary">
          Unlock
        </Button>
      </DialogFooter>
    </DialogContent>
  </Dialog>
</template>

<style scoped>
:deep([data-radix-vue-dialog-close]) {
  display: none;
}
</style>