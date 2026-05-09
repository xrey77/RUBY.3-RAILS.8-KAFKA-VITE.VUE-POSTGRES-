import { createRouter, createWebHistory, type RouteRecordRaw } from 'vue-router';
import Home from '../pages/Home.vue';
import About from '../pages/About.vue';
import Contact from '../pages/Contact.vue';
import Profile from '../pages/Profile.vue';
import List from '../pages/List.vue';
import Catalogs from '../pages/Catalogs.vue';
import Search from '../pages/Search.vue';

const routes: Array<RouteRecordRaw> = [
    { path: '/', name: 'Home', component: Home },
    { path: "/about",name: "About",component: About },
    { path: "/contact",name: "Contact",component: Contact },
    { path: "/profile",name: "Profile",component: Profile },
    { path: "/listproducts",name: "List",component: List},
    { path: "/listcatalogs",name: "Catalogs",component: Catalogs },
    { path: "/searchproduct",name: "Search",component: Search },
];

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL), // Use import.meta.env.BASE_URL with Vite
  routes,
});

export default router;
