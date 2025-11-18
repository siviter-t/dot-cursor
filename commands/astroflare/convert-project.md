# Convert Project to Astroflare Standards

This command converts any JAMstack or web project to Astroflare standards (Astro + Tailwind CSS v4 + Cloudflare Workers).

## Prerequisites

- Existing web project (JAMstack, static site, or any web project)
- Node.js 24.x installed
- pnpm >=10 installed

## Conversion Steps

### 1. Initialize Astro Project

If not already an Astro project:

```bash
# Create new Astro project in current directory or new directory
pnpm create astro@latest .

# Or create in new directory
pnpm create astro@latest my-astro-project
cd my-astro-project
```

### 2. Install Required Dependencies

```bash
# Core dependencies
pnpm add @astrojs/cloudflare @astrojs/sitemap astro-robots @tailwindcss/vite tailwindcss astro-seo

# Development dependencies
pnpm add -D wrangler typescript @types/node prettier prettier-plugin-astro eslint @eslint/js @typescript-eslint/eslint-plugin @typescript-eslint/parser eslint-plugin-astro eslint-config-prettier
```

### 3. Configure Astro for Cloudflare

Update `astro.config.mjs`:

```javascript
import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';
import sitemap from '@astrojs/sitemap';
import cloudflare from '@astrojs/cloudflare';
import robots from 'astro-robots';

export default defineConfig({
  site: 'https://your-domain.com', // Update with your domain
  integrations: [
    sitemap(),
    robots({
      sitemap: ['https://your-domain.com/sitemap-index.xml'],
      policy: [
        {
          userAgent: '*',
          allow: ['/'],
          disallow: ['/_actions/'],
        },
      ],
    }),
  ],
  vite: {
    plugins: [tailwindcss()],
  },
  adapter: cloudflare({
    imageService: 'compile',
    platformProxy: {
      enabled: true,
      experimental: { remoteBindings: true },
    },
  }),
  output: 'static',
  prefetch: false,
  build: {
    inlineStylesheets: 'auto',
  },
  trailingSlash: 'always',
  image: {
    remotePatterns: [{ protocol: 'https' }],
    service: {
      entrypoint: 'astro/assets/services/sharp',
      config: {
        limitInputPixels: false,
      },
    },
  },
  compressHTML: true,
  security: {
    checkOrigin: true,
  },
});
```

### 4. Setup Tailwind CSS v4

Create `src/styles/global.css`:

```css
@import 'tailwindcss';

@theme {
  /* Define your theme variables here */
  --color-brand: #your-color;
  /* Add more theme variables as needed */
}

@custom-variant dark (&:where([data-theme=dark], [data-theme=dark] *));
```

Import in your base layout (`src/layouts/BaseLayout.astro`):

```astro
---
import '../styles/global.css';
---
```

### 5. Create Project Structure

Create the following directory structure:

```
src/
  ├── components/
  │   ├── core/         # Reusable core components
  │   ├── forms/        # Form components
  │   ├── modals/       # Modal dialogs
  │   ├── animations/   # Animated components
  │   └── layout/       # Layout components
  ├── layouts/          # Page layouts
  ├── pages/            # File-based routing
  ├── actions/          # Server actions
  ├── client/           # Client-side utilities
  ├── server/           # Server utilities
  ├── styles/           # Global styles
  └── content/          # Content collections (if needed)
```

### 6. Setup TypeScript

Create/update `tsconfig.json`:

```json
{
  "extends": "astro/tsconfigs/strict",
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"]
    },
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true
  }
}
```

### 7. Create DOM Utilities

Create `src/client/dom.ts`:

