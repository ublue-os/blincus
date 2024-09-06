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
						{ label: 'Why?', link: '/about/why/' },
						{ label: 'Features', link: '/about/features/' },
						{ label: 'How Blincus Works', link: '/about/how-blincus-works/' },
					],
				},
				{
					label: 'Guides',
					items: [
						// Each item here is one entry in the navigation menu.
						{ label: 'Getting Started', link: '/guides/getting-started/' },
						{ label: 'Installing Blincus', link: '/guides/installing/' },
						{ label: 'Your First Instance', link: '/guides/first-instance/' },
						{ label: 'Customizing Blincus with cloud-init', link: '/guides/customizing-cloudinit/' },
						{ label: 'Customizing Blincus without cloud-init', link: '/guides/customizing-nocloudinit/' },
						{ label: 'Tips & Tricks', link: '/guides/tips-tricks/' },
					],
				},
				{
					label: 'CLI Reference',
					autogenerate: { directory: 'cli' },
				},				{
					label: 'Get Help',
					items: [
						{ label: 'Troubleshooting', link: '/guides/troubleshooting/' },
						{ label: 'Github', link: 'https://github.com/ublue-os/blincus' },
						{ label: 'Discourse', link: 'https://universal-blue.discourse.group/' },
					],
				},

			],
		}),
	]
});
