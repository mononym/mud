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
      fuchsia: colors.fuchsia,
      primary: {
        light: '#ffe168',
        DEFAULT: '#d4af37',
        dark: '#9f8000',
      },
      accent: {
        light: '#d05ce3',
        DEFAULT: '#9c27b0',
        dark: '#6a0080',
      },
      white: colors.white,
      black: colors.black
    },
    extend: {
      fontFamily: {
        sans: [...defaultTheme.fontFamily.sans],
      },
    },
    container: {
      center: true,
    },
  },
  variants: {},
  plugins: [],
};