import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';

export default defineConfig({
    plugins: [
        laravel({
            input: [
                'resources/css/filament.scss',
                'resources/js/filament.js'
            ],
            refresh: true,
        }),
    ],
    build: {
        manifest: true,       // Generate manifest.json
        outDir: 'public/build', // Place build files in public/build
        assetsDir: '',         // Avoid nested asset directories
    },
});
