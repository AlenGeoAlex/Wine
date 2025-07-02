<script setup lang="ts">
</script>

<template>
  <div class="not-found-page">
    <div class="container">
      <div class="glitch-wrapper">
        <div class="glitch unselectable" data-text="404">404</div>
      </div>
      <h1 class="unselectable">Media Not Found</h1>
      <p class="unselectable">
        Oops! The content you are looking for appears to be corrupted, moved, or was never here to begin with.
      </p>
    </div>
  </div>
</template>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;700&display=swap');

.unselectable {
  -webkit-touch-callout: none;
  -webkit-user-select: none;
  -khtml-user-select: none;
  -moz-user-select: none;
  -ms-user-select: none;
  user-select: none;
}


.not-found-page {
  --checker-light: #e0e0e0;
  --checker-dark: #c7c7c7;
  --checker-size: 40px;

  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 9999;

  font-family: 'Poppins', sans-serif;
  color: #333;

  background-color: var(--checker-light);
  background-image:
    linear-gradient(45deg, var(--checker-dark) 25%, transparent 25%),
    linear-gradient(-45deg, var(--checker-dark) 25%, transparent 25%),
    linear-gradient(45deg, transparent 75%, var(--checker-dark) 75%),
    linear-gradient(-45deg, transparent 75%, var(--checker-dark) 75%);
  background-size: var(--checker-size) var(--checker-size);
  background-position: 0 0, 0 calc(var(--checker-size)/2), calc(var(--checker-size)/2) calc(var(--checker-size)/-2), calc(var(--checker-size)/-2) 0px;

  display: flex;
  justify-content: center;
  align-items: center;
  overflow: hidden;
}

.container {
  text-align: center;
  background-color: rgba(255, 255, 255, 0.9);
  padding: 30px 30px;
  border-radius: 15px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
  backdrop-filter: blur(5px);
  -webkit-backdrop-filter: blur(5px);
  border: 1px solid rgba(255, 255, 255, 0.4);
  max-width: 30%;
  transition: all 0.3s ease;
}

.glitch-wrapper {
  position: relative;
}

.glitch {
  font-size: 10rem;
  font-weight: 700;
  position: relative;
  color: #222;
  letter-spacing: 0.05em;
  --glitch-text: "404";
  animation: glitch-shake 2.5s infinite linear;
  transition: font-size 0.3s ease;
}

.glitch::before,
.glitch::after {
  content: var(--glitch-text);
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  overflow: hidden;
}

.glitch::before {
  color: #ff00c1;
  animation: glitch-effect 1.5s infinite linear alternate-reverse;
  clip-path: polygon(0 0, 100% 0, 100% 35%, 0 35%);
}

.glitch::after {
  color: #00fff9;
  animation: glitch-effect 2s infinite linear alternate-reverse;
  clip-path: polygon(0 65%, 100% 65%, 100% 100%, 0 100%);
}

@keyframes glitch-shake {
  0%, 100% { transform: translateX(0); }
  10%, 30%, 50%, 70%, 90% { transform: translateX(-3px); }
  20%, 40%, 60%, 80% { transform: translateX(3px); }
}

@keyframes glitch-effect {
  0% { transform: translate(-4px, -2px); }
  25% { transform: translate(4px, 2px); }
  50% { transform: translate(-2px, 4px); }
  75% { transform: translate(2px, -4px); }
  100% { transform: translate(-4px, 2px); }
}

h1 {
  font-size: 2.5rem;
  margin-bottom: 10px;
  color: #1a1a1a;
  transition: font-size 0.3s ease;
}

p {
  font-size: 1.1rem;
  color: #555;
  margin-bottom: 30px;
  max-width: 400px;
  margin-left: auto;
  margin-right: auto;
  transition: font-size 0.3s ease;
}


/* Tablet Styles */
@media (max-width: 768px) {
  .glitch {
    font-size: 8rem;
  }
  h1 {
    font-size: 2rem;
  }
  p {
    font-size: 1rem;
  }
  .container {
    padding: 30px 35px;
  }
}

/* --- NEW MOBILE STYLES --- */
/* Mobile Phone Styles */
@media (max-width: 480px) {
  .glitch {
    font-size: 6rem;
  }
  h1 {
    font-size: 1.8rem;
  }
  p {
    font-size: 0.95rem;
  }
  .container {
    padding: 30px 20px;
    max-width: 95%; /* Allow it to get a little wider on small screens */
  }
  .btn {
    padding: 10px 20px;
    font-size: 0.9rem;
  }
}
</style>