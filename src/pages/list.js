/**
 * PetaBuitenzorg — List Page (Hotels & Hospitals)
 */

import { getHotels, getHospitals, getMalls, getGasStations, getAllPlaces, formatPrice, renderStars, getStarLabel, userLocation, calculateDistance, formatDistance, persistedFilters } from '../data.js';
import hotelsData from '../../data/hotels.json';
import gasStationsData from '../../data/gasstations.json';

let currentFilters = {};


export function renderList(container, type = 'hotel') {

  const isHotel = type === 'hotel';
  const isRS = type === 'rumah-sakit';
  const isMall = type === 'mall';
  const isSPBU = type === 'spbu';

  let typeLabel = "hotel";
  if (isRS) typeLabel = "rumah sakit";
  if (isMall) typeLabel = "mall";
  if (isSPBU) typeLabel = "SPBU";

  // Build unique fasilitas list from hotel data
  const allFasilitas = isHotel
    ? [...new Set(hotelsData.flatMap(h => h.fasilitas))].sort()
    : [];

  const spbuFasilitas = isSPBU
    ? [...new Set(gasStationsData.flatMap(g => g.fasilitas || []))].sort()
    : [];

  const spbuPenawaran = isSPBU
    ? [...new Set(gasStationsData.flatMap(g => g.penawaran || []))].sort()
    : [];

  // Initialize from Persisted Global State
  currentFilters = persistedFilters[type];

  container.innerHTML = `
    <div class="list-page" id="list-page">
      <div class="list-page__header">

        <div class="list-page__search">
          <div class="search-input">
            <svg class="search-input__icon" xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
            <input type="text" id="search-input" placeholder="Cari ${typeLabel}..." autocomplete="off" value="${currentFilters.search || ''}" />
            <button id="search-clear" class="search-input__clear" style="display: ${currentFilters.search ? 'flex' : 'none'}" title="Bersihkan pencarian">
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
            </button>
            <div class="search-suggestions" id="search-suggestions"></div>
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
                    <input type="checkbox" value="${f}" class="fasilitas-cb" ${currentFilters.fasilitas.includes(f) ? 'checked' : ''} />
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
                <label class="filter-multi-option"><input type="radio" name="filter-harga" value="" ${!currentFilters.harga ? 'checked' : ''} /> <span> Harga</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-harga" value="200000" ${currentFilters.harga == '200000' ? 'checked' : ''} /> <span>≤ Rp 200.000</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-harga" value="400000" ${currentFilters.harga == '400000' ? 'checked' : ''} /> <span>≤ Rp 400.000</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-harga" value="600000" ${currentFilters.harga == '600000' ? 'checked' : ''} /> <span>≤ Rp 600.000</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-harga" value="800000" ${currentFilters.harga == '800000' ? 'checked' : ''} /> <span>≤ Rp 800.000</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-harga" value="1000000" ${currentFilters.harga == '1000000' ? 'checked' : ''} /> <span>≤ Rp 1.000.000</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-harga" value="1000001" ${currentFilters.harga == '1000001' ? 'checked' : ''} /> <span>> Rp 1.000.000</span></label>
              </div>
            </div>
            <div class="filter-dropdown filter-custom-single" id="kategori-dropdown">
              <button type="button" class="filter-select filter-custom-btn" data-default="Kategori">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M6 9H4.5a2.5 2.5 0 0 1 0-5H6"/><path d="M18 9h1.5a2.5 2.5 0 0 0 0-5H18"/><path d="M4 22h16"/><path d="M10 14.66V17c0 .55-.47.98-.97 1.21C7.85 18.75 7 20.24 7 22"/><path d="M14 14.66V17c0 .55.47.98.97 1.21C16.15 18.75 17 20.24 17 22"/><path d="M18 2H6v7a6 6 0 0 0 12 0V2Z"/></svg>
                <span class="filter-single-label">Kategori</span>
                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
              </button>
              <div class="filter-multi-panel">
                <label class="filter-multi-option"><input type="radio" name="filter-kategori" value="" ${!currentFilters.kategori ? 'checked' : ''} /> <span> Kategori</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-kategori" value="1" ${currentFilters.kategori == 1 ? 'checked' : ''} /> <span>Bintang 1</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-kategori" value="2" ${currentFilters.kategori == 2 ? 'checked' : ''} /> <span>Bintang 2</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-kategori" value="3" ${currentFilters.kategori == 3 ? 'checked' : ''} /> <span>Bintang 3</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-kategori" value="4" ${currentFilters.kategori == 4 ? 'checked' : ''} /> <span>Bintang 4</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-kategori" value="5" ${currentFilters.kategori == 5 ? 'checked' : ''} /> <span>Bintang 5</span></label>
              </div>
            </div>
            <div class="filter-dropdown filter-custom-single" id="rating-dropdown">
              <button type="button" class="filter-select filter-custom-btn" data-default="Rating">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                <span class="filter-single-label">Rating</span>
                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
              </button>
              <div class="filter-multi-panel">
                <label class="filter-multi-option"><input type="radio" name="filter-rating" value="" ${!currentFilters.minRating ? 'checked' : ''} /> <span> Rating</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-rating" value="4.5" ${currentFilters.minRating == 4.5 ? 'checked' : ''} /> <span>4.5+</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-rating" value="4" ${currentFilters.minRating == 4 ? 'checked' : ''} /> <span>4.0+</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-rating" value="3.5" ${currentFilters.minRating == 3.5 ? 'checked' : ''} /> <span>3.5+</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-rating" value="3" ${currentFilters.minRating == 3 ? 'checked' : ''} /> <span>3.0+</span></label>
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
                <label class="filter-multi-option"><input type="radio" name="filter-jenis" value="" ${!currentFilters.jenis ? 'checked' : ''} /> <span> Jenis</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-jenis" value="RSIA" ${currentFilters.jenis == 'RSIA' ? 'checked' : ''} /> <span>RSIA</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-jenis" value="RSJ" ${currentFilters.jenis == 'RSJ' ? 'checked' : ''} /> <span>RSJ</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-jenis" value="RSU" ${currentFilters.jenis == 'RSU' ? 'checked' : ''} /> <span>RSU</span></label>
              </div>
            </div>
            <div class="filter-dropdown filter-custom-single" id="kelas-dropdown">
              <button type="button" class="filter-select filter-custom-btn" data-default="Kelas">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect width="18" height="11" x="3" y="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                <span class="filter-single-label">Kelas</span>
                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
              </button>
              <div class="filter-multi-panel">
                <label class="filter-multi-option"><input type="radio" name="filter-kelas" value="" ${!currentFilters.kelas ? 'checked' : ''} /> <span> Kelas</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-kelas" value="A" ${currentFilters.kelas == 'A' ? 'checked' : ''} /> <span>Kelas A</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-kelas" value="B" ${currentFilters.kelas == 'B' ? 'checked' : ''} /> <span>Kelas B</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-kelas" value="C" ${currentFilters.kelas == 'C' ? 'checked' : ''} /> <span>Kelas C</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-kelas" value="D" ${currentFilters.kelas == 'D' ? 'checked' : ''} /> <span>Kelas D</span></label>
              </div>
            </div>
            <div class="filter-dropdown filter-custom-single" id="rating-dropdown-rs">
              <button type="button" class="filter-select filter-custom-btn" data-default="Rating">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                <span class="filter-single-label">Rating</span>
                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
              </button>
              <div class="filter-multi-panel">
                <label class="filter-multi-option"><input type="radio" name="filter-rating" value="" ${!currentFilters.minRating ? 'checked' : ''} /> <span> Rating</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-rating" value="4.5" ${currentFilters.minRating == 4.5 ? 'checked' : ''} /> <span>4.5+</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-rating" value="4" ${currentFilters.minRating == 4 ? 'checked' : ''} /> <span>4.0+</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-rating" value="3.5" ${currentFilters.minRating == 3.5 ? 'checked' : ''} /> <span>3.5+</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-rating" value="3" ${currentFilters.minRating == 3 ? 'checked' : ''} /> <span>3.0+</span></label>
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
                <label class="filter-multi-option"><input type="radio" name="filter-jenis-spbu" value="" ${!currentFilters.jenis ? 'checked' : ''} /> <span> Jenis</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-jenis-spbu" value="Pertamina" ${currentFilters.jenis == 'Pertamina' ? 'checked' : ''} /> <span>Pertamina</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-jenis-spbu" value="Shell" ${currentFilters.jenis == 'Shell' ? 'checked' : ''} /> <span>Shell</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-jenis-spbu" value="VIVO" ${currentFilters.jenis == 'VIVO' ? 'checked' : ''} /> <span>VIVO</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-jenis-spbu" value="BP" ${currentFilters.jenis == 'BP' ? 'checked' : ''} /> <span>BP</span></label>
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
                    <input type="checkbox" value="${f}" class="fasilitas-spbu-cb" ${currentFilters.fasilitas.includes(f) ? 'checked' : ''} />
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
                    <input type="checkbox" value="${p}" class="penawaran-spbu-cb" ${currentFilters.penawaran.includes(p) ? 'checked' : ''} />
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
                <label class="filter-multi-option"><input type="radio" name="filter-rating" value="" ${!currentFilters.minRating ? 'checked' : ''} /> <span> Rating</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-rating" value="4.5" ${currentFilters.minRating == 4.5 ? 'checked' : ''} /> <span>4.5+</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-rating" value="4" ${currentFilters.minRating == 4 ? 'checked' : ''} /> <span>4.0+</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-rating" value="3.5" ${currentFilters.minRating == 3.5 ? 'checked' : ''} /> <span>3.5+</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-rating" value="3" ${currentFilters.minRating == 3 ? 'checked' : ''} /> <span>3.0+</span></label>
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
                <label class="filter-multi-option"><input type="radio" name="filter-rating" value="" ${!currentFilters.minRating ? 'checked' : ''} /> <span> Rating</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-rating" value="4.5" ${currentFilters.minRating == 4.5 ? 'checked' : ''} /> <span>4.5+</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-rating" value="4" ${currentFilters.minRating == 4 ? 'checked' : ''} /> <span>4.0+</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-rating" value="3.5" ${currentFilters.minRating == 3.5 ? 'checked' : ''} /> <span>3.5+</span></label>
                <label class="filter-multi-option"><input type="radio" name="filter-rating" value="3" ${currentFilters.minRating == 3 ? 'checked' : ''} /> <span>3.0+</span></label>
              </div>
            </div>
          `}
          <div class="filter-dropdown filter-custom-single" id="distance-dropdown">
            <button type="button" class="filter-select filter-custom-btn" data-default="Jarak">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="3 11 22 2 13 21 11 13 3 11"/></svg>
              <span class="filter-single-label">Jarak</span>
              <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
            </button>
            <div class="filter-multi-panel">
              <label class="filter-multi-option"><input type="radio" name="filter-distance" value="" ${!currentFilters.sortBy || currentFilters.sortBy == 'rating' ? 'checked' : ''} /> <span>Jarak</span></label>
              <label class="filter-multi-option"><input type="radio" name="filter-distance" value="distance-asc" ${currentFilters.sortBy == 'distance-asc' ? 'checked' : ''} /> <span>Terdekat</span></label>
              <label class="filter-multi-option"><input type="radio" name="filter-distance" value="distance-desc" ${currentFilters.sortBy == 'distance-desc' ? 'checked' : ''} /> <span>Terjauh</span></label>
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

      <div class="list-page__cards" id="cards-container">
        <!-- Cards rendered dynamically -->
      </div>
    </div>
  `;

  // Render initial cards
  renderCards(type);

  setupListEvents(type);
}



function renderCards(type) {
  const isHotel = type === 'hotel';
  const isRS = type === 'rumah-sakit';
  const isMall = type === 'mall';
  const isSPBU = type === 'spbu';

  let data = [];
  let totalData = [];

  if (isHotel) { data = getHotels(currentFilters); totalData = getHotels(); }
  else if (isRS) { data = getHospitals(currentFilters); totalData = getHospitals(); }
  else if (isMall) { data = getMalls(currentFilters); totalData = getMalls(); }
  else if (isSPBU) { data = getGasStations(currentFilters); totalData = getGasStations(); }

  updateFilterIndicators(type);

  const cardsContainer = document.getElementById('cards-container');
  const countEl = document.getElementById('list-count');
  const countBadge = document.getElementById('list-count-badge');

  if (countEl) {
    countEl.textContent = `${data.length} dari ${totalData.length} Lokasi`;
    if (countBadge) countBadge.classList.add('visible');
  }

  // Show skeleton if it's a "fresh" load or filter change
  cardsContainer.innerHTML = Array(3).fill(0).map(() => `
    <div class="skeleton-card">
      <div class="skeleton-card__img skeleton"></div>
      <div class="skeleton-card__info">
        <div class="skeleton-card__title skeleton"></div>
        <div class="skeleton-card__meta skeleton"></div>
        <div class="skeleton-card__address skeleton"></div>
      </div>
    </div>
  `).join('');

  // Use a small timeout to let the skeleton be visible briefly for "speed" feel
  setTimeout(() => {
    if (data.length === 0) {
      cardsContainer.innerHTML = `
        <div class="empty-state">
          <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/><line x1="8" y1="8" x2="14" y2="14"/><line x1="14" y1="8" x2="8" y2="14"/></svg>
          <p>Tidak ditemukan hasil yang cocok</p>
        </div>
      `;
      return;
    }

    cardsContainer.innerHTML = data.map((item, index) => {
    const detailUrl = `#/${type}/${item.id}`;

    let badgeHtml = '';
    if (isHotel) {
      badgeHtml = `<span class="badge badge--star-${item.kategori}">${getStarLabel(item.kategori)}</span>`;
    } else if (isRS) {
      let rsBadgeClass = 'badge--rs';
      let kelasBadgeClass = 'badge--kelas';
      if (item.jenis === 'RSIA') rsBadgeClass = 'badge--rsia';
      else if (item.jenis === 'RSU') rsBadgeClass = 'badge--rsu';
      else if (item.jenis === 'RSJ') rsBadgeClass = 'badge--rsj';

      if (item.kelas === 'A') kelasBadgeClass = 'badge--kelas-a';
      else if (item.kelas === 'B') kelasBadgeClass = 'badge--kelas-b';
      else if (item.kelas === 'C') kelasBadgeClass = 'badge--kelas-c';
      else if (item.kelas === 'D') kelasBadgeClass = 'badge--kelas-d';

      badgeHtml = `<span class="badge ${rsBadgeClass}">${item.jenis}</span><span class="badge ${kelasBadgeClass}">Kelas ${item.kelas}</span>`;
    } else if (isMall) {
      badgeHtml = `<span class="badge" style="background-color:#d946ef;color:white;">Mall</span>`;
    } else if (isSPBU) {
      let spbuColor = getSpbuBrandColor(item.jenis);
      badgeHtml = `<span class="badge" style="background-color:${spbuColor};color:white;">${item.jenis}</span>`;
    }

    let emoji = isHotel ? '🏨' : isRS ? '🏥' : isMall ? '🛍️' : '⛽';

    let ratingHtml = '';
    if (item.rating) {
      ratingHtml = `
        <div class="rating">
          <span class="rating__stars"><svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="currentColor" stroke="currentColor" stroke-width="2"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg></span>
          <span class="rating__value">${item.rating}</span>
        </div>
      `;
    }

    let distanceHtml = '';
    if (userLocation) {
      const distKm = calculateDistance(userLocation.lat, userLocation.lng, item.lat, item.lng);
      distanceHtml = `
        <div class="place-card__distance" style="font-size: 13px; color: var(--accent-teal); display: flex; align-items: center; gap: 4px; font-weight: 500; margin-bottom: 4px;">
          <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2v20"/></svg>
          <span style="color: var(--text-primary)">Berjarak ${formatDistance(distKm)}</span>
        </div>
      `;
    }

    return `
      <a href="${detailUrl}" class="place-card gpu-accelerated" id="card-${type}-${item.id}" style="animation-delay: ${index * 0.05}s">
        <div class="img-wrapper skeleton" style="width: 100px; height: 100px; border-radius: var(--radius-md); flex-shrink: 0;">
          <img
            class="place-card__image img-fade-in"
            src="${item.gambar}"
            alt="${item.nama}"
            loading="lazy"
            decoding="async"
            onload="this.classList.add('loaded'); this.parentElement.classList.remove('skeleton');"
            onerror="this.src='data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><rect fill=%22%231e293b%22 width=%22100%22 height=%22100%22/><text x=%2250%22 y=%2255%22 text-anchor=%22middle%22 fill=%22%2364748b%22 font-size=%2214%22>${emoji}</text></svg>'; this.classList.add('loaded'); this.parentElement.classList.remove('skeleton');"
          />
        </div>
        <div class="place-card__info">
          <div class="place-card__name">${item.nama}</div>
          <div class="place-card__meta">
            ${ratingHtml + badgeHtml}
          </div>
          ${distanceHtml}
          ${isHotel
        ? `<div class="price">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="flex-shrink:0;"><rect x="2" y="5" width="20" height="14" rx="2"/><line x1="2" y1="10" x2="22" y2="10"/></svg>
            ${formatPrice(item.harga)} <span class="price__label">/ malam</span>
          </div>`
        : ''
      }
          <div class="place-card__address">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="flex-shrink:0; color: var(--accent-teal);"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
            ${item.alamat}
          </div>
        </div>
      </a>
    `;
    }).join('');
  }, 150); // Small delay to show skeleton
}

