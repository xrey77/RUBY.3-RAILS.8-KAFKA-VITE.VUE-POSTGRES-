<template>
    <div class="w-100">
      <p class="text-center size12">Copyright &copy; {{ new Date().getFullYear() }} SUPERCARS INC. All rights reserved. &trade;</p>
    </div>      
  </template>

  <style lang="scss" scoped>
  .size12 {
    font-size: 12px;
    padding: 3px;
  }
  </style>

  <script lang="ts">
    import { defineComponent} from 'vue';

    export default defineComponent({
    name: 'Footer-Page',
  });

  </script>