<template>
<div class="container-fluid mb-5">
    <div class="left-10">
    <h2 class="text-warning">Search Product</h2>    
    <form class="row g-3" @submit.prevent="submitSearch" autocomplete="off">
        <div class="col-auto">
          <input type="text" required class="form-control-sm" v-model="search" name="search" placeholder="enter Product keyword">
          <div class="text-warning">{{message}}</div>
        </div>
        <div class="col-auto">
          <button type="submit" class="btn btn-primary btn-sm mb-3">search</button>
        </div>
    </form>
    </div>
    <div class="container-fluid mb-4">
        <div class="card-group">
            <div v-for="prod in prodsearch" :key="prod['id']" class="col-md-4">
                <div class="card mx-3 mt-2">
                    <img v-bind:src="prod['productpicture']" class="card-img" alt=""/>
                    <div class="card-body cardbody-height">
                        <h5 class="card-title">Description</h5>
                        <p class="card-text">{{ prod['descriptions'] }}</p>
                    </div>
                    <div class="card-footer price-size">
                        <p class="card-text text-danger"><span class="text-dark">PRICE :</span>&nbsp;<strong>&#8369;{{ toDecimal(prod['sellprice']) }}</strong></p>
                    </div>  
                </div>
            </div>
        
        </div>    
    
    </div>
    <div class="left-10" v-if="totpage > 1">
        <nav aria-label="Page navigation example">
            <ul class="pagination">
              <li class="page-item"><a @click="lastPage($event)" class="page-link" href="#">Last</a></li>
              <li class="page-item"><a @click="prevPage($event)" class="page-link" href="#">Previous</a></li>
              <li class="page-item"><a @click="nextPage" class="page-link" href="#">Next</a></li>
              <li class="page-item"><a @click="firstPage($event)" class="page-link" href="#">First</a></li>
              <li class="page-item page-link text-danger">Page&nbsp;{{ pages }} of&nbsp;{{ totpage }}</li>
            </ul>
          </nav>
          <div class="tot-rec text-white">Total Records : {{ totalrecords }}</div>
        </div>  

</div>

</template>

<style scoped>
.card-body {
    height: 15vh !important;
}

</style>


<script setup lang="ts">
import { ref } from 'vue';
import axios from 'axios';

const api = axios.create({
    baseURL: "http://127.0.0.1:3000",
    headers: {'Accept': 'application/json',
            'Content-Type': 'application/json'}
});

const search = ref<string>('');
const prodsearch = ref([]);
const message = ref<string>('');
const totalrecords = ref<number>(0);
const pages = ref<number>(1);
const totpage = ref<number>(0);


const getProdsearch = async (page: number, keyword: string) => {
    message.value = "searching...";
    await api.get(`api/products/search/${page}/${keyword}`)
    .then((res: any) => {
        prodsearch.value = res.data.products;
        totalrecords.value = res.data.totalrecords;
        pages.value = Number(res.data.page);
        totpage.value = res.data.totpage;
        setTimeout(() => {
            message.value = '';
        }, 1000);
        return;
    }, (error: any) => {
        if (error.response) {
                message.value = error.response.data.message;
        } else {
          message.value = error.message;
        }
        prodsearch.value = []
        setTimeout(() => {
            message.value = '';
        }, 3000);
        return;
    });      

}

const submitSearch = () => {
    getProdsearch(pages.value, search.value);
}


const nextPage = (event: any) => {
      event.preventDefault();
      if (pages.value == totpage.value) {
          return;
      }
      pages.value++;
      return getProdsearch(pages.value, search.value);
    }


    const prevPage = (event: any) => {
      event.preventDefault();
      if (pages.value == 1) {
      return;
      }
      pages.value--;
      return getProdsearch(pages.value, search.value);
    }

    const firstPage = (event: any) => {
      event.preventDefault();
      pages.value = 1;
      return getProdsearch(pages.value, search.value);
    }

    const lastPage = (event: any) => {
      event.preventDefault();
      pages.value = totpage.value;
      return getProdsearch(pages.value, search.value);
    }

    const toDecimal = (nos: number) => {
      const formatter = new Intl.NumberFormat('en-US', {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2,
      });
      return formatter.format(nos);
    }
    

</script>