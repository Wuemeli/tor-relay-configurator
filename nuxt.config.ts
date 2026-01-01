import tailwindcss from "@tailwindcss/vite";
export default defineNuxtConfig({
  ssr: true,
  devtools: true,

  app: {
    head: {
      charset: "utf-8",
      viewport: "width=device-width, initial-scale=1",
      title: "Tor-Relay Configurator",
      htmlAttrs: {
        lang: "en",
      },
    },
    link: [{ rel: "icon", type: "image/x-icon", href: "/favicon.ico" }],
  },

  vite: { plugins: [tailwindcss()] },
  css: ["~/assets/css/main.css"],

  nitro: {
    preset: "static",
    prerender: {
      failOnError: false,
      crawlLinks: true,
      routes: ["/"],
    },
  },

  modules: ["nuxt-umami"],

  umami: {
    id: "90c7973a-08b5-4e41-bc7e-d29800e1fdc0",
    host: "https://hahaitwackedyou.wuemeli.com",
    autoTrack: true,
  },
});
