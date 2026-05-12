<template>
  <main>
    <div class="card bg-dark">
      <div class="card-body">
        <div class="card-text">
          <img class="contact" src="/images/3.jpeg" alt=""/>
          <h3 class="card-text text-warning">Contact Us</h3>
          <p class="card-text text-white">
            Supercars welcomes all enquiries, comments, feedback or suggestions regarding the championship, ticketing, digital, media, corporate sales etc.

            For troubleshooting and support on the APP, Live Timing, Memberships and Superview, please visit our <a class="text-warning" href="#">FAQ and TROUBLE SHOOTING GUIDE</a>
            
            Supercars closely monitors the views and opinions of our fans and where possible will seek to respond to all on an individual basis.
            
            Note: All constructive feedback is welcome however Supercars will not reply to any correspondence of an offensive nature.            
          </p>
          <p class="card-text text-white">
            <strong>Supercars</strong>
            <br/>
            PO Box 607, SOUTHPORT BC, QLD, 4215
            <br/>            
            45 Nerang Street, Southport, QLD, 4215
            <br/>
            Ph. 07 5630 0364
            <br/>
            Hours of operation – Mon-Fri 9am-5pm            
          </p>
        </div>
      </div>
    </div>
    <div class="footer">
      <Footer class="mt-10"/>
    </div>  
</main>  
</template>

<style lang="scss">
.footer {
  height: 10vh !important;
}
.mt-10 {
  padding-top: 10% !important;
}
.contact {
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
  .contact {
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
  import { defineComponent } from 'vue';
  import Footer from '../components/Footer.vue';
  
export default defineComponent({
    name: 'Contact-Page',
    components: {
      Footer,
    }
})
</script>