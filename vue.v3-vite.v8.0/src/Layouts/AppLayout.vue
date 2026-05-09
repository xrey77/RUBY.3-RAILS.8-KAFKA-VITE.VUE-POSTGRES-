<script lang="ts">  
  import Header from '../components/Header.vue';  
  import { defineComponent} from 'vue';

  export default defineComponent({
    name: 'AppLayout',
    components: {
      Header,
    }
});

</script>

<template>
    <Header />
      <main>
      <slot></slot>
    </main>
    <RouterView/>
</template>
  
<style lang="css">
body {
  background-color: black;
}

</style>