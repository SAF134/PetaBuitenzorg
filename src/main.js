/**
 * PetaBuitenzorg — Main Application Entry
 * SPA initialization, routing, and navigation logic
 */

import { Router } from './router.js';
import { renderLanding } from './pages/landing.js';
import { renderList } from './pages/list.js';
import { renderDetail } from './pages/detail.js';
import { renderMap } from './pages/map.js';
import { initLocation } from './data.js';
import { StatusBar, Style } from '@capacitor/status-bar';
import { App } from '@capacitor/app';

/**
 * Trigger haptic feedback (vibration) on mobile devices
 * @param {number} duration - Vibration duration in ms
 */
function triggerHaptic(duration = 10) {
    if ('vibrate' in navigator) {
        navigator.vibrate(duration);
    }
}

/**
 * Creates a material ripple effect on an element
 * @param {PointerEvent} e 
 * @param {HTMLElement} target 
 */
function createRipple(e, target) {
    target.classList.add('ripple-element');
    
    const ripple = document.createElement('span');
    ripple.className = 'ripple';
    
    const rect = target.getBoundingClientRect();
    const size = Math.max(rect.width, rect.height);
    const x = e.clientX - rect.left - size / 2;
    const y = e.clientY - rect.top - size / 2;
    
    ripple.style.width = ripple.style.height = `${size}px`;
    ripple.style.left = `${x}px`;
    ripple.style.top = `${y}px`;
    
    target.appendChild(ripple);
    
    ripple.addEventListener('animationend', () => {
        ripple.remove();
    });
}

// Global Interaction Monitor for Haptic Feedback
document.addEventListener('pointerdown', (e) => {
    // List of interactive selectors
    const selectors = [
        '.btn', 
        '.category-card', 
        '.map-page__filter-btn', 
        '.detail-page__back',
        '.filter-custom-btn',
        '.place-card'
    ];
    
    const target = e.target.closest(selectors.join(', '));
    if (target) {
        // Create Ripple Effect
        createRipple(e, target);

        // Subtle haptic for buttons (10ms)
        // Stronger haptic for major actions (30ms)
        const isMajorAction = target.classList.contains('btn--primary') || target.classList.contains('category-card');
        triggerHaptic(isMajorAction ? 25 : 12);
    }
});

// Navbar Elements
const app = document.getElementById('app');
const navbar = document.getElementById('navbar');
const exploreBtn = document.getElementById('nav-explore');
const exploreMenu = document.getElementById('nav-explore-menu');
const navOverlay = document.getElementById('nav-overlay');

// Initialize router
const router = new Router();

// Route definitions
router.add('/', (params, query) => {
    renderLanding(app);
    updateNavbar('landing');
});

router.add('/hotel', (params, query) => {
    renderList(app, 'hotel');
    updateNavbar('hotel');
});

router.add('/rumah-sakit', (params, query) => {
    renderList(app, 'rumah-sakit');
    updateNavbar('rumah-sakit');
});

router.add('/hotel/:id', (params, query) => {
    renderDetail(app, 'hotel', params.id);
    updateNavbar('detail');
});

router.add('/rumah-sakit/:id', (params, query) => {
    renderDetail(app, 'rumah-sakit', params.id);
    updateNavbar('detail');
});

router.add('/mall', (params, query) => {
    renderList(app, 'mall');
    updateNavbar('mall');
});

router.add('/mall/:id', (params, query) => {
    renderDetail(app, 'mall', params.id);
    updateNavbar('detail');
});

router.add('/spbu', (params, query) => {
    renderList(app, 'spbu');
    updateNavbar('spbu');
});

router.add('/spbu/:id', (params, query) => {
    renderDetail(app, 'spbu', params.id);
    updateNavbar('detail');
});

router.add('/peta', (params, query) => {
    renderMap(app, query);
    updateNavbar('peta');
});

