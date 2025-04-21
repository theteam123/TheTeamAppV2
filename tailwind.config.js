/** @type {import('tailwindcss').Config} */
export default {
  content: [
    './index.html',
    './src/**/*.{vue,js,ts,jsx,tsx}'
  ],
  theme: {
    extend: {
      colors: {
        brand: {
          50: '#EBFDF7',
          100: '#D7FBEF',
          200: '#AFF7DF',
          300: '#87F3CF',
          400: '#5FEEBF',
          500: '#38DE9D',
          600: '#2DB27E',
          700: '#22865F',
          800: '#175A3F',
          900: '#0B2D20',
        }
      },
      fontFamily: {
        sans: [
          'Inter var',
          'ui-sans-serif',
          'system-ui',
          '-apple-system',
          'BlinkMacSystemFont',
          '"Segoe UI"',
          'Roboto',
          '"Helvetica Neue"',
          'Arial',
          '"Noto Sans"',
          'sans-serif',
          '"Apple Color Emoji"',
          '"Segoe UI Emoji"',
          '"Segoe UI Symbol"',
          '"Noto Color Emoji"',
        ],
      }
    },
  },
  plugins: [
    require('@tailwindcss/forms')
  ],
}