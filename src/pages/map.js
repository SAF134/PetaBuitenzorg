/**
 * PetaBuitenzorg — Map Page
 */

import { getAllPlaces, getHotels, getHospitals, getMalls, getGasStations, formatPrice, renderStars, getStarLabel, userLocation, fetchCurrentLocation, calculateDistance, formatDistance } from '../data.js';
import hotelsData from '../../data/hotels.json';
import gasStationsData from '../../data/gasstations.json';
import bogorBoundaryData from '../../data/bogor.json';
import L from 'leaflet';
import 'leaflet.markercluster';

let mapInstance = null;
let markersLayer = null; // will now hold markerClusterGroup
let currentFilters = {};

let activeCategory = 'semua';

export function renderMap(container, query = {}) {
  // Destroy previous map
  if (mapInstance) {
    mapInstance.remove();
    mapInstance = null;
  }


  activeCategory = query.kategori || 'semua';
  const isHotel = activeCategory === 'hotel';
  const isRS = activeCategory === 'rs';
  const isMall = activeCategory === 'mall';
  const isSPBU = activeCategory === 'spbu';

  const allFasilitas = isHotel
    ? [...new Set(hotelsData.flatMap(h => h.fasilitas))].sort()
    : [];

  const spbuFasilitas = isSPBU
    ? [...new Set(gasStationsData.flatMap(g => g.fasilitas || []))].sort()
    : [];

  const spbuPenawaran = isSPBU
    ? [...new Set(gasStationsData.flatMap(g => g.penawaran || []))].sort()
    : [];

  currentFilters = { search: '', sortBy: 'rating' };
  if (isHotel) {
    currentFilters.kategori = null;
    currentFilters.harga = null;
    currentFilters.minRating = null;
    currentFilters.fasilitas = [];
  } else if (isRS) {
    currentFilters.jenis = null;
    currentFilters.kelas = null;
    currentFilters.minRating = null;
  }

  let headerHtml = '';
  if (isHotel || isRS || isMall || isSPBU) {
    let typeLabel = isHotel ? 'hotel' : isRS ? 'rumah sakit' : isMall ? 'mall' : 'SPBU';
    headerHtml = `
      <div class="list-page__header gpu-accelerated" style="position: relative; z-index: 9999; flex: none; backdrop-filter: none; -webkit-backdrop-filter: none; background: var(--bg-primary);">

        <div class="list-page__search">
          <div class="search-input">
            <svg class="search-input__icon" xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
            <input type="text" id="search-input" placeholder="Cari ${typeLabel}..." autocomplete="off" />
          </div>
        </div>
        <div class="list-page__filter-bar" id="filter-bar">
          ${isHotel ? `
            <div class="filter-dropdown filter-dropdown--multi" id="fasilitas-dropdown">
              <button type="button" class="filter-select filter-multi-btn" id="fasilitas-toggle">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m12 3-1.912 5.813a2 2 0 0 1-1.275 1.275L3 12l5.813 1.912a2 2 0 0 1 1.275 1.275L12 21l1.912-5.813a2 2 0 0 1 1.275-1.275L21 12l-5.813-1.912a2 2 0 0 1-1.275-1.275L12 3Z"/><path d="M5 3v4"/><path d="M19 17v4"/><path d="M3 5h4"/><path d="M17 19h4"/></svg>
                Fasilitas <span class="filter-multi-count" id="fasilitas-count"></span>
                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
              </button>
              <div class="filter-multi-panel" id="fasilitas-panel">
                ${allFasilitas.map(f => `
                  <label class="filter-multi-option">
                    <input type="checkbox" value="${f}" class="fasilitas-cb" />
                    <span>${f}</span>
                  </label>
                `).join('')}
              </div>
            </div>
            <div class="filter-dropdown filter-custom-single" id="harga-dropdown">
              <button type="button" class="filter-select filter-custom-btn" data-default="Harga">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect width="20" height="12" x="2" y="6" rx="2"/><circle cx="12" cy="12" r="2"/><path d="M6 12h.01M18 12h.01"/></svg>
                <span class="filter-single-label">Harga</span>
                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
              </button>
              <div class="filter-multi-panel">
                <label class="filter-multi-option"><input type="radio" name="filter-harga" value="" checked /> <span> Harga</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-harga" value="200000" /> <span>≤ Rp 200.000</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-harga" value="400000" /> <span>≤ Rp 400.000</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-harga" value="600000" /> <span>≤ Rp 600.000</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-harga" value="800000" /> <span>≤ Rp 800.000</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-harga" value="1000000" /> <span>≤ Rp 1.000.000</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-harga" value="1000001" /> <span>> Rp 1.000.000</span></label>
              </div>
            </div>
            <div class="filter-dropdown filter-custom-single" id="kategori-dropdown">
              <button type="button" class="filter-select filter-custom-btn" data-default="Kategori">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M6 9H4.5a2.5 2.5 0 0 1 0-5H6"/><path d="M18 9h1.5a2.5 2.5 0 0 0 0-5H18"/><path d="M4 22h16"/><path d="M10 14.66V17c0 .55-.47.98-.97 1.21C7.85 18.75 7 20.24 7 22"/><path d="M14 14.66V17c0 .55.47.98.97 1.21C16.15 18.75 17 20.24 17 22"/><path d="M18 2H6v7a6 6 0 0 0 12 0V2Z"/></svg>
                <span class="filter-single-label">Kategori</span>
                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
              </button>
              <div class="filter-multi-panel">
                <label class="filter-multi-option"><input type="radio" name="filter-kategori" value="" checked /> <span> Kategori</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-kategori" value="1" /> <span>Bintang 1</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-kategori" value="2" /> <span>Bintang 2</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-kategori" value="3" /> <span>Bintang 3</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-kategori" value="4" /> <span>Bintang 4</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-kategori" value="5" /> <span>Bintang 5</span></label>
              </div>
            </div>
            <div class="filter-dropdown filter-custom-single" id="rating-dropdown">
              <button type="button" class="filter-select filter-custom-btn" data-default="Rating">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                <span class="filter-single-label">Rating</span>
                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
              </button>
              <div class="filter-multi-panel">
                <label class="filter-multi-option"><input type="radio" name="filter-rating" value="" checked /> <span> Rating</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-rating" value="4.5" /> <span>4.5+</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-rating" value="4" /> <span>4.0+</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-rating" value="3.5" /> <span>3.5+</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-rating" value="3" /> <span>3.0+</span></label>
              </div>
            </div>
          ` : isRS ? `
            <div class="filter-dropdown filter-custom-single" id="jenis-dropdown">
              <button type="button" class="filter-select filter-custom-btn" data-default="Jenis">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 14c1.49-1.46 3-3.21 3-5.5A5.5 5.5 0 0 0 16.5 3c-1.76 0-3 .5-4.5 2-1.5-1.5-2.74-2-4.5-2A5.5 5.5 0 0 0 2 8.5c0 2.3 1.5 4.05 3 5.5l7 7Z"/></svg>
                <span class="filter-single-label">Jenis</span>
                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
              </button>
              <div class="filter-multi-panel">
                <label class="filter-multi-option"><input type="radio" name="filter-jenis" value="" checked /> <span> Jenis</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-jenis" value="RSIA" /> <span>RSIA</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-jenis" value="RSJ" /> <span>RSJ</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-jenis" value="RSU" /> <span>RSU</span></label>
              </div>
            </div>
            <div class="filter-dropdown filter-custom-single" id="kelas-dropdown">
              <button type="button" class="filter-select filter-custom-btn" data-default="Kelas">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect width="18" height="11" x="3" y="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                <span class="filter-single-label">Kelas</span>
                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
              </button>
              <div class="filter-multi-panel">
                <label class="filter-multi-option"><input type="radio" name="filter-kelas" value="" checked /> <span> Kelas</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-kelas" value="A" /> <span>Kelas A</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-kelas" value="B" /> <span>Kelas B</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-kelas" value="C" /> <span>Kelas C</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-kelas" value="D" /> <span>Kelas D</span></label>
              </div>
            </div>
            <div class="filter-dropdown filter-custom-single" id="rating-dropdown-rs">
              <button type="button" class="filter-select filter-custom-btn" data-default="Rating">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                <span class="filter-single-label">Rating</span>
                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
              </button>
              <div class="filter-multi-panel">
                <label class="filter-multi-option"><input type="radio" name="filter-rating" value="" checked /> <span> Rating</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-rating" value="4.5" /> <span>4.5+</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-rating" value="4" /> <span>4.0+</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-rating" value="3.5" /> <span>3.5+</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-rating" value="3" /> <span>3.0+</span></label>
              </div>
            </div>
          ` : isSPBU ? `
            <div class="filter-dropdown filter-custom-single" id="jenis-spbu-dropdown">
              <button type="button" class="filter-select filter-custom-btn" data-default="Jenis">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10"/></svg>
                <span class="filter-single-label">Jenis</span>
                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
              </button>
              <div class="filter-multi-panel">
                <label class="filter-multi-option"><input type="radio" name="filter-jenis-spbu" value="" checked /> <span> Jenis</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-jenis-spbu" value="Pertamina" /> <span>Pertamina</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-jenis-spbu" value="Shell" /> <span>Shell</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-jenis-spbu" value="VIVO" /> <span>VIVO</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-jenis-spbu" value="BP" /> <span>BP</span></label>
              </div>
            </div>
            <div class="filter-dropdown filter-dropdown--multi" id="fasilitas-spbu-dropdown">
              <button type="button" class="filter-select filter-multi-btn" id="fasilitas-spbu-toggle">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m12 3-1.912 5.813a2 2 0 0 1-1.275 1.275L3 12l5.813 1.912a2 2 0 0 1 1.275 1.275L12 21l1.912-5.813a2 2 0 0 1 1.275-1.275L21 12l-5.813-1.912a2 2 0 0 1-1.275-1.275L12 3Z"/><path d="M5 3v4"/><path d="M19 17v4"/><path d="M3 5h4"/><path d="M17 19h4"/></svg>
                Fasilitas <span class="filter-multi-count" id="fasilitas-spbu-count"></span>
                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
              </button>
              <div class="filter-multi-panel" id="fasilitas-spbu-panel">
                ${spbuFasilitas.map(f => `
                  <label class="filter-multi-option">
                    <input type="checkbox" value="${f}" class="fasilitas-spbu-cb" />
                    <span>${f}</span>
                  </label>
                `).join('')}
              </div>
            </div>
            <div class="filter-dropdown filter-dropdown--multi" id="penawaran-spbu-dropdown">
              <button type="button" class="filter-select filter-multi-btn" id="penawaran-spbu-toggle">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 14c.2-1 .7-1.7 1.5-2.5 1-.9 1.5-2.2 1.5-3.5A5.5 5.5 0 0 0 12.5 2.5a5.1 5.1 0 0 0-3.5 1.5c-1 .8-1.5 1.8-1.5 3"/><path d="M11 22v-3"/><path d="M11 16v-1a2 2 0 0 0-2-2"/></svg>
                Penawaran <span class="filter-multi-count" id="penawaran-spbu-count"></span>
                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
              </button>
              <div class="filter-multi-panel" id="penawaran-spbu-panel">
                ${spbuPenawaran.map(p => `
                  <label class="filter-multi-option">
                    <input type="checkbox" value="${p}" class="penawaran-spbu-cb" />
                    <span>${p}</span>
                  </label>
                `).join('')}
              </div>
            </div>
            <div class="filter-dropdown filter-custom-single" id="rating-dropdown">
              <button type="button" class="filter-select filter-custom-btn" data-default="Rating">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                <span class="filter-single-label">Rating</span>
                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
              </button>
              <div class="filter-multi-panel">
                <label class="filter-multi-option"><input type="radio" name="filter-rating" value="" checked /> <span> Rating</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-rating" value="4.5" /> <span>4.5+</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-rating" value="4" /> <span>4.0+</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-rating" value="3.5" /> <span>3.5+</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-rating" value="3" /> <span>3.0+</span></label>
              </div>
            </div>
          ` : `
            <div class="filter-dropdown filter-custom-single" id="rating-dropdown">
              <button type="button" class="filter-select filter-custom-btn" data-default="Rating">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                <span class="filter-single-label">Rating</span>
                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
              </button>
              <div class="filter-multi-panel">
                <label class="filter-multi-option"><input type="radio" name="filter-rating" value="" checked /> <span> Rating</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-rating" value="4.5" /> <span>4.5+</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-rating" value="4" /> <span>4.0+</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-rating" value="3.5" /> <span>3.5+</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-rating" value="3" /> <span>3.0+</span></label>
              </div>
            </div>
          `}
            <div class="filter-dropdown filter-custom-single" id="distance-dropdown">
              <button type="button" class="filter-select filter-custom-btn" data-default="Radius">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="3 11 22 2 13 21 11 13 3 11"/></svg>
                <span class="filter-single-label">Radius</span>
                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
              </button>
              <div class="filter-multi-panel">
                <label class="filter-multi-option"><input type="radio" name="filter-distance" value="" checked /> <span> Radius</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-distance" value="10" /> <span>< 10 km</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-distance" value="8" /> <span>< 8 km</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-distance" value="6" /> <span>< 6 km</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-distance" value="4" /> <span>< 4 km</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-distance" value="2" /> <span>< 2 km</span></label>
              </div>
            </div>
          <button class="filter-reset-btn" id="filter-reset-btn" title="Reset Filter">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="1 4 1 10 7 10"/><path d="M3.51 15a9 9 0 1 0 2.13-9.36L1 10"/></svg>
          </button>
        </div>
        <div class="results-badge" id="list-count-badge">
          <i data-lucide="map-pin" style="width:12px; height:12px;"></i>
          <span id="list-count"></span>
        </div>
      </div>
    `;
  }

  container.innerHTML = `
    <div class="map-page gpu-accelerated" id="map-page" style="display: flex; flex-direction: column;">
      ${headerHtml}
      <div class="map-page__container" id="map-container" style="flex: 1; position: relative; z-index: 1;">
        <!-- Category Trigger Button (Center Top) -->
        <button class="map-page__category-trigger gpu-accelerated" id="category-trigger-btn" title="Pilih Kategori">
          <i data-lucide="${activeCategory === 'semua' ? 'compass' : (activeCategory === 'hotel' ? 'bed' : (activeCategory === 'rs' ? 'hospital' : (activeCategory === 'mall' ? 'shopping-bag' : (activeCategory === 'spbu' ? 'fuel' : 'compass'))))}"></i>
          <span>${activeCategory === 'semua' ? 'Semua' : (activeCategory === 'rs' || activeCategory === 'spbu' ? activeCategory.toUpperCase() : activeCategory.charAt(0).toUpperCase() + activeCategory.slice(1))}</span>
        </button>

        <!-- The button is pushed inside the relative container -->
        <button class="map-page__locate-btn gpu-accelerated" id="map-locate-btn" title="Lokasi Saya">
          <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="7"/><line x1="12" y1="2" x2="12" y2="5"/><line x1="12" y1="19" x2="12" y2="22"/><line x1="2" y1="12" x2="5" y2="12"/><line x1="19" y1="12" x2="22" y2="12"/></svg>
        </button>

        <!-- Category Popup Menu -->
        <div id="category-popup-overlay" class="category-popup-overlay"></div>
        <div id="category-popup-menu" class="category-popup-menu">
          <div class="category-popup-menu__grid">
            <div class="category-popup-menu__item ${activeCategory === 'hotel' ? 'active' : ''}" data-filter="hotel">
              <div class="icon-box icon-box--hotel"><i data-lucide="bed-double"></i></div>
              <span>Hotel</span>
            </div>
            <div class="category-popup-menu__item ${activeCategory === 'rs' ? 'active' : ''}" data-filter="rs">
              <div class="icon-box icon-box--rs"><i data-lucide="heart-pulse"></i></div>
              <span>RS</span>
            </div>
            <div class="category-popup-menu__item ${activeCategory === 'semua' ? 'active' : ''}" data-filter="semua">
              <div class="icon-box icon-box--semua"><i data-lucide="globe"></i></div>
              <span>Semua</span>
            </div>
            <div class="category-popup-menu__item ${activeCategory === 'mall' ? 'active' : ''}" data-filter="mall">
              <div class="icon-box icon-box--mall"><i data-lucide="shopping-bag"></i></div>
              <span>Mall</span>
            </div>
            <div class="category-popup-menu__item ${activeCategory === 'spbu' ? 'active' : ''}" data-filter="spbu">
              <div class="icon-box icon-box--spbu"><i data-lucide="fuel"></i></div>
              <span>SPBU</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  `;

  initMap();
  setupMapEvents();
  if (isHotel || isRS || isMall || isSPBU) {
    // startClock removed
  }
}