function updateFilterIndicators(type) {
  const isHotel = type === 'hotel';
  const isRS = type === 'rumah-sakit';
  const isSPBU = type === 'spbu';

  // Helper to toggle active-filter class
  const toggleDot = (id, isActive) => {
    const el = document.getElementById(id);
    if (!el) return;
    const btn = el.querySelector('.filter-custom-btn, .filter-multi-btn, .filter-select');
    if (btn) {
      if (isActive) btn.classList.add('active-filter');
      else btn.classList.remove('active-filter');
    }
  };

  if (isHotel) {
    toggleDot('kategori-dropdown', currentFilters.kategori !== null);
    toggleDot('harga-dropdown', currentFilters.harga !== null);
    toggleDot('rating-dropdown', currentFilters.minRating !== null);
    toggleDot('fasilitas-dropdown', currentFilters.fasilitas.length > 0);
  } else if (isRS) {
    toggleDot('jenis-dropdown', currentFilters.jenis !== null);
    toggleDot('kelas-dropdown', currentFilters.kelas !== null);
    toggleDot('rating-dropdown-rs', currentFilters.minRating !== null);
  } else if (isSPBU) {
    toggleDot('jenis-spbu-dropdown', currentFilters.jenis !== null);
    toggleDot('rating-dropdown', currentFilters.minRating !== null);
    toggleDot('fasilitas-spbu-dropdown', currentFilters.fasilitas.length > 0);
    toggleDot('penawaran-spbu-dropdown', currentFilters.penawaran.length > 0);
  }

  // Distance filter (shared)
  toggleDot('distance-dropdown', currentFilters.sortBy !== 'rating');
}

