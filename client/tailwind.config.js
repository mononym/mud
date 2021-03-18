const defaultTheme = require("tailwindcss/defaultTheme");
const colors = require('tailwindcss/colors')

module.exports = {
  future: {
    removeDeprecatedGapUtilities: true,
    purgeLayersByDefault: true,
  },
  purge: ["./src/**/*.svelte"],
  theme: {
    colors: {
      // Build your palette here
      transparent: 'transparent',
      current: 'currentColor',
      gray: colors.trueGray,
      red: colors.red,
      blue: colors.blue,
      yellow: colors.amber,
      accent: {
        light: '#f2e7c3',
        DEFAULT: '#d4af37',
        dark: '#c39623',
      },
      primary: {
        light: '#e1bee7',
        DEFAULT: '#9c27b0',
        dark: '#801797',
      },
      white: colors.white,
      black: colors.black
    },
    extend: {
      fontFamily: {
        sans: [...defaultTheme.fontFamily.sans],
      },
    },
  },
  variants: {},
  plugins: [],
};