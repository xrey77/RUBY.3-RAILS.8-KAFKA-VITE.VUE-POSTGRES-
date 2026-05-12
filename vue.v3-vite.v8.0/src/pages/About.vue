<template>
  <main>
    <div class="card bg-dark mt-2">
      <div class="card-body">
      <img class="about" src="/images/about.png" alt="" />
      <div class="card-text text-white">
        <h3 class="text-warning">About Us</h3>
        Our supercar, also known as an exotic car, is a street-legal sports car with race track-like power, speed, and handling, plus a certain subjective cachet linked to pedigree and/or exclusivity. The term 'supercar' is frequently used for the extreme fringe of powerful, low-bodied mid-engine luxury sportscars. A low-profile car may have limited ground clearance, but a handling-favorable center of gravity and a smaller frontal area than a front engined car. These characteristics can reduce supercars' aerodynamic drag, enabling higher top speeds. Since the 2000s, the term hypercar has come into use for the highest-performance supercars.
        <br/><br/>
        <p class="text-white">
          Supercars often serve as the flagship model within a vehicle manufacturer's sports car range and typically feature various performance-related technology derived from motorsports. Some examples include the Ferrari 458 Italia, Lamborghini Aventador, and McLaren 720S.           
        </p>
        <p class="text-white">
          Automotive journalism typically reserves the predicate 'hypercar' for low (two- to low 4-figure) production-number cars, built over and above the marque's typical product line-up and carrying 21st century sales prices often exceeding a million euros, dollars, or pounds. Examples include the Porsche Carrera GT, Ford GT, and Ferrari F40/F50/Enzo lineage. Only a few car makers, like Bugatti and Koenigsegg, exclusively make hypercars.           
        </p>
      </div>
    </div>
    </div>
    <div class="footer text-white">
    <Footer class="mt-10"/>
    </div>
</main>
</template>

<style lang="scss">
.footer {
  height: 20vh !important;
}
.mt-10 {
  padding-top: 20% !important;
}
.about {
  width: 90% !important;
  height: 57vh !important;  
  margin-left: 5%;
  object-fit: fill;
  border-radius: 20px;
}
.card-text {
  margin-left: 5%;
  margin-right: 5%;
  text-align: justify;

}

@media (max-width: 991.98px) { 
  .about {
    margin-top: 50px;
    width: 90% !important;
    height: 60% !important;  
    object-fit: cover;
    border-radius: 20px;
  }
  .footer {
    height: 100vh !important;
  }
  
  .mt-10 {
    padding-top: 73vh !important;
  }
    
 }
</style>

<script lang="ts">
import { defineComponent} from 'vue';
import Footer from '../components/Footer.vue';

export default defineComponent({
    name: 'About-Page',
    components: {
      Footer,
    }
});
</script>