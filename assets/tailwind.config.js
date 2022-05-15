module.exports = {
  purge: [
    '../lib/**/*.ex',
    '../lib/**/*.leex',
    '../lib/**/*.eex',
    './js/**/*.js'
  ],
  theme: {
    extend: {},
    fontFamily: {
      'story': ['fantasy']
    },
    fontWeight: {
      'story': 'bolder'
    }
  },
  variants: {},
  plugins: []
}
