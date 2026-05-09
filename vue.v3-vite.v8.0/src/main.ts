import 'bootstrap/dist/css/bootstrap.min.css';
import 'bootstrap/dist/js/bootstrap.bundle.min.js';
import { createApp } from 'vue'
import AppLayout from './Layouts/AppLayout.vue';
import router from './router/index';
import './style.css'

createApp(AppLayout).use(router).mount('#app');
  
