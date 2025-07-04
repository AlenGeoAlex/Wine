<!-- src/views/NotFoundView.vue -->
<script setup lang="ts">
import { RouterLink } from 'vue-router'
import { Button } from '@/components/ui/button'
</script>

<template>
  <div class="not-found-container">
    <div class="text-center">
      <h1 class="not-found-title unselectable">404</h1>
      <p class="not-found-text unselectable">
        Oops! The media you're looking for doesn't exist.
      </p>
    </div>
  </div>
</template>

<style scoped>
.not-found-container {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 60vh;
  text-align: center;
  /* Use theme variables for text color! */
  color: hsl(var(--foreground));
}

/* Define the animation */
@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* Apply the animation with delays for a staggered effect */
.not-found-title,
.not-found-text,
.not-found-button {
  /* This keeps the elements in their final state after animation */
  animation-fill-mode: forwards;
  /* Set initial opacity to 0 to prevent flash before animation starts */
  opacity: 0;
}

.not-found-title {
  font-size: 8rem;
  font-weight: 800;
  line-height: 1;
  animation: fadeInUp 0.5s ease-out forwards;
}

.not-found-text {
  font-size: 1.25rem;
  margin-top: 0.5rem;
  margin-bottom: 2rem;
  color: hsl(var(--muted-foreground));
  animation: fadeInUp 0.5s ease-out 0.2s forwards; /* 0.2s delay */
}

.not-found-button {
  animation: fadeInUp 0.5s ease-out 0.4s forwards; /* 0.4s delay */
}
</style>