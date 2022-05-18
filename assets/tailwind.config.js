module.exports = {
  content: [
    './js/**/*.js',
    '../lib/*_web.ex',
    '../lib/*_web/**/*.*ex',
  ],
  theme: {
    container: {
      center: true,
    },
    extend: {
      colors: {
        neutral: {
          750: '#323232',
        },
      },
      fontFamily: {
        'story': ['fantasy']
      },
      fontWeight: {
        'story': 'bolder'
      }
    },
    screens: {
      'smphone': '260px',
      'mdphone': '290px',
      'lgphone': '360px',
      'xlphone': '390px',
      '2xlphone': '410px',
      '3xlphone': '500px',
      'sm': '640px',
      // => @media (min-width: 640px) { ... }

      'md': '768px',
      // => @media (min-width: 768px) { ... }

      '900': '900px',
      // => @media (min-width: 768px) { ... }

      'lg': '1024px',
      // => @media (min-width: 1024px) { ... }

      'xl': '1280px',
      // => @media (min-width: 1280px) { ... }

      '2xl': '1400px',

      '3xl': '1820px',

      // => @media (min-width: 1536px) { ... }
      '5xl': '2500px'
    },
    spacing: {
      px: '1px',
      0: '0',
      0.125: '0.125rem',
      0.25: '0.25rem',
      0.375: '0.375rem',
      0.5: '0.5rem',
      0.625: '0.625rem',
      0.75: '0.75rem',
      0.875: '0.875rem',
      1: '1rem',
      1.25: '1.25rem',
      1.5: '1.5rem',
      1.75: '1.75rem',
      2: '2rem',
      2.25: '2.25rem',
      2.5: '2.5rem',
      2.75: '2.75rem',
      3: '3rem',
      3.5: '3.5rem',
      4: '4rem',
      5: '5rem',
      6: '6rem',
      7: '7rem',
      8: '8rem',
      9: '9rem',
      10: '10rem',
      11: '11rem',
      12: '12rem',
      13: '13rem',
      14: '14rem',
      15: '15rem',
      16: '16rem',
      18: '18rem',
      20: '20rem',
      22: '22rem',
      24: '24rem',
      26: '26rem',
      28: '28rem',
      30: '30rem',
      32: '32rem',
      34: '34rem',
      36: '36rem',
      38: '38rem',
      40: '40rem',
      42: '42rem',
      44: '44rem',
      46: '46rem',
      48: '48rem',
      50: '50rem',
      52: '52rem',
      54: '54rem',
      56: '56rem',
      58: '58rem',
      60: '60rem',
      62: '62rem',
      64: '64rem',
      66: '66rem',
      68: '68rem',
      70: '70rem',
    }
  },
  variants: {},
  plugins: []
}
