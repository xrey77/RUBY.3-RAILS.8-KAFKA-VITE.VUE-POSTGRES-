<template>
    <div class="modal fade" id="staticMfa" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="staticMfaLabel" aria-hidden="true">
      <div class="modal-dialog modal-sm modal-dialog-centered">
        <div class="modal-content">
          <div class="modal-header bg-warning">
            <h1 class="modal-title fs-5 text-dark" id="staticMfaLabel">2-Factor Authenticator</h1>
            <button @click="closeMfa" type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body">
            <form id="mfaForm" @submit.prevent="submitOTP">
              <div class="mb-3">
                <input type="text" class="form-control border-warning" v-model="Otpcode" required placeholder="enter 6 digits OTP Code" autocomplete="off">
            </div>
            <button type="submit" class="btn btn-warning">submit</button>
            <button id="mfaReset" type="reset" class="btn btn-warning">reset</button>
    
            </form>
          </div>
          <div class="modal-footer">
            <div id="mfaMsg" class="w-100 text-left text-danger">{{ OtpMessage }}</div>
          </div>
        </div>
      </div>
    </div>  
    </template>
    
    <style scoped>
      #mfaReset {
        visibility: hidden;
      }
    </style>
    
    <script lang="ts">
     import { defineComponent } from 'vue';
     import jQuery from 'jquery';
     import axios from 'axios';
    
     
     const api = axios.create({
        baseURL: "http://127.0.0.1:3000",
        headers: {'Accept': 'application/json',
                  'Content-Type': 'application/json'}
     })
    
     export default defineComponent({
        name: 'Mfa-Page',
        data() {
            return {
                Userid: '',
                Otpcode: '',
                token: '',
                OtpMessage: ''
            }
        },
        methods: {
            submitOTP: function() {
                const usrId = window.sessionStorage.getItem('USERID');
                if (usrId !== null) {
                  this.Userid = usrId
                }
                const usrToken = window.sessionStorage.getItem('TOKEN');
                if (usrToken !== null) {
                  this.token = usrToken;
                }

                const data =JSON.stringify({otp: this.Otpcode });
                api.patch(`api/mfa/verifytotp/${this.Userid}`, data, { headers: {
                'Content-Type': 'application/json',
                Authorization: `Bearer ${this.token}`
                }})
                .then((res: any) => {
                      this.OtpMessage = res.data.message;
                      sessionStorage.setItem("USERNAME", res.data.username);
                      jQuery("#mfaReset").trigger('click');
                      window.setTimeout(() => {
                        this.OtpMessage = '';
                        window.location.reload();
                      }, 3000);
                  }, (error: any) => {
                        if (error.response) {
                          this.OtpMessage = error.response.data.message;
                        } else {
                          this.OtpMessage = error.message;
                        }
                        window.setTimeout(() => {
                        this.OtpMessage = '';
                        }, 3000);
                });
    
            },
            closeMfa: function() {
                jQuery("#mfaReset").trigger('click');
                this.OtpMessage = '';
                sessionStorage.removeItem('USERID');
                sessionStorage.removeItem('USERNAME');
                sessionStorage.removeItem('TOKEN');
                sessionStorage.removeItem('USERPIC');            
                sessionStorage.clear();
                window.location.href="/";
            },
        }
     })
    </script>