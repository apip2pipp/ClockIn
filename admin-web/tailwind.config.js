/** @type {import('tailwindcss').Config} */
import preset from "./vendor/filament/support/tailwind.config.preset";

export default {
    presets: [preset],
    content: [
        "./resources/**/*.blade.php",
        "./resources/**/*.js",
        "./resources/**/*.vue",
        "./app/Filament/**/*.php",
        "./resources/views/filament/**/*.blade.php",
        "./vendor/filament/**/*.blade.php",
    ],
    safelist: [
        // Dynamic colors untuk profile stats
        "bg-orange-100",
        "text-orange-600",
        "dark:bg-orange-500/10",
        "dark:text-orange-400",
        "bg-rose-100",
        "text-rose-600",
        "dark:bg-rose-500/10",
        "dark:text-rose-400",
    ],
    theme: {
        extend: {
            colors: {
                "clockin-blue": "#2D3E5F",
                "clockin-dark": "#1E293B",
                "clockin-teal": "#3B82A0",
                "clockin-green": "#4ADE80",
                "clockin-green-dark": "#22C55E",
            },
            fontFamily: {
                sans: ["Inter", "ui-sans-serif", "system-ui", "sans-serif"],
            },
        },
    },
    plugins: [],
};