```typescript
export const getElementById = <T extends HTMLElement>(
  id: string,
  ctor: { new (...args: unknown[]): T } | (Function & { prototype: T })
): T | null => {
  const element = document.getElementById(id);
  return element instanceof (ctor as Function) ? (element as T) : null;
};

export const getElementByIdOrThrow = <T extends HTMLElement>(
  id: string,
  ctor: { new (...args: unknown[]): T } | (Function & { prototype: T })
): T => {
  const element = getElementById(id, ctor);
  if (!element) {
    throw new Error(`Element with id ${id} not found`);
  }
  return element;
};

export const getElementByQuery = <T extends Element>(
  selector: string,
  root: Document | Element = document
): T | null => {
  return root.querySelector<T>(selector);
};

export const getElementByQueryOrThrow = <T extends Element>(
  selector: string,
  root: Document | Element = document
): T => {
  const element = getElementByQuery<T>(selector, root);
  if (!element) {
    throw new Error(`Element not found with selector ${selector}`);
  }
  return element;
};
```

### 8. Configure Cloudflare Workers

Create `wrangler.jsonc`:

```jsonc
{
  "$schema": "node_modules/wrangler/config-schema.json",
  "name": "your-project-name",
  "main": "./dist/_worker.js/index.js",
  "compatibility_date": "2025-09-08",
  "compatibility_flags": ["nodejs_compat"],
  "assets": {
    "binding": "ASSETS",
    "directory": "./dist"
  },
  "observability": {
    "enabled": true
  },
  "vars": {
    // Add non-secret environment variables here
  }
}
```

Create `.dev.vars` (add to `.gitignore`):

```
# Add secret environment variables for local development
# This file should NOT be committed
```

### 9. Setup Package Scripts

Update `package.json` scripts:

```json
{
  "scripts": {
    "dev": "astro dev",
    "build": "astro build",
    "preview": "pnpm run build && wrangler dev --port 8933",
    "deploy": "pnpm run build && wrangler deploy",
    "check": "astro check",
    "gen:types:astro": "astro sync",
    "gen:types:bindings": "wrangler types",
    "gen:types": "pnpm run gen:types:bindings && pnpm run gen:types:astro",
    "lint": "eslint .",
    "lint:fix": "eslint . --fix",
    "format": "prettier --write .",
    "format:check": "prettier --check .",
    "fix": "pnpm run format && pnpm run lint:fix"
  }
}
```

### 10. Migrate Content

**For Markdown/Content:**
- Move content to `src/content/` or `content/` directory
- Create content collection config in `src/content/config.ts`:

```typescript
import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';

const blog = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './content/blog' }),
  schema: z.object({
    title: z.string(),
    date: z.coerce.date(),
    // Add more fields as needed
  }),
});

export const collections = { blog };
```

**For Pages:**
- Convert HTML pages to `.astro` files in `src/pages/`
- Convert templates to Astro components in `src/components/`
- Use Astro's component syntax instead of template engines

**For Components:**
- Convert React/Vue/Svelte components to Astro components
- Use web components for client-side interactivity instead of framework components
- Move reusable components to `src/components/core/`

### 11. Convert Forms to Server Actions

**Old pattern (if using API routes):**
```javascript
// Old: /api/contact.js
export async function POST(request) { ... }
```

**New pattern (Astro Actions):**
```typescript
// src/actions/contact.ts
import { defineAction } from 'astro:actions';
import { z } from 'astro:schema';

const contactSchema = z.object({
  email: z.string().email(),
  message: z.string().min(1),
});

export const contact = defineAction({
  accept: 'form',
  input: contactSchema,
  handler: async (input, context) => {
    // Access env via context.locals.runtime.env
    // Handle form logic
    return { success: true };
  },
});
```

**Export in `src/actions/index.ts`:**
```typescript
import { contact } from './contact';

export const server = {
  contact,
};
```

**Use in forms:**
```astro
<form id="contact-form">
  <!-- form fields -->
</form>

<script>
  const form = document.getElementById('contact-form');
  form?.addEventListener('submit', async (e) => {
    e.preventDefault();
    const formData = new FormData(form);
    const response = await fetch('/_actions/contact', {
      method: 'POST',
      body: formData,
    });
    // Handle response
  });
</script>
```