// Toggle Explore Menu Logic
function toggleExplore(show) {
    if (show === undefined) show = !exploreMenu.classList.contains('active');
    
    if (show) {
        exploreMenu.classList.add('active');
        navOverlay.classList.add('active');
        exploreBtn.classList.add('active');
    } else {
        exploreMenu.classList.remove('active');
        navOverlay.classList.remove('active');
        exploreBtn.classList.remove('active');
    }
}

exploreBtn.addEventListener('click', (e) => {
    e.stopPropagation();
    toggleExplore();
});

navOverlay.addEventListener('click', () => toggleExplore(false));

// Close menu when clicking a category item
exploreMenu.addEventListener('click', (e) => {
    if (e.target.closest('.explore-menu__item')) {
        toggleExplore(false);
    }
});

// Navigation callback — used for page transitions
router.onNavigate = (path, params, query) => {
    // Scroll to top on page change
    window.scrollTo({ top: 0, behavior: 'instant' });
    // Always close explore menu on navigation
    toggleExplore(false);
};

/**
 * Update bottom navbar visibility and active state
 */
function updateNavbar(page) {
    // Hide navbar on landing page
    if (page === 'landing') {
        navbar.classList.add('hidden');
    } else {
        navbar.classList.remove('hidden');
    }

    // Update active states
    const items = navbar.querySelectorAll('.navbar__item');
    items.forEach(item => item.classList.remove('active'));

    if (page === 'landing') {
        document.getElementById('nav-home')?.classList.add('active');
    } else if (['hotel', 'rumah-sakit', 'mall', 'spbu'].includes(page)) {
        document.getElementById('nav-explore')?.classList.add('active');
    } else if (page === 'peta') {
        document.getElementById('nav-map')?.classList.add('active');
    }

    // Re-initialize Lucide icons for navbar & menu
    if (window.lucide) {
        window.lucide.createIcons();
    }
}

// Initialize
async function init() {
    // Mobile fixes for notch and status bar
    try {
        await StatusBar.hide();
    } catch (e) {
        console.warn("StatusBar not available", e);
    }

    initLocation(() => {
        router._resolve();
    });
    router.start();

    // Toast logic for exit confirmation
    let backButtonPressedOnce = false;
    let backButtonTimeout;

    function showToast(message) {
        let toastContainer = document.querySelector('.toast-container');
        if (!toastContainer) {
            toastContainer = document.createElement('div');
            toastContainer.className = 'toast-container';
            toastContainer.innerHTML = '<div class="toast"></div>';
            document.body.appendChild(toastContainer);
        }
        const toast = toastContainer.querySelector('.toast');
        toast.textContent = message;
        
        toastContainer.classList.add('active');
        setTimeout(() => {
            toastContainer.classList.remove('active');
        }, 2000);
    }

    // Handle Hardware Back Button for Android
    App.addListener('backButton', ({ canGoBack }) => {
        const path = window.location.hash || window.location.pathname;
        const isHome = path === '#/' || path === '/' || path === '';

        if (isHome) {
            if (backButtonPressedOnce) {
                App.exitApp();
            } else {
                backButtonPressedOnce = true;
                showToast('Tekan sekali lagi untuk keluar');
                clearTimeout(backButtonTimeout);
                backButtonTimeout = setTimeout(() => {
                    backButtonPressedOnce = false;
                }, 2000);
            }
        } else {
            // Otherwise, go back in history
            window.history.back();
        }
    });

    // Handle Hardware Back Button for Android (Legacy if no App plugin, but we have it now)
    if (window.lucide) {
        window.lucide.createIcons();
    }

    // Scroll to Top Logic
    const scrollTopBtn = document.getElementById('scroll-top');
    if (scrollTopBtn) {
        window.addEventListener('scroll', () => {
            if (window.scrollY > 300) {
                scrollTopBtn.classList.add('visible');
            } else {
                scrollTopBtn.classList.remove('visible');
            }
        });

        scrollTopBtn.addEventListener('click', () => {
            window.scrollTo({
                top: 0,
                behavior: 'smooth'
            });
        });
    }
}

// Wait for DOM
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
} else {
    init();
}
