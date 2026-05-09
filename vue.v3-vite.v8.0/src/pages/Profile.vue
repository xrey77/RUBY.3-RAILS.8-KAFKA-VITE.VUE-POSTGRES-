<template>
    <div class="card bg-dark card-width bs-info-border-subtle">
      <div class="card-header bg-success text-light">
        <strong>USER'S PROFILE NO.&nbsp; {{ userid }}</strong>
      </div>
      <div class="card-body bg-warning">    
        <form id="profileForm" @submit.prevent="submitProfile" enctype="multipart/form-data" method="POST">
            <div class="row">
                <div class="col">
                    <div class="mb-3">
                        <input type="text" required v-model="firstname" name="firstname" class="form-control"  autocomplete="off">
                    </div>
                    <div class="mb-3">
                        <input type="text" required v-model="lastname" name="lastname" class="form-control" autocomplete="off">
                    </div>
                    <div class="mb-3">
                        <input type="email" v-model="email" name="email" class="form-control" readonly>
                    </div>
                    <div class="mb-3">
                        <input type="text" required v-model="mobile" name="mobile" class="form-control" autocomplete="off">
                    </div>
    
                </div>
                <div class="col">
                    <img id="userpic" class="usr" v-bind:src="profilepic" alt=""/>
                    <div class="mb-3">
                        <input type="file" @change="changePicture" class="form-control form-control-sm mt-3" accept=".png, .jpg, .jpeg, .gif"  />
                    </div>
    
                </div>
            </div>
    
            <div class="row">
                <div class="col">
                    <div class="form-check">
                        <input type="checkbox" class="form-check-input cb-border" v-model="chgPwd" @change="checkboxPassword" />
                        <label class="form-check-label" for="chgPwd">
                            Change Password
                        </label>
                    </div>
                </div>
                <div class="col">
                    <div class="form-check">
                        <input class="form-check-input cb-border" type="checkbox" v-model="chkMfa" @change="checkboxMFA" />
                        <label class="form-check-label" for="chkMfa">
                            2-Factor Authenticator
                        </label>
                    </div>
                </div>
            </div>
    
            <div class="row">
    
                <div class="col">
                    <div v-if="chgPwd" id="cpwd">
                        <div class="mb-3">
                            <input type="password"  v-model="password" class="form-control pwd" placeholder="enter new Password" autocomplete="off">
                        </div>
                        <div class="mb-3">
                            <input type="password" v-model="confpassword" class="form-control pwd" placeholder="confirm new Password" autocomplete="off">
                        </div>
                        <button @click="changePassword" type="button" class="btn btn-primary">change password</button>
                    </div>
                    <div v-if="chkMfa" id="mfa1">
                        <img class="qrcode1" v-bind:src="qrcodeurl" alt="qrcodeurl"/>
                    </div>
                    
                </div>
                <div class="col">

                        <div v-if="chkMfa" id="mfa2">
                            <p id="qrcode-cap1" class='text-danger'><strong>Requirements</strong></p>
                            <p id="qrcode-cap2">You need to install <strong>Google or Microsoft Authenticator</strong> in your Mobile Phone, once installed, click Enable Button below, and <strong>SCAN QR CODE</strong>, next time you login, another dialog window will appear, then enter the <strong>OTP CODE</strong> from your Mobile Phone in order for you to login.</p>
                            <div class="row">
                                <div class="col btn-1">
                                    <button @click="enableMFA" type="button" class="btn btn-primary qrcode-cap3">Enable</button>
                                </div>
                                <div class="col col-3 btn-2">
                                    <button @click="disableMFA" type="button" class="btn btn-secondary qrcode-cap3">Disable</button>
                                </div>
                            </div>
    
                        </div>
    
                </div>
            </div>
            <div v-if="showSave === false">
                <button id="save" type="submit" class="btn btn-success">save</button>
            </div>
        </form>
      </div>
      <div class="card-footer">
        <div class="w-100 text-left text-warning">{{ profileMsg }}</div>
      </div>
      <div v-if="chkMfa">
        <Footer/>
      </div>
      <div v-if="!chkMfa" class="fixed-bottom text-white">
        <Footer/>
      </div>

    </div>
    </template>
    
    <style scoped>
        .usr {
            width: 150px!important;
            height: 150px!important;
        }
        .card-width {
            padding: 20px!important;
        }
        .btn-1 {
            max-width: 90px!important;
        }
        .btn-2 {
            float: left!important;
        }
        #save {
            margin-top: 30px!important;
        }
        .qrcode1 {
            float: right;
            width: 200px;
            height: 200px;
        }
        .qrcode2 {
            float: right;
            width: 200px;
            height: 200px;
            opacity: 0.3;
        }
        @media (max-width: 991.98px) { 
            #qrcode-cap1 {
                margin-top: 200px;
                margin-left: -210px;
            }
    
            #qrcode-cap2 {
                margin-top: 10px;
                margin-left: -230px;
                width: 300px;
                text-align: justify;
            }
    
            .qrcode-cap3  {
                margin-left: -230px !important;
            }
        }
    </style>
    
    <script lang="ts">
    import { defineComponent} from 'vue'
    import Footer from '../components/Footer.vue';
    import jQuery from 'jquery';
    import axios from 'axios';
    
    // const selectedFile = ref<File | null>(null);
    
    const api = axios.create({
        baseURL: "http://127.0.0.1:3000",
        headers: {'Accept': 'application/json',
                  'Content-Type': 'application/json'}
    })
    
    export default defineComponent({
        name: 'Profile-Page',
        components: {
            Footer,
        },
        data() {
            return {
                userid: '',
                token: '',
                firstname: '',
                lastname: '',
                email: '',
                mobile: '',
                password: '',
                confpassword: '',
                qrcodeurl: '',
                profileMsg: '',
                profilepic: "",
                chgPwd: false,
                chkMfa: false,
                showSave: false,
            }
        },
        mounted(){
            const _usrid = sessionStorage.getItem('USERID');
            if (_usrid) {
                this.userid = _usrid
            }
            const _token = sessionStorage.getItem("TOKEN");
            if (_token) {
                this.token = _token
            }
            this.profileMsg = "wait...retrieving profile...";
            this.getUserprofile();
        },
        methods: {
            getUserprofile: async function() {
              await api.get(`api/getuserid/${this.userid}`, { headers: {
                Authorization: `Bearer ${this.token}`
            }} )
                .then((res: any) => {
                        this.profileMsg = res.data.message;
                        this.firstname = res.data.firstname;
                        this.lastname = res.data.lastname;
                        this.email = res.data.email;
                        this.mobile = res.data.mobile;
                        this.profilepic = res.data.userpic;
                        if (res.data.qrcodeurl == null) {
                            this.qrcodeurl = 'http://127.0.0.1:3000/images/qrcode.png';
                        } else {
                            let qrcode: any = 'data:image/png;base64,'+res.data.qrcodeurl;
                            this.qrcodeurl = qrcode;
                        }
                        setTimeout(() => {
                            this.profileMsg = '';    
                        }, 1000);
                  }, (error: any) => {
                        if (error.response) {
                            this.profileMsg = error.response.data.message;
                        } else {
                            this.profileMsg = error.message;
                        }
                        setTimeout(() => {
                            this.profileMsg = '';    
                        }, 3000);
                });
            },
            submitProfile: function() {
                const data =JSON.stringify({lastname: this.lastname, 
                    firstname: this.firstname, mobile: this.mobile });
    
                api.patch(`/api/updateprofile/${this.userid}`, data, { headers: {
                Authorization: `Bearer ${this.token}`
                }} )
                .then((res: any) => {
                        this.profileMsg = res.data.message;
                        window.setTimeout(() => {
                            this.profileMsg = '';
                        }, 3000);
                        return;
                  }, (error: any) => {
                        if (error.response) {
                            this.profileMsg = error.response.data.message;
                        } else {
                            this.profileMsg = error.message;
                        }
                        window.setTimeout(() => {
                            this.profileMsg = '';
                        }, 3000);
                        return;
                });
    
            },
            changePassword: function() {
                if (this.password === '') {
                    this.profileMsg = "Please enter New Password.";
                    setTimeout(() => {
                        this.profileMsg = '';
                    }, 3000);
                    return;
                }
                if (this.confpassword === '') {
                    this.profileMsg = "Please confirm New Password.";
                    setTimeout(() => {
                        this.confpassword = '';
                    }, 3000);
                    return;
                }
                if (this.password != this.confpassword) {
                    this.profileMsg = "New Password does not matched.";
                    setTimeout(() => {
                        this.profileMsg = '';
                    }, 3000);
                    return;
                }
                const data =JSON.stringify({password: this.password });
                api.patch(`api/changepassword/${this.userid}`, data, { headers: {
                Authorization: `Bearer ${this.token}`
                }} )
                .then((res: any) => {
                        this.profileMsg = res.data.message;
                        window.setTimeout(() => {
                            this.profileMsg = '';
                        }, 3000);
                  }, (error) => {
                    if (error.response) {
                            this.profileMsg = error.response.data.message;
                    } else {
                        this.profileMsg = error.message;
                    }
                    window.setTimeout(() => {
                            this.profileMsg = '';
                        }, 3000);
                        return;
                });
    
    
            },
            changePicture: function(event: any) {
                event.preventDefault();            
                    jQuery("#userpic").attr('src',URL.createObjectURL(event.target.files[0]));
                    const formdata = new FormData();
                    formdata.append('userpic', event.target.files[0]);
    
                    api.patch(`api/uploadpicture/${this.userid}`, formdata, { headers: {
                    'Content-Type': 'multipart/form-data',
                    Authorization: `Bearer ${this.token}`
                    }} )
                    .then((res: any) => {
                        this.profileMsg = res.data.message;
                        setTimeout(() => {
                            sessionStorage.setItem('USERPIC',res.data.userpic);
                            this.profileMsg = '';
                            this.profilepic = res.data.userpic;
                            location.reload();
                        }, 3000);
                    }, (error: any) => {
                        if (error.response) {
                            this.profileMsg = error.response.data.message;
                        } else {
                            this.profileMsg = error.message;
                        }
                        window.setTimeout(() => {
                                this.profileMsg = '';
                            }, 3000);
                            return;
                    });    
            },
            checkboxPassword: function() {
                if (this.chgPwd) {
                    jQuery("#cpwd").show();
                    jQuery("#mfa1").hide();  
                    jQuery("#mfa2").hide();  
                    this.chgPwd = true;
                    this.chkMfa = false;
                    this.showSave = true;
                    // $('#chkMfa').prop('checked', false);
                } else {
                    this.password = '';
                    this.confpassword = '';
                    this.showSave = false;
                    this.chgPwd = false;
                    jQuery("#cpwd").hide();
                }
            },
            checkboxMFA: function() {
                if (this.chkMfa) {
                    jQuery("#cpwd").hide();
                    jQuery("#mfa1").show();
                    jQuery("#mfa2").show();
                    this.chgPwd = false;
                    this.showSave = true;
                } else {
                    jQuery("#mfa1").hide();  
                    jQuery("#mfa2").hide();                  
                    this.showSave = false;
                }
            },
            enableMFA: function() {
                const data =JSON.stringify({TwoFactorEnabled: true });
                api.patch(`api/mfa/activate/${this.userid}`, data, { headers: {
                'Content-Type': 'application/json',
                Authorization: `Bearer ${this.token}`
                }})
                .then((res: any) => {
                        this.profileMsg = res.data.message;
                        window.setTimeout(() => {
                            this.profileMsg = '';
                            let qrcode: any = 'data:image/png;base64,'+res.data.qrcodeurl;
                            this.qrcodeurl = qrcode;
                        }, 2000);
                  }, (error) => {
                    if (error.response) {
                            this.profileMsg = error.response.data.message;
                    } else {
                        this.profileMsg = error.message;
                    }
                    window.setTimeout(() => {
                            this.profileMsg = '';
                        }, 3000);
                });
            },
            disableMFA: function() {
                const data =JSON.stringify({TwoFactorEnabled: false });
                api.patch(`api/mfa/activate/${this.userid}`, data, { headers: {
                    Authorization: `Bearer ${this.token}`
                }} )
                .then((res: any) => {
                        this.qrcodeurl = 'http://127.0.0.1:3000/images/qrcode.png';
                        this.profileMsg = res.data.message;
                        window.setTimeout(() => {
                            this.profileMsg = '';
                        }, 3000);
                  }, (error) => {
                        if (error.response) {
                            this.profileMsg = error.response.data.message;
                        } else {
                            this.profileMsg = error.message;
                        }
                        window.setTimeout(() => {
                            this.profileMsg = '';
                        }, 3000);
                });
    
            },
    
        }
    
    })
    </script>
    