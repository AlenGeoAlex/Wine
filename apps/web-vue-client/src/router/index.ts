import { createRouter, createWebHistory } from 'vue-router'
import NotFoundPage from "@/pages/NotFoundPage.vue";
import HomePageView from "@/pages/HomePageView.vue";

const router = createRouter({
    history: createWebHistory(import.meta.env.BASE_URL),
    routes: [
        {
            path: '/:id',
            name: 'home',
            component: HomePageView
        },
        {
            path: '/:pathMatch(.*)*', // This regex matches everything
            name: 'NotFound',
            component: NotFoundPage
        }
    ]
})

export default router