### 12. Setup Prettier and ESLint

Create `.prettierrc`:

```json
{
  "printWidth": 100,
  "singleQuote": true,
  "jsxSingleQuote": true,
  "plugins": ["prettier-plugin-astro"]
}
```

Create `eslint.config.js` (or `.mjs`):

```javascript
import js from '@eslint/js';
import tseslint from 'typescript-eslint';
import astro from 'eslint-plugin-astro';
import prettier from 'eslint-config-prettier';

export default [
  js.configs.recommended,
  ...tseslint.configs.recommended,
  ...astro.configs.recommended,
  prettier,
  {
    rules: {
      // Add custom rules
    },
  },
];
```

### 13. Create Base Layout with Comprehensive SEO

Create `src/layouts/BaseLayout.astro` with full SEO implementation:

```astro
---
import '../styles/global.css';
import { SEO } from 'astro-seo';
import { ClientRouter } from 'astro:transitions';
import { SITE_TITLE, SITE_SLUG, site_url } from '@/config';

interface Props {
  title?: string;
  description?: string;
  image?: string;
  canonical?: string;
  noindex?: boolean;
  article?: boolean;
}

const {
  title = SITE_TITLE,
  description = 'Default description', // Page-specific, not from config
  image = `${site_url()}/og-image.png`,
  canonical,
  noindex = false,
  article = false,
} = Astro.props;

const canonicalURL = canonical || new URL(Astro.url.pathname, site_url());
const socialImage = new URL(image, site_url());
const pageTitle = title === SITE_TITLE ? title : `${title} | ${SITE_TITLE}`;
---

<!doctype html>
<html lang="en">
  <head>
    <!-- Basic Meta Tags -->
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="generator" content={Astro.generator} />
    <link rel="alternate" hreflang="en" href={canonicalURL.toString()} />

    <!-- SEO Meta Tags -->
    <SEO
      title={pageTitle}
      description={description}
      canonical={canonicalURL}
      openGraph={{
        basic: {
          title: pageTitle,
          type: article ? 'article' : 'website',
          image: socialImage.toString(),
          url: canonicalURL.toString(),
        },
        optional: {
          description: description,
          siteName: SITE_SLUG,
        },
      }}
      twitter={{
        card: 'summary_large_image',
        title: pageTitle,
        description: description,
        image: socialImage.toString(),
      }}
    />

    <!-- Robots meta tag -->
    {noindex && <meta name="robots" content="noindex, nofollow" />}

    <!-- Sitemap -->
    <link rel="sitemap" href="/sitemap-index.xml" />

    <!-- Favicons -->
    <link rel="icon" type="image/x-icon" href="/favicons/favicon.ico" />
    <link rel="icon" type="image/png" sizes="32x32" href="/favicons/favicon-32x32.png" />
    <link rel="icon" type="image/png" sizes="16x16" href="/favicons/favicon-16x16.png" />
    <link rel="apple-touch-icon" sizes="180x180" href="/favicons/apple-touch-icon.png" />
    <link rel="manifest" href="/favicons/site.webmanifest" />

    <!-- Schema.org structured data -->
    <script type="application/ld+json">
      {
        "@context": "https://schema.org",
        "@graph": [
          {
            "@type": "Person", // or "Organization", "LocalBusiness", etc.
            "@id": `${site_url()}/#person`,
            "name": "Author Name", // Page-specific, not from config
            "url": site_url(),
            "sameAs": [
              // Add social media links
            ]
          },
          {
            "@type": "WebSite",
            "@id": `${site_url()}/#website`,
            "url": site_url(),
            "name": SITE_TITLE,
            "publisher": {
              "@id": `${site_url()}/#person`
            }
          }
        ]
      }
    </script>

    <!-- Theme and performance -->
    <meta name="theme-color" content="#your-theme-color" />
    <meta name="color-scheme" content="dark light" />

    <!-- Client Router for View Transitions API -->
    <ClientRouter fallback="none" />
  </head>
  <body>
    <slot />
  </body>
