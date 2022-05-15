import svelte from 'rollup-plugin-svelte';
import commonjs from '@rollup/plugin-commonjs';
import resolve from '@rollup/plugin-node-resolve';
import livereload from 'rollup-plugin-livereload';
import { terser } from 'rollup-plugin-terser';
import sveltePreprocess from 'svelte-preprocess';
import typescript from '@rollup/plugin-typescript';
import css from 'rollup-plugin-css-only';
import scss from 'rollup-plugin-scss'
import replace from "@rollup/plugin-replace";
import nodePolyfills from 'rollup-plugin-polyfill-node';

// const production = !process.env.ROLLUP_WATCH;
var environment = process.env.NODE_ENV
var production = environment !== 'development'

// Add here external dependencies that actually you use.
const globals = {
	'lodash': 'lodash'
};

function serve() {
	let server;

	function toExit() {
		if (server) server.kill(0);
	}

	return {
		writeBundle() {
			if (server) return;
			server = require('child_process').spawn('npm', ['run', 'start', '--', '--dev'], {
				stdio: ['ignore', 'inherit', 'inherit'],
				shell: true
			});

			process.on('SIGTERM', toExit);
			process.on('exit', toExit);
		}
	};
}

export default {
	input: 'src/svelte.ts',
	output: {
		sourcemap: true,
		format: 'iife',
		name: 'app',
		file: 'public/build/bundle.js',
		inlineDynamicImports: true,
		globals: globals
	},
	plugins: [
		nodePolyfills(),
		replace({
			preventAssignment: true,
			'BASE_URL': production ? 'https://gameserver.unnamedmud.com' : 'https://localhost:4000',
			'BASE_WEBSOCKET_URL': production ? 'wss://gameserver.unnamedmud.com/socket' : 'wss://localhost:4000/socket'
		}),
		svelte({
			preprocess: sveltePreprocess({
				postcss: true,  // And tells it to specifically run postcss!
			}),
			compilerOptions: {
				// enable run-time checks when not in production
				dev: !production
			}
		}),
		// we'll extract any component CSS out into
		// a separate file - better for performance
		css({ output: 'bundle.css' }),

		// If you have external dependencies installed from
		// npm, you'll most likely need these plugins. In
		// some cases you'll need additional configuration -
		// consult the documentation for details:
		// https://github.com/rollup/plugins/tree/master/packages/commonjs
		resolve({
			browser: true,
			dedupe: ['svelte']
		}),
		commonjs({
			include: /node_modules/,
			namedExports: {
				'node_modules/lodash/lodash.js': ['cloneDeep'],
			}
		}),
		typescript({
			sourceMap: true,
			inlineSources: !production
		}),

		// In dev mode, call `npm run start` once
		// the bundle has been generated
		!production && serve(),

		// Watch the `public` directory and refresh the
		// browser on changes when not in production
		!production && livereload('public'),

		// If we're building for production (npm run build
		// instead of npm run dev), minify
		production && terser(),
		scss()
	],
	watch: {
		clearScreen: false
	}
};