function initMap() {
  const mapContainer = document.getElementById('map-container');
  if (!mapContainer) return;

  // Jika lokasi user sudah ada (persisted), gunakan itu. Jika tidak, pakai center Bogor.
  const center = userLocation ? [userLocation.lat, userLocation.lng] : [-6.595, 106.800];
  const zoom = userLocation ? 15 : 13;

  mapInstance = L.map(mapContainer, {
    zoomControl: false,
    attributionControl: true,
  }).setView(center, zoom);

  const googleStreet = L.tileLayer('https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}', {
    maxZoom: 20,
    attribution: '&copy; Google Maps',
  });

  const googleSatellite = L.tileLayer('https://mt1.google.com/vt/lyrs=s,h&x={x}&y={y}&z={z}', {
    maxZoom: 20,
    attribution: '&copy; Google Maps',
  });

  googleStreet.addTo(mapInstance);

  // Add Bogor City Boundary
  const boundaryLayer = L.geoJSON(bogorBoundaryData, {
    style: {
      color: '#09b6c8',
      weight: 4,
      opacity: 0.8,
      fillColor: '#0a0e1a',
      fillOpacity: 0.05
    },
    interactive: false
  }).addTo(mapInstance);

  const baseLayers = {
    'Google Street Maps': googleStreet,
    'Google Satelit': googleSatellite,
  };

  const overlays = {
    'Batas Wilayah Bogor': boundaryLayer
  };

  L.control.layers(baseLayers, overlays, { position: 'bottomleft' }).addTo(mapInstance);

  addMarkers();

  setTimeout(() => mapInstance.invalidateSize(), 300);
}

