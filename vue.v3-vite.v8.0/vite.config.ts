import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  // setupFiles: ['./src/components/__tests__/vitest-localstorage-mock.ts'],  
  server: {
    origin: 'http://localhost:5173',
    port: 5173,
  },  
})
