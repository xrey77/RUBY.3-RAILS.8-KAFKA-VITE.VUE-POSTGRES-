<template>
  <div class="container">
    <h1 class="text-center text-warning">Product List</h1>
    <div v-if="totpage==0" class="text-danger text-center">{{message}}</div>
    <div v-else-if="totpage >1" class="text-danger">{{message}}</div>
    <table class="table table-hover table-success table-striped">
        <thead>
          <tr>
            <th class="bg-primary text-white" scope="col">#</th>
            <th class="bg-primary text-white" scope="col">Descriptions</th>
            <th class="bg-primary text-white" scope="col">Stocks</th>
            <th class="bg-primary text-white" scope="col">Unit</th>
            <th class="bg-primary text-white" scope="col">Price</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="item in products" :key="item['id']">
            <td>{{ item['id'] }}</td>
            <td>{{ item['descriptions'] }}</td>
            <td>{{ item['qty'] }}</td>
            <td>{{ item['unit'] }}</td>
            <td>&#8369;{{ toDecimal(item['sellprice']) }}</td>
          </tr>
        </tbody>
    </table>    

      <nav aria-label="Page navigation example">
        <ul class="pagination">
          <li class="page-item"><a @click="lastPage($event)" class="page-link" href="#">Last</a></li>
          <li class="page-item"><a @click="prevPage($event)" class="page-link" href="#">Previous</a></li>
          <li class="page-item"><a @click="nextPage" class="page-link" href="#">Next</a></li>
          <li class="page-item"><a @click="firstPage($event)" class="page-link" href="#">First</a></li>
          <li class="page-item page-link text-danger">Page&nbsp;{{ page }} of&nbsp;{{ totpage }}</li>
        </ul>
      </nav>
      <div class="tot-rec text-white">Total Records : {{ totalrecords }}</div>
    </div>
    <div class="fixed-bottom text-white">
      <Footer/>
  </div>
</template>

<style lang="css" scoped>
body html {
  background-color: black;
}
</style>

<script setup lang="ts">
    import { ref } from 'vue';
    import axios from 'axios';
    import Footer from '../components/Footer.vue';

    const api = axios.create({
        baseURL: "http://127.0.0.1:3000",
        headers: {'Accept': 'application/json',
                  'Content-Type': 'application/json'}
    });

  const message = ref<string>('');
  const totalrecords = ref<number>(0);
  const page = ref<number>(1);
  const totpage = ref<number>(0);
  const products = ref<any[]>([]);

  const getProducts = async (pg: number) => {
        await api.get(`api/products/list/${pg}`)
        .then((res: any) => {
            products.value = res.data.products;
            totalrecords.value = res.data.totalrecords;
            page.value = res.data.page;
            totpage.value = res.data.totpage;
        }, (error: any) => {
             if (error.response) {
                message.value = error.response.data.message;
             } else {
                message.value = error.message;
             }
             setTimeout(() => {
                message.value = ''
             }, 3000);
        });    
    }

    getProducts(page.value);

    const nextPage = (event: any) => {
      event.preventDefault();
      if (page.value == totpage.value) {          
          return;
      }
      page.value++;
      getProducts(page.value);
      return;
    }


    const prevPage = (event: any) => {
      event.preventDefault();
      if (page.value == 1) {
      return;
      }
      page.value--;
      getProducts(page.value);
      return;    
    }

    const firstPage = (event: any) => {
      event.preventDefault();
      page.value = 1;
      getProducts(page.value);
      return;    
    }

    const lastPage = (event: any) => {
      event.preventDefault();
      page.value = totpage.value;
      getProducts(page.value);
      return;    
    }

    const toDecimal = (nos: number) => {
      const formatter = new Intl.NumberFormat('en-US', {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2,
      });
      return formatter.format(nos);
    }
    
  
</script>