function addMarkers() {
  clearRadiusLayers();

  if (markersLayer) {
    mapInstance.removeLayer(markersLayer);
  }

  markersLayer = L.markerClusterGroup({
    showCoverageOnHover: false,
    zoomToBoundsOnClick: true,
    maxClusterRadius: 50,
    chunkedLoading: true,
    iconCreateFunction: function (cluster) {
      const childCount = cluster.getChildCount();
      let c = ' custom-marker-cluster';
      if (childCount < 10) {
        c += ' custom-cluster-small';
      } else if (childCount < 50) {
        c += ' custom-cluster-medium';
      } else {
        c += ' custom-cluster-large';
      }

      if (activeCategory === 'mall') {
        c += ' custom-cluster-mall';
      } else if (activeCategory === 'spbu') {
        c += ' custom-cluster-spbu';
      }

      return new L.DivIcon({
        html: `<div><span>${childCount}</span></div>`,
        className: 'custom-cluster-icon' + c,
        iconSize: new L.Point(40, 40)
      });
    }
  });

  const bounds = [];

  let hotels = [];
  let hospitals = [];
  let malls = [];
  let spbus = [];
  let totalDataLength = 0;

  if (activeCategory === 'hotel') {
    hotels = getHotels(currentFilters);
    totalDataLength = getHotels().length;
  } else if (activeCategory === 'rs') {
    hospitals = getHospitals(currentFilters);
    totalDataLength = getHospitals().length;
  } else if (activeCategory === 'mall') {
    malls = getMalls(currentFilters);
    totalDataLength = getMalls().length;
  } else if (activeCategory === 'spbu') {
    spbus = getGasStations(currentFilters);
    totalDataLength = getGasStations().length;
  } else {
    // semua
    const all = getAllPlaces();
    hotels = all.hotels;
    hospitals = all.hospitals;
    malls = all.malls;
    spbus = all.gasStations;
  }

  // Update header count if exist
  const countEl = document.getElementById('list-count');
  const countBadge = document.getElementById('list-count-badge');
  if (countEl) {
    let currentCount = 0;
    if (activeCategory === 'hotel') currentCount = hotels.length;
    else if (activeCategory === 'rs') currentCount = hospitals.length;
    else if (activeCategory === 'mall') currentCount = malls.length;
    else if (activeCategory === 'spbu') currentCount = spbus.length;

    countEl.textContent = `${currentCount} dari ${totalDataLength} Lokasi`;
    if (countBadge) countBadge.classList.add('visible');
  }

  hotels.forEach(hotel => {
    let bgColor = '#3b82f6';
    switch (hotel.kategori) {
      case 5: bgColor = '#ef4444'; break;
      case 4: bgColor = '#f59e0b'; break;
      case 3: bgColor = '#8b5cf6'; break;
      case 2: bgColor = '#3b82f6'; break;
      case 1: bgColor = '#cbd5e1'; break;
    }

    const icon = L.divIcon({
      className: 'custom-marker',
      html: `<div style="width:40px;height:40px;background:${bgColor};border-radius:50%;border:4px solid white;box-shadow:0 3px 10px rgba(0,0,0,0.4);display:flex;align-items:center;justify-content:center;color:white;font-size:13px;font-weight:bold;gap:2px;cursor:pointer;">
        <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="currentColor" stroke="none"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
        ${hotel.kategori}
      </div>`,
      iconSize: [40, 40],
      iconAnchor: [20, 20],
    });

    const marker = L.marker([hotel.lat, hotel.lng], { icon })
      .bindPopup(createPopup(hotel, 'hotel'), {
        maxWidth: 260,
        minWidth: 240,
        closeButton: true,
        className: 'custom-popup',
      });

    markersLayer.addLayer(marker);
    bounds.push([hotel.lat, hotel.lng]);
  });

  hospitals.forEach(hospital => {
    let bgColor = '#ef4444';
    switch (hospital.jenis) {
      case 'RSIA': bgColor = '#e4680f'; break;
      case 'RSU': bgColor = '#22c55e'; break;
      case 'RSJ': bgColor = '#eab308'; break;
    }

    const icon = L.divIcon({
      className: 'custom-marker',
      html: `<div style="width:40px;height:40px;background:${bgColor};border-radius:50%;border:4px solid white;box-shadow:0 3px 10px rgba(0,0,0,0.4);display:flex;align-items:center;justify-content:center;color:white;font-size:16px;font-weight:bold;cursor:pointer;">${hospital.kelas || 'H'}</div>`,
      iconSize: [40, 40],
      iconAnchor: [20, 20],
    });

    const marker = L.marker([hospital.lat, hospital.lng], { icon })
      .bindPopup(createPopup(hospital, 'rumah-sakit'), {
        maxWidth: 260,
        minWidth: 240,
        closeButton: true,
        className: 'custom-popup',
      });

    markersLayer.addLayer(marker);
    bounds.push([hospital.lat, hospital.lng]);
  });

  malls.forEach(mall => {
    let bgColor = '#d946ef';

    const icon = L.divIcon({
      className: 'custom-marker',
      html: `<div style="width:40px;height:40px;background:${bgColor};border-radius:50%;border:4px solid white;box-shadow:0 3px 10px rgba(0,0,0,0.4);display:flex;align-items:center;justify-content:center;color:white;font-size:16px;font-weight:bold;cursor:pointer;">M</div>`,
      iconSize: [40, 40],
      iconAnchor: [20, 20],
    });

    const marker = L.marker([mall.lat, mall.lng], { icon })
      .bindPopup(createPopup(mall, 'mall'), {
        maxWidth: 260,
        minWidth: 240,
        closeButton: true,
        className: 'custom-popup custom-popup-mall',
      });

    markersLayer.addLayer(marker);
    bounds.push([mall.lat, mall.lng]);
  });

  spbus.forEach(spbu => {
    let bgColor = getSpbuBrandColor(spbu.jenis);

    const icon = L.divIcon({
      className: 'custom-marker',
      html: `<div style="width:40px;height:40px;background:${bgColor};border-radius:50%;border:4px solid white;box-shadow:0 3px 10px rgba(0,0,0,0.4);display:flex;align-items:center;justify-content:center;color:white;font-size:16px;font-weight:bold;cursor:pointer;">S</div>`,
      iconSize: [40, 40],
      iconAnchor: [20, 20],
    });

    const marker = L.marker([spbu.lat, spbu.lng], { icon })
      .bindPopup(createPopup(spbu, 'spbu'), {
        maxWidth: 260,
        minWidth: 240,
        closeButton: true,
        className: 'custom-popup custom-popup-spbu',
      });

    markersLayer.addLayer(marker);
    bounds.push([spbu.lat, spbu.lng]);
  });

  mapInstance.addLayer(markersLayer);

  // Draw radius circle if exists
  if (currentFilters.maxDistance && userLocation) {
    let circleColor = '#3b82f6';
    if (currentFilters.maxDistance == '10') circleColor = '#ef4444'; // Red for largest
    else if (currentFilters.maxDistance == '8') circleColor = '#f97316'; // Orange
    else if (currentFilters.maxDistance == '6') circleColor = '#eab308'; // Yellow
    else if (currentFilters.maxDistance == '4') circleColor = '#22c55e'; // Green
    else if (currentFilters.maxDistance == '2') circleColor = '#3b82f6'; // Blue for smallest

    const radiusLayer = L.circle([userLocation.lat, userLocation.lng], {
      color: circleColor,
      fillColor: circleColor,
      fillOpacity: 0.1,
      radius: parseInt(currentFilters.maxDistance) * 1000 // Convert km to meters
    }).addTo(mapInstance);

    // add to layers to be removed on next update
    if (!window._radiusLayer) {
      window._radiusLayers = [];
    }
    window._radiusLayers.push(radiusLayer);
  }

  if (bounds.length > 0) {
    mapInstance.fitBounds(bounds, { padding: [50, 50], maxZoom: 14 });
  } else if (currentFilters.maxDistance && userLocation) {
    // if no results inside radius, just pan to user location with circle
    mapInstance.setView([userLocation.lat, userLocation.lng], 13);
  }
}

