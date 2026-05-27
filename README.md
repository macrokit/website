# macrokit.dev — landing site

Pre-launch landing for [macrokit.dev](https://macrokit.dev). Static HTML/CSS, no build step, no JS framework. Single page until Days 14–16 of the launch sprint when the full docs site (Astro Starlight or equivalent) replaces it.

## Layout

```
public/
├── index.html
├── styles.css
├── wordmark.svg
├── logo.svg
├── favicon.svg
├── robots.txt
└── sitemap.xml
```

Served as static files by nginx. No server runtime, no pm2 needed.

## Local preview

```sh
cd public && python3 -m http.server 8000
# open http://localhost:8000
```

## Production

- Server: EC2 (see ops notes — not committed to the repo).
- Document root: `/macrokit/website/public/`.
- Vhost: `deploy/nginx/macrokit.dev.conf` (committed; symlinked into `/etc/nginx/sites-enabled/` on the server).
- TLS: Let's Encrypt via certbot. Re-run after DNS A record is in place.

### Deploy

```sh
./deploy/deploy.sh
```

Pushes the `public/` tree to the server via rsync, reloads nginx.

## License

Apache 2.0 — same as the rest of the project. The site content is intentionally a mirror of the org-profile and core README copy; the source of truth lives in [github.com/macrokit/core](https://github.com/macrokit/core).
