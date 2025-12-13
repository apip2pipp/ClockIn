import laravel from "laravel-vite-plugin";
import { defineConfig } from "vite";

const currentIP = "192.168.18.129";

export default defineConfig({
    plugins: [
        laravel({
            input: [
                "resources/css/app.css",
                "resources/js/app.js",
                "resources/css/filament-admin.css",
            ],
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