function clearRadiusLayers() {
  if (window._radiusLayers) {
    window._radiusLayers.forEach(l => mapInstance.removeLayer(l));
    window._radiusLayers = [];
  }
}


function createPopup(item, type) {
  const isHotel = type === 'hotel';
  const isRS = type === 'rumah-sakit';

  let distanceHtml = '';
  if (userLocation) {
    const distKm = calculateDistance(userLocation.lat, userLocation.lng, item.lat, item.lng);
    distanceHtml = `
      <div class="map-popup__distance" style="font-size: 11px; color: var(--accent-teal); display: flex; align-items: center; gap: 4px; font-weight: 500; margin-top: 4px;">
        <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2v20"/></svg>
        <span style="color: var(--text-primary)">Berjarak ${formatDistance(distKm)}</span>
      </div>
    `;
  }

  return `
    <div class="map-popup">
      <div class="img-wrapper skeleton" style="height: 120px;">
        <img
          class="map-popup__img img-fade-in"
          src="${item.gambar}"
          alt="${item.nama}"
          decoding="async"
          onload="this.classList.add('loaded'); this.parentElement.classList.remove('skeleton');"
          onerror="this.style.display='none'; this.parentElement.classList.remove('skeleton');"
        />
      </div>
      <div class="map-popup__body">
        <div class="map-popup__name">${item.nama}</div>
        <div class="map-popup__meta" style="flex-direction: column; align-items: flex-start; gap: 4px; border-top: none; padding-top: 0;">
          <div style="display: flex; align-items: center; gap: 8px; width: 100%;">
            ${item.rating ? `
            <div class="rating" style="font-size:12px; display: flex; align-items: center; gap: 4px;">
              <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="var(--accent-gold)" stroke="var(--accent-gold)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
              <span class="rating__value" style="color: var(--text-primary); font-weight: 600;">${item.rating}</span>
            </div>` : ''}
            ${isHotel && item.kategori ? `
              <span class="badge" style="background: ${item.kategori === 5 ? '#ef4444' :
        item.kategori === 4 ? '#f59e0b' :
          item.kategori === 3 ? '#8b5cf6' :
            item.kategori === 2 ? '#3b82f6' : '#cbd5e1'
      }; color: ${item.kategori === 1 ? 'var(--bg-primary)' : 'white'}; font-size: 10px; padding: 2px 6px; border: none; letter-spacing: 1px; font-weight: 800;">
                ${'★'.repeat(item.kategori)}
              </span>
            ` : ''}
            ${isRS ? `
              <span class="badge" style="background: ${item.jenis === 'RSIA' ? '#e4680f' :
        item.jenis === 'RSJ' ? '#eab308' : 'var(--accent-green)'
      }; color: white; font-size: 10px; border: none; font-weight: 700;">${item.jenis}</span>
              <span class="badge" style="background: ${item.kelas === 'A' ? '#f97316' :
        item.kelas === 'B' ? 'var(--accent-purple)' :
          item.kelas === 'C' ? 'var(--accent-blue)' : 'var(--text-primary)'
      }; color: ${item.kelas === 'D' ? 'var(--bg-primary)' : 'white'}; font-size: 10px; border: none; font-weight: 700;">Kelas ${item.kelas}</span>
            ` : ''}
            ${type === 'spbu' && item.jenis ? `<span class="badge" style="background-color:${getSpbuBrandColor(item.jenis)};color:white;font-size:10px;padding:2px 6px;">${item.jenis}</span>` : ''}
          </div>
          ${isHotel ? `<div class="price" style="font-size:13px; font-weight: 700; color: var(--accent-green); margin-top: 2px; display: flex; align-items: center; gap: 4px;">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="flex-shrink:0;"><rect x="2" y="5" width="20" height="14" rx="2"/><line x1="2" y1="10" x2="22" y2="10"/></svg>
            ${formatPrice(item.harga)} <span style="font-size: 10px; font-weight: 400; color: var(--text-muted)">/malam</span>
          </div>` : ''}
        </div>
        ${distanceHtml}
        <a href="#/${type}/${item.id}" class="map-popup__link">
          Lihat Selengkapnya →
        </a>
      </div>
    </div>
  `;
}

