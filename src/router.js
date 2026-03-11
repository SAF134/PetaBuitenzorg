/**
 * PetaBuitenzorg — SPA Hash Router
 * Lightweight hash-based routing without dependencies
 */

export class Router {
    constructor() {
        this.routes = [];
        this.currentPage = null;
        this.onNavigate = null;
    }

    /**
     * Register a route
     * @param {string} path - Route pattern (e.g., '/hotel/:id')
     * @param {Function} handler - Page render function
     */
    add(path, handler) {
        // Convert path pattern to regex
        const paramNames = [];
        const regexStr = path
            .replace(/:(\w+)/g, (_, name) => {
                paramNames.push(name);
                return '([^/]+)';
            })
            .replace(/\//g, '\\/');

        this.routes.push({
            path,
            regex: new RegExp(`^${regexStr}$`),
            paramNames,
            handler,
        });
    }

    /**
     * Start listening for hash changes
     */
    start() {
        window.addEventListener('hashchange', () => this._resolve());
        // Initial resolve
        this._resolve();
    }

    /**
     * Navigate to a path
     * @param {string} path
     */
    navigate(path) {
        window.location.hash = path;
    }

    /**
     * Resolve the current hash to a route
     */
    _resolve() {
        const hash = window.location.hash.slice(1) || '/';
        const [path, queryString] = hash.split('?');
        const query = Object.fromEntries(new URLSearchParams(queryString || ''));

        for (const route of this.routes) {
            const match = path.match(route.regex);
            if (match) {
                const params = {};
                route.paramNames.forEach((name, i) => {
                    params[name] = decodeURIComponent(match[i + 1]);
                });

                const executeNavigation = () => {
                    if (this.onNavigate) {
                        this.onNavigate(route.path, params, query);
                    }
                    route.handler(params, query);
                    this.currentPage = route.path;
                };

                // Use View Transitions API if supported
                if (document.startViewTransition) {
                    document.startViewTransition(() => executeNavigation());
                } else {
                    executeNavigation();
                }
                return;
            }
        }

        // 404 — fallback to landing
        this.navigate('/');
    }
}
