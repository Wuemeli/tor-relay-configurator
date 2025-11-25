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
      script: [
        {
          defer: true,
          dataDomain: "tor-relay.dev",
          src: "https://googleisbad.wuemeli.com/js/script.outbound-links.tagged-events.js",
        },
      ],
    },
    link: [{ rel: "icon", type: "image/x-icon", href: "/favicon.ico" }],
  },
  vite: { plugins: [tailwindcss()] },
  css: ["~/assets/css/main.css"],
});
