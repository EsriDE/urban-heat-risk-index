export default {
  server: {
    port: 3000
  },
  base: "./",
  build: {
    target: "es2020",
  },
  css: {
    preprocessorOptions: {
      scss: {
        api: 'modern-compiler'
      }
    }
  }
}