</html>
```

Create `src/config.ts` for site configuration:

```typescript
export const SITE_TITLE = 'Your Site Title';
export const SITE_SLUG = 'your-site-slug';
export const SITE_DOMAIN = 'your-domain.com';

export function site_url(): string {
  return `https://${SITE_DOMAIN}`;
}
```

**Note:** Description, author, and email should be page-specific props, not in config.

### 14. Migrate Styling

**If using CSS frameworks:**
- Convert to Tailwind utility classes
- Move custom CSS to `src/styles/global.css` using `@theme` directive
- Use CSS custom properties for theming

**If using CSS-in-JS:**
- Convert to Tailwind classes or scoped `<style>` tags in Astro components
- Use CSS custom properties for dynamic values

### 15. Setup View Transitions (Optional)

Add loading spinner component (`src/components/core/ClientRouterLoadingSpinner.astro`):

```astro
<dialog id="loading" class="backdrop:bg-black/60 bg-transparent">
  <div class="spinner">Loading...</div>
</dialog>

<script is:inline>
  document.addEventListener('astro:before-preparation', () => {
    document.getElementById('loading')?.showModal();
  });
  
  document.addEventListener('astro:page-load', () => {
    document.getElementById('loading')?.close();
  });
</script>
```

### 16. Generate Types

```bash
pnpm gen:types
```

### 17. Test Locally

```bash
pnpm dev
# Visit http://localhost:4321
```

### 18. Build and Preview

```bash
pnpm build
pnpm preview
# Visit http://localhost:8933
```

## Migration Checklist

- [ ] Astro project initialized
- [ ] Dependencies installed
- [ ] Astro config updated for Cloudflare
- [ ] Tailwind CSS v4 configured
- [ ] Project structure created
- [ ] TypeScript configured
- [ ] DOM utilities created
- [ ] Cloudflare Workers configured
- [ ] Package scripts updated
- [ ] Content migrated
- [ ] Forms converted to server actions
- [ ] Prettier/ESLint configured
- [ ] Base layout created
- [ ] Styling migrated
- [ ] View transitions setup (optional)
- [ ] Types generated
- [ ] Tested locally
- [ ] Build successful

## Converting from Component Frameworks

### Planning Your Migration

**Assessment Phase:**
1. **Inventory your current stack:**
   - Framework (Gatsby, Next.js, Remix, etc.)
   - State management (Redux, Zustand, Context API, etc.)
   - Styling solution (CSS-in-JS, CSS modules, Tailwind, etc.)
   - Content management (CMS, markdown, headless CMS)
   - API routes / server functions
   - Build and deployment setup

2. **Identify migration strategy:**
   - **Incremental:** Migrate page by page (recommended for large sites)
   - **Big bang:** Complete rewrite (recommended for smaller sites)
   - **Hybrid:** Keep some pages in old framework, migrate others

3. **Map framework concepts to Astro:**
   - Framework components → Astro components
   - Client-side state → Web components or server-side data
   - API routes → Astro server actions
   - Framework plugins → Astro integrations
   - Build system → Astro build + Cloudflare adapter

### Common Framework Patterns

#### Site Configuration Migration
**From:** Framework config files (`gatsby-config.js`, `next.config.js`, etc.)  
**To:** `src/config.ts` with individual constants and helper function

```typescript
// src/config.ts
export const SITE_TITLE = 'Site Title';
export const SITE_SLUG = 'site-slug';
export const SITE_DOMAIN = 'your-domain.com';

