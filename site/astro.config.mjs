import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

// https://astro.build/config
export default defineConfig({
	site: 'https://blincus.dev',
	integrations: [
		starlight({
			logo: {
				src: './src/assets/blincus-black.svg',
			  },
			head: [
				{
				  tag: 'script',
				  attrs: {
					src: 'https://a.ketelsen.cloud/script.js',
					'data-website-id': '95dd1266-3403-4efa-8d9f-c5e0988493b6',
					defer: true,
					async: true,
				  },
				},
			  ],
			title: 'Blincus',
			social: {
				github: 'https://github.com/ublue-os/blincus',
			},
			sidebar: [
				{
					label: 'About Blincus',
					items: [
						// Each item here is one entry in the navigation menu.
						{ label: 'Why?', link: '/reference/why/' },
						{ label: 'Features', link: '/reference/features/' },
						{ label: 'How Blincus Works', link: '/reference/how-blincus-works/' },
					],
				},
				{
					label: 'Guides',
					items: [
						// Each item here is one entry in the navigation menu.
						{ label: 'Getting Started', link: '/guides/getting-started/' },
						{ label: 'Installing Blincus', link: '/guides/installing/' },
						{ label: 'Customizing Blincus', link: '/guides/customizing/' },
						{ label: 'Tips & Tricks', link: '/guides/tips-tricks/' },
					],
				},
				{
					label: 'CLI Reference',
					autogenerate: { directory: 'cli' },
				},
			],
		}),
	],
});
