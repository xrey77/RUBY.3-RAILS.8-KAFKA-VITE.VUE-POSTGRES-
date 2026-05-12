<template>  
<div>
  <div id="carouselExampleCaptions" class="carousel slide overflow-hidden" data-bs-ride="true">
    <div class="carousel-indicators">
      <button type="button" data-bs-target="#carouselExampleCaptions" data-bs-slide-to="0" class="active" aria-current="true" aria-label="Slide 1"></button>
      <button type="button" data-bs-target="#carouselExampleCaptions" data-bs-slide-to="1" aria-label="Slide 2"></button>
      <button type="button" data-bs-target="#carouselExampleCaptions" data-bs-slide-to="2" aria-label="Slide 3"></button>
    </div>
    <div class="carousel-inner">
      <div class="carousel-item active">
        <img src="/images/1.jpeg" class="d-block w-100" alt="...">
        <div class="carousel-caption d-none d-md-block">
          <h1 class="mb-5 embossed-text">Sports car with race track-like power</h1>
        </div>
      </div>
      <div class="carousel-item">
        <img src="/images/2.jpeg" class="d-block w-100" alt="...">
        <div class="carousel-caption d-none d-md-block">
          <h1 class="mb-5 embossed-text">More powerful than typical sports cars</h1>
        </div>
      </div>
      <div class="carousel-item">
        <img src="/images/3.jpeg" class="d-block w-100" alt="...">
        <div class="carousel-caption d-none d-md-block">
          <h1 class="mb-5 embossed-text"> Super fast, luxurious and prestigious</h1>
        </div>
      </div>
    </div>
    <button class="carousel-control-prev" type="button" data-bs-target="#carouselExampleCaptions" data-bs-slide="prev">
      <span class="carousel-control-prev-icon" aria-hidden="true"></span>
      <span class="visually-hidden">Previous</span>
    </button>
    <button class="carousel-control-next" type="button" data-bs-target="#carouselExampleCaptions" data-bs-slide="next">
      <span class="carousel-control-next-icon" aria-hidden="true"></span>
      <span class="visually-hidden">Next</span>
    </button>
  </div>  
  <Footer class="footer text-white mt-5"/>
</div>  
</template>

<script lang="ts">
  import Footer from '../components/Footer.vue';
  import { defineComponent} from 'vue';

  export default defineComponent({
    name: 'Home',
    components: {
      Footer,
    }
});
</script>



<style lang="scss" scoped>
.carousel-indicators [data-bs-target] {
  box-sizing: content-box;
  flex: 0 1 auto;
  width: 30px;
  height: 30px;
  padding: 0;
  margin-right: 3px;
  margin-left: 3px;
  text-indent: -999px;
  cursor: pointer;
  background-color: #bfe159;
  background-clip: padding-box;
  border: 0;
  border-radius: 50%;
  border-top: 10px solid transparent;
  border-bottom: 10px solid transparent;
  opacity: .5;
  transition: opacity .6s ease;
}

.carousel-inner .carousel-item img {
  max-width: 100% !important;
  height: 88vh;
  object-fit: cover;
  scrollbar-width: none !important; /* For Firefox */
  -ms-overflow-style: none !important; /* For Internet Explorer and Edge */
}

/* Hide scrollbar for WebKit browsers (Chrome, Safari) */
.carousel::-webkit-scrollbar {
  display: none !important;
}
.footer {
  margin-bottom: -45px;
}
@media (max-width: 991.98px) { 
  .footer {
    margin-bottom: 10px;
  }
}
</style>

  