function setupMapEvents() {
  const isHotel = activeCategory === 'hotel';
  const isRS = activeCategory === 'rs';
  const isMall = activeCategory === 'mall';
  const isSPBU = activeCategory === 'spbu';
  // Category popup logic
  const categoryBtn = document.getElementById('category-trigger-btn');
  const categoryMenu = document.getElementById('category-popup-menu');
  const categoryOverlay = document.getElementById('category-popup-overlay');

  const toggleCategoryMenu = (show) => {
    if (show === undefined) show = !categoryMenu.classList.contains('active');
    if (show) {
      categoryMenu.classList.add('active');
      categoryOverlay.classList.add('active');
    } else {
      categoryMenu.classList.remove('active');
      categoryOverlay.classList.remove('active');
    }
  };

  categoryBtn.addEventListener('click', (e) => {
    e.stopPropagation();
    toggleCategoryMenu();
  });

  categoryOverlay.addEventListener('click', () => toggleCategoryMenu(false));

  categoryMenu.addEventListener('click', (e) => {
    const item = e.target.closest('.category-popup-menu__item');
    if (!item) return;
    const filterTarget = item.dataset.filter;
    toggleCategoryMenu(false);
    window.location.hash = `#/peta?kategori=${filterTarget}`;
  });

  if (window.lucide) window.lucide.createIcons();

  // Locate me button
  const locateBtn = document.getElementById('map-locate-btn');
  locateBtn.addEventListener('click', async () => {
    locateBtn.style.color = 'var(--accent-teal)';
    const loc = await fetchCurrentLocation();
    
    if (loc) {
      mapInstance.setView([loc.lat, loc.lng], 15);

      const userIcon = L.divIcon({
        className: 'user-location-marker',
        html: '<div class="pulse-marker"></div>',
        iconSize: [20, 20],
        iconAnchor: [10, 10],
      });

      L.marker([loc.lat, loc.lng], { icon: userIcon })
        .bindPopup('<div class="map-popup__body"><div class="map-popup__name" style="font-family:Inter,sans-serif; text-align: center;">📍 Lokasi Anda</div></div>')
        .addTo(mapInstance);

      locateBtn.style.color = '';
    } else {
      locateBtn.style.color = '';
      alert('Gagal mendapatkan lokasi. Pastikan GPS aktif.');
    }
  });

  // List filters events if visible
  if (isHotel || isRS || isMall || isSPBU) {
    const searchInput = document.getElementById('search-input');
    let debounceTimer;
    searchInput.addEventListener('input', (e) => {
      clearTimeout(debounceTimer);
      debounceTimer = setTimeout(() => {
        currentFilters.search = e.target.value;
        addMarkers();
      }, 250);
    });

    let activeFilterId = null;

    const closeAllDropdowns = () => {
      document.querySelectorAll('.filter-custom-single.open, .filter-dropdown--multi.open').forEach(d => {
        d.classList.remove('open');
      });
      activeFilterId = null;
    };

    const toggleFilter = (dropdownId, triggerBtn, panel) => {
      const dropdown = document.getElementById(dropdownId);
      if (!dropdown) return;
      
      if (activeFilterId === dropdownId) {
        dropdown.classList.remove('open');
        activeFilterId = null;
      } else {
        closeAllDropdowns();
        dropdown.classList.add('open');
        activeFilterId = dropdownId;
        positionPanel(triggerBtn, panel);
      }
    };

    // Helper: position a fixed panel below its trigger button
    const positionPanel = (btn, panel) => {
      const rect = btn.getBoundingClientRect();
      const windowWidth = window.innerWidth;
      
      if (rect.left + 220 > windowWidth - 16) {
        panel.style.left = 'auto';
        panel.style.right = '0';
      } else {
        panel.style.left = '0';
        panel.style.right = 'auto';
      }
    };

    // Helper: setup a custom single-select dropdown
    const setupSingleDropdown = (dropdownId, onChange) => {
      const dropdown = document.getElementById(dropdownId);
      if (!dropdown) return;
      const btn = dropdown.querySelector('.filter-custom-btn');
      const panel = dropdown.querySelector('.filter-multi-panel');
      const labelEl = dropdown.querySelector('.filter-single-label');
      const defaultLabel = btn.dataset.default;

      btn.addEventListener('click', (e) => {
        e.stopPropagation();
        toggleFilter(dropdownId, btn, panel);
      });

      panel.querySelectorAll('input[type="radio"]').forEach(radio => {
        radio.addEventListener('change', () => {
          const selected = panel.querySelector('input[type="radio"]:checked');
          labelEl.textContent = selected && selected.value ? selected.nextElementSibling.textContent : defaultLabel;
          dropdown.classList.remove('open');
          onChange(selected ? selected.value : '');
        });
      });
    };

    // Close all custom dropdowns on outside click
    document.addEventListener('click', (e) => {
      if (!e.target.closest('.filter-custom-single') && !e.target.closest('.filter-dropdown--multi')) {
        closeAllDropdowns();
      }
    });

    if (isHotel) {
      setupSingleDropdown('kategori-dropdown', (val) => {
        currentFilters.kategori = val ? Number(val) : null;
        addMarkers();
      });
      setupSingleDropdown('harga-dropdown', (val) => {
        currentFilters.harga = val || null;
        addMarkers();
      });
      setupSingleDropdown('rating-dropdown', (val) => {
        currentFilters.minRating = val || null;
        addMarkers();
      });

      const fasilitasToggle = document.getElementById('fasilitas-toggle');
      const fasilitasPanel = document.getElementById('fasilitas-panel');
      const fasilitasDropdown = document.getElementById('fasilitas-dropdown');
      const fasilitasCount = document.getElementById('fasilitas-count');

      fasilitasToggle.addEventListener('click', (e) => {
        e.stopPropagation();
        toggleFilter('fasilitas-dropdown', fasilitasToggle, fasilitasPanel);
      });

      fasilitasPanel.querySelectorAll('.fasilitas-cb').forEach(cb => {
        cb.addEventListener('change', () => {
          const checked = fasilitasPanel.querySelectorAll('.fasilitas-cb:checked');
          currentFilters.fasilitas = Array.from(checked).map(c => c.value);
          fasilitasCount.textContent = currentFilters.fasilitas.length > 0
            ? `(${currentFilters.fasilitas.length})`
            : '';
          addMarkers();
        });
      });
    } else if (isRS) {
      setupSingleDropdown('jenis-dropdown', (val) => {
        currentFilters.jenis = val || null;
        addMarkers();
      });
      setupSingleDropdown('kelas-dropdown', (val) => {
        currentFilters.kelas = val || null;
        addMarkers();
      });
      setupSingleDropdown('rating-dropdown-rs', (val) => {
        currentFilters.minRating = val || null;
        addMarkers();
      });
    } else if (isSPBU) {
      setupSingleDropdown('jenis-spbu-dropdown', (val) => {
        currentFilters.jenis = val || null;
        addMarkers();
      });
      setupSingleDropdown('rating-dropdown', (val) => {
        currentFilters.minRating = val || null;
        addMarkers();
      });

      // SPBU Fasilitas toggle
      const fasSpbuToggle = document.getElementById('fasilitas-spbu-toggle');
      const fasSpbuPanel = document.getElementById('fasilitas-spbu-panel');
      const fasSpbuDropdown = document.getElementById('fasilitas-spbu-dropdown');
      const fasSpbuCount = document.getElementById('fasilitas-spbu-count');

      if (fasSpbuToggle) {
        fasSpbuToggle.addEventListener('click', (e) => {
          e.stopPropagation();
          toggleFilter('fasilitas-spbu-dropdown', fasSpbuToggle, fasSpbuPanel);
        });

        fasSpbuPanel.querySelectorAll('.fasilitas-spbu-cb').forEach(cb => {
          cb.addEventListener('change', () => {
            const checked = fasSpbuPanel.querySelectorAll('.fasilitas-spbu-cb:checked');
            currentFilters.fasilitas = Array.from(checked).map(c => c.value);
            fasSpbuCount.textContent = currentFilters.fasilitas.length > 0
              ? `(${currentFilters.fasilitas.length})`
              : '';
            addMarkers();
          });
        });
      }

      // SPBU Penawaran toggle
      const penawaranToggle = document.getElementById('penawaran-spbu-toggle');
      const penawaranPanel = document.getElementById('penawaran-spbu-panel');
      const penawaranDropdown = document.getElementById('penawaran-spbu-dropdown');
      const penawaranCount = document.getElementById('penawaran-spbu-count');

      if (penawaranToggle) {
        penawaranToggle.addEventListener('click', (e) => {
          e.stopPropagation();
          toggleFilter('penawaran-spbu-dropdown', penawaranToggle, penawaranPanel);
        });

        penawaranPanel.querySelectorAll('.penawaran-spbu-cb').forEach(cb => {
          cb.addEventListener('change', () => {
            const checked = penawaranPanel.querySelectorAll('.penawaran-spbu-cb:checked');
            currentFilters.penawaran = Array.from(checked).map(c => c.value);
            penawaranCount.textContent = currentFilters.penawaran.length > 0
              ? `(${currentFilters.penawaran.length})`
              : '';
            addMarkers();
          });
        });
      }
    } else {
      setupSingleDropdown('rating-dropdown', (val) => {
        currentFilters.minRating = val || null;
        addMarkers();
      });
    }

    setupSingleDropdown('distance-dropdown', (val) => {
      currentFilters.maxDistance = val || null;
      clearRadiusLayers();
      addMarkers();
    });

    document.getElementById('filter-reset-btn').addEventListener('click', () => {
      currentFilters = { search: '', sortBy: 'rating', maxDistance: null };
      clearRadiusLayers();
      if (isHotel) {
        currentFilters.kategori = null;
        currentFilters.harga = null;
        currentFilters.minRating = null;
        currentFilters.fasilitas = [];
      } else if (isRS) {
        currentFilters.jenis = null;
        currentFilters.kelas = null;
        currentFilters.minRating = null;
      } else if (isSPBU) {
        currentFilters.jenis = null;
        currentFilters.minRating = null;
        currentFilters.fasilitas = [];
        currentFilters.penawaran = [];
      } else {
        currentFilters.minRating = null;
      }

      // Reset text on selects
      document.querySelectorAll('.filter-custom-single').forEach(dropdown => {
        const btn = dropdown.querySelector('.filter-custom-btn');
        const labelEl = dropdown.querySelector('.filter-single-label');
        if (btn && labelEl) {
          labelEl.textContent = btn.dataset.default;
        }

        // Reset radio buttons
        const defaultRadio = dropdown.querySelector('input[type="radio"][value=""]');
        if (defaultRadio) defaultRadio.checked = true;
      });

      if (isHotel) {
        document.querySelectorAll('.fasilitas-cb').forEach(cb => cb.checked = false);
        const countEl = document.getElementById('fasilitas-count');
        if (countEl) countEl.textContent = '';
        document.getElementById('fasilitas-dropdown')?.classList.remove('open');
      } else if (isSPBU) {
        document.querySelectorAll('.fasilitas-spbu-cb').forEach(cb => cb.checked = false);
        const fasCountEl = document.getElementById('fasilitas-spbu-count');
        if (fasCountEl) fasCountEl.textContent = '';
        document.getElementById('fasilitas-spbu-dropdown')?.classList.remove('open');

        document.querySelectorAll('.penawaran-spbu-cb').forEach(cb => cb.checked = false);
        const penCountEl = document.getElementById('penawaran-spbu-count');
        if (penCountEl) penCountEl.textContent = '';
        document.getElementById('penawaran-spbu-dropdown')?.classList.remove('open');
      }

      searchInput.value = '';
      addMarkers();
    });
  }
}

function getSpbuBrandColor(jenis) {
  switch (jenis) {
    case 'Pertamina': return '#dc2626';
    case 'Shell': return '#eab308';
    case 'VIVO': return '#1630a3ff';
    case 'BP': return '#15c805ff';
    default: return '#ea580c';
  }
}
