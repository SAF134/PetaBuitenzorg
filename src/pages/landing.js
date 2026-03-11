/**
 * PetaBuitenzorg — Landing Page
 */

import hotelsData from '../../data/hotels.json';
import hospitalsData from '../../data/hospitals.json';
import mallsData from '../../data/malls.json';
import spbuData from '../../data/gasstations.json';
import logoImg from '../assets/Logo.png';

export function renderLanding(container) {
  container.innerHTML = `
    <section class="landing" id="landing-page">
      <div class="landing__orb2"></div>
      <div class="landing__content">
        <div class="landing__logo"><img src="${logoImg}" alt="PetaBuitenzorg Logo" class="landing__logo-img" /></div>
        <h1 class="landing__title">PetaBuitenzorg</h1>
        <p class="landing__subtitle">Aplikasi Pemetaan Lokasi di Bogor</p>

        <div class="landing__categories">
          <a href="#/hotel" class="category-card category-card--hotel" id="btn-hotel">
            <div class="category-card__icon">🏨</div>
            <div class="category-card__label">Hotel</div>
            <div class="category-card__count">${hotelsData.length} Lokasi</div>
          </a>
          <a href="#/rumah-sakit" class="category-card category-card--rs" id="btn-rs">
            <div class="category-card__icon">🏥</div>
            <div class="category-card__label">Rumah Sakit</div>
            <div class="category-card__count">${hospitalsData.length} Lokasi</div>
          </a>
        </div>
        <div class="landing__categories" style="margin-top: 16px;">
          <a href="#/mall" class="category-card category-card--mall" id="btn-mall" style="border-top-color: #d946ef;">
            <div class="category-card__icon">🛍️</div>
            <div class="category-card__label">Mall</div>
            <div class="category-card__count">${mallsData.length} Lokasi</div>
          </a>
          <a href="#/spbu" class="category-card category-card--spbu" id="btn-spbu" style="border-top-color: #ea580c;">
            <div class="category-card__icon">⛽</div>
            <div class="category-card__label">SPBU</div>
            <div class="category-card__count">${spbuData.length} Lokasi</div>
          </a>
        </div>

        <div class="landing__map-cta">
          <a href="#/peta" class="btn btn--primary btn--full" id="btn-peta">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="1 6 1 22 8 18 16 22 23 18 23 2 16 6 8 2 1 6"/><line x1="8" y1="2" x2="8" y2="18"/><line x1="16" y1="6" x2="16" y2="22"/></svg>
            Lihat Peta Interaktif
          </a>
        </div>
      </div>

      <div class="landing__footer">
        © 2026 PetaBuitenzorg
      </div>
    </section>
  `;
}
