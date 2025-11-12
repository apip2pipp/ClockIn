/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./resources/**/*.blade.php",
    "./resources/**/*.js",
    "./resources/**/*.vue",
  ],
  theme: {
    extend: {
      colors: {
        'clockin-blue': '#2D3E5F',
        'clockin-dark': '#1E293B',
        'clockin-teal': '#3B82A0',
        'clockin-green': '#4ADE80',
        'clockin-green-dark': '#22C55E',
      },
      fontFamily: {
        sans: ['Inter', 'ui-sans-serif', 'system-ui', 'sans-serif'],
      },
    },
  },
  plugins: [],
}
