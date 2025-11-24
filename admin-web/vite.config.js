import { defineConfig } from "vite";
import laravel from "laravel-vite-plugin";

const currentIP = "192.168.1.16";

export default defineConfig({
    plugins: [
        laravel({
            input: ["resources/css/app.css", "resources/js/app.js"],
            refresh: true,
        }),
    ],

    server: {
        host: currentIP,
        port: 5173,
        cors: true,
        hmr: {
            host: currentIP,
        },
    },
});