export function site_url(): string {
  return `https://${SITE_DOMAIN}`;
}
```

**Note:** Only include site-level constants. Description, author, and email should be page-specific.

#### Layout Migration
**From:** Framework layout components (React, Vue, Svelte)  
**To:** Astro layout files in `src/layouts/`

- Remove framework-specific layout wrappers
- Convert to `.astro` files with `<slot />` for content
- Move SEO, meta tags, and global styles to layout

#### Component Migration
**From:** Framework components (JSX, Vue, Svelte)  
**To:** Astro components with web components for interactivity

- Convert static components to `.astro` files
- Replace client-side interactivity with web components
- Remove framework-specific hooks and state management

#### Content Migration
**From:** Framework content plugins (`gatsby-source-*`, `next-mdx`, etc.)  
**To:** Astro Content Collections with `glob` loader

```typescript
// src/content/config.ts
const blog = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './content/blog' }),
  schema: z.object({ title: z.string(), date: z.coerce.date() }),
});
```

#### API Routes Migration
**From:** Framework API routes (`/api/*`, `getServerSideProps`, etc.)  
**To:** Astro server actions in `src/actions/`

- Convert API endpoints to `defineAction()` functions
- Use `accept: 'form'` or `accept: 'json'` based on use case
- Access environment via `context.locals.runtime.env`

#### Styling Migration
**From:** CSS-in-JS, CSS modules, framework-specific styling  
**To:** Tailwind CSS v4 with `@theme` directive

- Convert styled components to Tailwind utility classes
- Move theme variables to `@theme` in `global.css`
- Use scoped `<style>` tags for component-specific styles

### Migration Checklist

- [ ] Audit current framework features and dependencies
- [ ] Create `src/config.ts` with site constants (SITE_TITLE, SITE_SLUG, SITE_DOMAIN, site_url())
- [ ] Set up Astro project structure
- [ ] Migrate layouts to Astro format
- [ ] Convert components (static → Astro, interactive → web components)
- [ ] Migrate content to Content Collections
- [ ] Convert API routes to server actions
- [ ] Migrate styling to Tailwind v4
- [ ] Update build and deployment configuration
- [ ] Test all functionality
- [ ] Update documentation

## Common Migration Patterns

### Converting React Components

**Before:**
```jsx
function Button({ children, onClick }) {
  return <button onClick={onClick}>{children}</button>;
}
```

**After:**
```astro
---
interface Props {
  onClick?: () => void;
}

const { onClick, children } = Astro.props;
---

<button data-onclick={onClick ? 'true' : undefined}>
  {children}
</button>

<script>
  const button = document.currentScript?.previousElementSibling;
  const onClick = button?.dataset.onclick;
  if (onClick) {
    button?.addEventListener('click', () => {
      // Handle click
    });
  }
</script>
```

Or use web component:
```astro
<custom-button data-onclick={onClick}>
  <slot />
</custom-button>

<script>
  class CustomButton extends HTMLElement {
    connectedCallback() {
      this.addEventListener('click', () => {
        // Handle click
      });
    }
  }
  customElements.define('custom-button', CustomButton);
</script>
```

### Converting API Routes

**Before:**
```javascript
// /api/users.js
export async function GET() {
  return Response.json({ users: [] });
}
```

**After:**
```typescript
// src/actions/users.ts
import { defineAction } from 'astro:actions';

export const getUsers = defineAction({
  accept: 'json',
  handler: async () => {
    return { users: [] };
  },
});
```

## SEO Best Practices

See the [Astroflare Standards](../rules/standards/astroflare.mdc) for comprehensive SEO implementation details including:
- Basic meta tags
- Open Graph and Twitter Card tags
- Schema.org structured data (Person/Organization/LocalBusiness)
- Additional SEO meta tags
- Favicons and manifest
- Performance hints
- Complete SEO checklist

## Post-Migration

1. Run `pnpm fix` to format and lint
2. Test all functionality
3. Verify SEO implementation (use tools like Google Rich Results Test)
4. Update deployment configuration
5. Deploy to Cloudflare Pages/Workers
6. Submit sitemap to search engines
7. Update documentation

## References

- [Astroflare Standards](../rules/standards/astroflare.mdc) - Complete standards and best practices
