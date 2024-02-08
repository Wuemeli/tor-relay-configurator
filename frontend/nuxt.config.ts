// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  ssr: true,
  devtools: true,
  app: {
    head: {
      charset: 'utf-8',
      viewport: 'width=device-width, initial-scale=1',
      title: 'Tor-Relay Configurator 🔥',
      htmlAttrs: {
        lang: 'en'
      },
      meta: [
        { hid: 'description', name: 'description', content: 'Tor Relay Configurator is a web application that helps you to configure your Tor relay. It even has a Leaderboard to compare your relay with others.' },
        { name: 'keywords', content: 'tor, relay, configurator, leaderboard, tor relay, tor configurator, tor leaderboard, tor relay configurator, tor relay leaderboard' },
        { name: 'author', content: 'Wuemeli' },
        { hid: 'og:title', property: 'og:title', content: 'Tor-Relay Configurator 🔥' },
        { hid: 'og:description', property: 'og:description', content: 'Tor Relay Configurator is a web application that helps you to configure your Tor relay. It even has a Leaderboard to compare your relay with others.' },
        { hid: 'og:url', property: 'og:url', content: 'https://tor-relay.dev' },
        { property: 'og:type', content: 'website' },
      ],
    },
    link: [{ rel: 'icon', type: 'image/x-icon', href: '/favicon.ico' }],
   },
    
  css: ['~/assets/css/main.css'],
  postcss: {
    plugins: {
      tailwindcss: {},
      autoprefixer: {},
    },
  },
})