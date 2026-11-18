export default {
  locales: [
    "en-US",
    "zh-CN",
    "fr-FR",
    "es-ES"
  ],
  extract: {
    input: "src/**/*.{js,jsx,mjs,ts,tsx}",
    output: "src/locales/{{language}}/{{namespace}}.json"
  }
}