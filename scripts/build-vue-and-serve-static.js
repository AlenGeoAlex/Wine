// scripts/build-vue-and-serve-static.js

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// --- Configuration ---
// Get the absolute path of the monorepo root
const MONOREPO_ROOT = process.cwd();

// Path to the vue-client package
const VUE_CLIENT_PATH = path.join(MONOREPO_ROOT, 'apps', 'web-vue-client');

// Path to the build output of the vue-client
const VUE_CLIENT_BUILD_OUTPUT = path.join(VUE_CLIENT_PATH, 'dist');

// The final destination for the static assets
const DESTINATION_PATH = path.join(
    MONOREPO_ROOT,
    'apps',
    'wine-server',
    'static'
);
// --- End Configuration ---


// --- Helper for logging ---
const log = {
    info: (msg) => console.log(`\x1b[34mℹ ${msg}\x1b[0m`),
    success: (msg) => console.log(`\x1b[32m✔ ${msg}\x1b[0m`),
    error: (msg) => console.error(`\x1b[31m✖ ${msg}\x1b[0m`),
    step: (msg) => console.log(`\n\x1b[33m▶ ${msg}\x1b[0m`),
};


/**
 * Main function to run the build and copy process.
 */
function main() {
    try {
        // --- Step 1: Build the Vue client ---
        log.step('Building the Vue client...');
        log.info(`Running 'pnpm build' in ${VUE_CLIENT_PATH}`);

        // Execute the build command within the vue-client directory.
        // 'stdio: inherit' will show the build output directly in your console.
        execSync('pnpm build', { cwd: VUE_CLIENT_PATH, stdio: 'inherit' });

        log.success('Vue client built successfully.');


        // --- Step 2: Verify build output ---
        log.step('Verifying build output...');
        if (!fs.existsSync(VUE_CLIENT_BUILD_OUTPUT)) {
            throw new Error(`Build output directory not found at: ${VUE_CLIENT_BUILD_OUTPUT}`);
        }
        log.success('Build output found.');


        // --- Step 3: Prepare the destination directory ---
        log.step('Preparing destination directory...');
        log.info(`Cleaning and creating: ${DESTINATION_PATH}`);

        // Remove the destination directory if it exists to ensure a clean copy
        if (fs.existsSync(DESTINATION_PATH)) {
            fs.rmSync(DESTINATION_PATH, { recursive: true, force: true });
        }

        // Create the nested destination directory
        fs.mkdirSync(DESTINATION_PATH, { recursive: true });
        log.success('Destination directory is ready.');


        // --- Step 4: Copy files to destination ---
        log.step('Copying built files...');
        log.info(`Copying from ${VUE_CLIENT_BUILD_OUTPUT} to ${DESTINATION_PATH}`);

        // Use the modern, recursive copy method
        fs.cpSync(VUE_CLIENT_BUILD_OUTPUT, DESTINATION_PATH, { recursive: true });

        log.success('All files copied successfully!');

        console.log('\n\x1b[35m✨ Process complete.\x1b[0m');

    } catch (error) {
        log.error('An error occurred during the process.');
        log.error(error.message);
        process.exit(1); // Exit with a failure code
    }
}

// Run the main function
main();