function setupListEvents(type) {
  const isHotel = type === 'hotel';
  const isRS = type === 'rumah-sakit';
  const isMall = type === 'mall';
  const isSPBU = type === 'spbu';
  // Search
  const searchInput = document.getElementById('search-input');
  const searchClear = document.getElementById('search-clear');
  const suggestionsBox = document.getElementById('search-suggestions');
  let debounceTimer;

  const allData = getAllPlaces();
  const flatData = [
    ...allData.hotels.map(h => ({ ...h, typeLabel: 'Hotel', icon: 'bed-double' })),
    ...allData.hospitals.map(h => ({ ...h, typeLabel: 'RS', icon: 'heart-pulse' })),
    ...allData.malls.map(m => ({ ...m, typeLabel: 'Mall', icon: 'shopping-bag' })),
    ...allData.gasStations.map(g => ({ ...g, typeLabel: 'SPBU', icon: 'fuel' }))
  ];

  const hideSuggestions = () => {
    suggestionsBox.classList.remove('active');
    suggestionsBox.innerHTML = '';
  };

  searchInput.addEventListener('input', (e) => {
    const value = e.target.value.trim();
    
    // Toggle clear button
    if (searchClear) {
      searchClear.style.display = value ? 'flex' : 'none';
    }

    if (value.length >= 3) {
      const matches = flatData.filter(item => 
        item.nama.toLowerCase().includes(value.toLowerCase())
      ).slice(0, 5); // Limit to top 5

      if (matches.length > 0) {
        suggestionsBox.innerHTML = matches.map(item => `
          <div class="search-suggestion-item" data-name="${item.nama}">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
            <div class="search-suggestion-item__text">${item.nama}</div>
            <div class="search-suggestion-item__type">${item.typeLabel}</div>
          </div>
        `).join('');
        suggestionsBox.classList.add('active');
      } else {
        hideSuggestions();
      }
    } else {
      hideSuggestions();
    }

    clearTimeout(debounceTimer);
    debounceTimer = setTimeout(() => {
      currentFilters.search = value;
      renderCards(type);
    }, 250);
  });

  suggestionsBox.addEventListener('click', (e) => {
    const item = e.target.closest('.search-suggestion-item');
    if (item) {
      const name = item.dataset.name;
      searchInput.value = name;
      currentFilters.search = name;
      hideSuggestions();
      renderCards(type);
      if (searchClear) searchClear.style.display = 'flex';
    }
  });

  if (searchClear) {
    searchClear.addEventListener('click', () => {
      searchInput.value = '';
      currentFilters.search = '';
      searchClear.style.display = 'none';
      hideSuggestions();
      searchInput.focus();
      renderCards(type);
    });
  }

  // Close suggestions on outside click
  document.addEventListener('click', (e) => {
    if (!e.target.closest('.search-input')) {
      hideSuggestions();
    }
  });

  let activeFilterId = null;

  const closeAll = () => {
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
      closeAll();
      dropdown.classList.add('open');
      activeFilterId = dropdownId;
      positionPanel(triggerBtn, panel);
    }
  };

  // Helper: position a fixed panel below its trigger button
  const positionPanel = (btn, panel) => {
    const rect = btn.getBoundingClientRect();
    const windowWidth = window.innerWidth;
    
    // Karena panel sekarang absolute inside relative parent,
    // kita hanya perlu mengatur alignment horizontal jika di tepi layar.
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

    // Sync label on mount
    const initialSelected = panel.querySelector('input[type="radio"]:checked');
    if (initialSelected && initialSelected.value) {
      labelEl.textContent = initialSelected.nextElementSibling.textContent;
    }
  };

  // Close all custom dropdowns on outside click
  document.addEventListener('click', (e) => {
    if (!e.target.closest('.filter-custom-single') && !e.target.closest('.filter-dropdown--multi')) {
      closeAll();
    }
  });

  // Dropdown filters
  if (isHotel) {
    setupSingleDropdown('kategori-dropdown', (val) => {
      currentFilters.kategori = val ? Number(val) : null;
      renderCards(type);
    });
    setupSingleDropdown('harga-dropdown', (val) => {
      currentFilters.harga = val || null;
      renderCards(type);
    });
    setupSingleDropdown('rating-dropdown', (val) => {
      currentFilters.minRating = val || null;
      renderCards(type);
    });

    // Fasilitas multi-select toggle
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
        renderCards(type);
      });
    });
  } else if (isRS) {
    setupSingleDropdown('jenis-dropdown', (val) => {
      currentFilters.jenis = val || null;
      renderCards(type);
    });
    setupSingleDropdown('kelas-dropdown', (val) => {
      currentFilters.kelas = val || null;
      renderCards(type);
    });
    setupSingleDropdown('rating-dropdown-rs', (val) => {
      currentFilters.minRating = val || null;
      renderCards(type);
    });
  } else if (isSPBU) {
    setupSingleDropdown('jenis-spbu-dropdown', (val) => {
      currentFilters.jenis = val || null;
      renderCards(type);
    });
    setupSingleDropdown('rating-dropdown', (val) => {
      currentFilters.minRating = val || null;
      renderCards(type);
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
          renderCards(type);
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
          renderCards(type);
        });
      });
    }
  } else {
    setupSingleDropdown('rating-dropdown', (val) => {
      currentFilters.minRating = val || null;
      renderCards(type);
    });
  }

  // Distance filter (shared)
  setupSingleDropdown('distance-dropdown', (val) => {
    currentFilters.sortBy = val || 'rating';
    renderCards(type);
  });

  // Sync multi-select counts on mount
  if (isHotel) {
    const fc = document.getElementById('fasilitas-count');
    if (fc && currentFilters.fasilitas && currentFilters.fasilitas.length > 0) fc.textContent = `(${currentFilters.fasilitas.length})`;
  } else if (isSPBU) {
    const fsc = document.getElementById('fasilitas-spbu-count');
    if (fsc && currentFilters.fasilitas && currentFilters.fasilitas.length > 0) fsc.textContent = `(${currentFilters.fasilitas.length})`;
    const psc = document.getElementById('penawaran-spbu-count');
    if (psc && currentFilters.penawaran && currentFilters.penawaran.length > 0) psc.textContent = `(${currentFilters.penawaran.length})`;
  }

  // Reset button
  document.getElementById('filter-reset-btn').addEventListener('click', () => {
    // Reset the values inside the persisted object to keep the reference
    persistedFilters[type].search = '';
    persistedFilters[type].sortBy = 'rating';
    
    if (isHotel) {
      persistedFilters[type].kategori = null;
      persistedFilters[type].harga = null;
      persistedFilters[type].minRating = null;
      persistedFilters[type].fasilitas = [];
    } else if (isRS) {
      persistedFilters[type].jenis = null;
      persistedFilters[type].kelas = null;
      persistedFilters[type].minRating = null;
    } else if (isSPBU) {
      persistedFilters[type].jenis = null;
      persistedFilters[type].minRating = null;
      persistedFilters[type].fasilitas = [];
      persistedFilters[type].penawaran = [];
    } else {
      persistedFilters[type].minRating = null;
    }

    currentFilters = persistedFilters[type];

    // Reset custom dropdowns
    document.querySelectorAll('.filter-custom-single').forEach(dropdown => {
      const btn = dropdown.querySelector('.filter-custom-btn');
      const labelEl = dropdown.querySelector('.filter-single-label');
      if (btn && labelEl) {
        labelEl.textContent = btn.dataset.default;
      }
      const defaultRadio = dropdown.querySelector('input[type="radio"][value=""]');
      if (defaultRadio) {
        defaultRadio.checked = true;
      }
    });

    // Reset fasilitas/penawaran checkboxes
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
    renderCards(type);
  });
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
