/**
 * PetaBuitenzorg — Detail Page
 */

import { getHotelById, getHospitalById, getMallById, getGasStationById, formatPrice, renderStars, getStarLabel, userLocation, calculateDistance, formatDistance } from '../data.js';
import L from 'leaflet';

let miniMap = null;

export function renderDetail(container, type, id) {
  const isHotel = type === 'hotel';
  const isRS = type === 'rumah-sakit';
  const isMall = type === 'mall';
  const isSPBU = type === 'spbu';

  let item = null;
  if (isHotel) item = getHotelById(id);
  else if (isRS) item = getHospitalById(id);
  else if (isMall) item = getMallById(id);
  else if (isSPBU) item = getGasStationById(id);

  if (!item) {
    container.innerHTML = `
      <div class="empty-state" style="min-height:100vh;">
        <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
        <p>Data tidak ditemukan</p>
        <a href="#/${type}" class="btn btn--outline">Kembali</a>
      </div>
    `;
    return;
  }

  const backUrl = `#/${type}`;

  container.innerHTML = `
    <button class="detail-page__back" id="btn-back" onclick="window.location.hash='${backUrl}'">
      <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
      
    </button>
    <div class="detail-page" id="detail-page">
      <!-- Hero -->
      <div class="detail-page__hero img-wrapper skeleton">
        <img
          class="detail-page__hero-img img-fade-in"
          src="${item.gambar}"
          alt="${item.nama}"
          onload="this.classList.add('loaded'); this.parentElement.classList.remove('skeleton');"
          onerror="this.src='data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 400 280%22><rect fill=%22%231e293b%22 width=%22400%22 height=%22280%22/><text x=%22200%22 y=%22145%22 text-anchor=%22middle%22 fill=%22%2364748b%22 font-size=%2240%22>${isHotel ? '🏨' : isRS ? '🏥' : isMall ? '🛍️' : '⛽'}</text></svg>'; this.classList.add('loaded'); this.parentElement.classList.remove('skeleton');"
        />
      </div>

      <!-- Content -->
      <div class="detail-page__content">
        <!-- Title Section -->
        <div class="detail-page__title-section">
          <h1 class="detail-page__name">${item.nama}</h1>
          <div class="detail-page__meta">
            ${isHotel ? `
              <div class="rating">
                <span class="rating__stars"><svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="currentColor" stroke="currentColor" stroke-width="2"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg></span>
                <span class="rating__value">${Number(item.rating).toFixed(1)}</span>
              </div>
              <span class="badge badge--star-${item.kategori}">${getStarLabel(item.kategori)}</span>`
      : `
              ${item.rating ? `
              <div class="rating">
                <span class="rating__stars"><svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="currentColor" stroke="currentColor" stroke-width="2"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg></span>
                <span class="rating__value">${Number(item.rating).toFixed(1)}</span>
              </div>` : ''}
              ${isRS ? `<span class="badge ${item.jenis === 'RSIA' ? 'badge--rsia' : item.jenis === 'RSU' ? 'badge--rsu' : item.jenis === 'RSJ' ? 'badge--rsj' : 'badge--rs'}">${item.jenis}</span><span class="badge ${item.kelas === 'A' ? 'badge--kelas-a' : item.kelas === 'B' ? 'badge--kelas-b' : item.kelas === 'C' ? 'badge--kelas-c' : item.kelas === 'D' ? 'badge--kelas-d' : 'badge--kelas'}">Kelas ${item.kelas}</span>`
        : isMall ? `<span class="badge" style="background-color:#d946ef;color:white;">Mall</span>`
          : `<span class="badge" style="background-color:${getSpbuBrandColor(item.jenis)};color:white;">${item.jenis}</span>`
      }`
    }
          </div>
          ${isHotel
      ? `<div class="detail-page__price">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 8px; vertical-align: middle; opacity: 0.9;"><rect x="2" y="5" width="20" height="14" rx="2"/><line x1="2" y1="10" x2="22" y2="10"/></svg>
            ${formatPrice(item.harga)} <span class="detail-page__price-label">/ malam</span>
         </div>`
      : ''
    }
        </div>

        <!-- Info -->
        <div class="detail-page__info">
          ${userLocation ? `
          <div class="detail-page__info-item" style="color: var(--accent-teal); font-weight: 500;">
            <svg class="detail-page__info-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2v20"/></svg>
            <span class="detail-page__info-text" style="color: var(--text-primary);">Berjarak ${formatDistance(calculateDistance(userLocation.lat, userLocation.lng, item.lat, item.lng))}</span>
          </div>
          ` : ''}
          <div class="detail-page__info-item">
            <svg class="detail-page__info-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0118 0z"/><circle cx="12" cy="10" r="3"/></svg>
            <span class="detail-page__info-text">${item.alamat}</span>
          </div>
        </div>

        <!-- Facilities (Hotel and SPBU) -->
        ${(isHotel || isSPBU) && item.fasilitas ? `
          <div class="detail-page__facilities">
            <h2 class="detail-page__facilities-title">Fasilitas</h2>
            <div class="detail-page__facilities-grid">
              ${item.fasilitas.map(f => `
                <span class="pill">${getFacilityIcon(f)} ${f}</span>
              `).join('')}
            </div>
          </div>
        ` : ''}

        <!-- Penawaran (SPBU only) -->
        ${isSPBU && item.penawaran ? `
          <div class="detail-page__facilities" style="margin-top: 24px;">
            <h2 class="detail-page__facilities-title">Penawaran</h2>
            <div class="detail-page__facilities-grid">
              ${item.penawaran.map(f => `
                <span class="pill">⛽ ${f}</span>
              `).join('')}
            </div>
          </div>
        ` : ''}

        <!-- Mini Map -->
        <div class="detail-page__minimap" id="detail-minimap"></div>

        <!-- Actions -->
        <div class="detail-page__actions">
          <a href="${item.peta}" target="_blank" rel="noopener noreferrer" class="btn btn--maps btn--full" id="btn-maps">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="3 11 22 2 13 21 11 13 3 11"/></svg>
            Buka di Google Maps
          </a>
          ${isHotel && item.pemesanan ? `
            <a href="${item.pemesanan}" target="_blank" rel="noopener noreferrer" class="btn btn--book btn--full" id="btn-book">
              <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
              Pesan Sekarang
            </a>
          ` : ''}
        </div>
      </div>
    </div>
  `;

  // Initialize mini-map
  initMiniMap(item, type);
}

function initMiniMap(item, type) {
  // Destroy previous instance if exists
  if (miniMap) {
    miniMap.remove();
    miniMap = null;
  }

  const mapContainer = document.getElementById('detail-minimap');
  if (!mapContainer) return;

  miniMap = L.map(mapContainer, {
    zoomControl: false,
    attributionControl: false,
    dragging: false,
    scrollWheelZoom: false,
    doubleClickZoom: false,
    touchZoom: false,
  }).setView([item.lat, item.lng], 16);

  L.tileLayer('https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}', {
    maxZoom: 20,
    attribution: '&copy; Google Maps',
  }).addTo(miniMap);

  let markerColor = '#3b82f6'; // default blue

  if (type === 'hotel') {
    switch (item.kategori) {
      case 5: markerColor = '#ef4444'; break; // merah
      case 4: markerColor = '#f97316'; break; // oranye
      case 3: markerColor = '#8b5cf6'; break; // ungu
      case 2: markerColor = '#3b82f6'; break; // biru
      case 1: markerColor = '#cbd5e1'; break; // putih keabuan
    }
  } else if (type === 'rumah-sakit') {
    markerColor = '#ef4444';
    switch (item.jenis) {
      case 'RSIA': markerColor = '#e4680f'; break; // coklat
      case 'RSU': markerColor = '#22c55e'; break; // hijau
      case 'RSJ': markerColor = '#eab308'; break; // kuning
    }
  } else if (type === 'mall') {
    markerColor = '#d946ef'; // pink-purple
  } else if (type === 'spbu') {
    markerColor = getSpbuBrandColor(item.jenis);
  }

  const markerHtml = type === 'hotel'
    ? `<svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="currentColor" stroke="none"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>${item.kategori || ''}`
    : type === 'rumah-sakit'
      ? `<span style="font-size:16px;">${item.kelas || 'H'}</span>`
      : type === 'mall' ? `<span style="font-size:16px;">M</span>` : `<span style="font-size:16px;">S</span>`;

  const markerIcon = L.divIcon({
    className: 'custom-marker',
    html: `<div style="width:40px;height:40px;background:${markerColor};border-radius:50%;border:4px solid white;box-shadow:0 3px 10px rgba(0,0,0,0.4);display:flex;align-items:center;justify-content:center;color:white;font-size:13px;font-weight:bold;gap:2px;">${markerHtml}</div>`,
    iconSize: [40, 40],
    iconAnchor: [20, 20],
  });

  L.marker([item.lat, item.lng], { icon: markerIcon }).addTo(miniMap);

  // Fix tile loading issue
  setTimeout(() => miniMap.invalidateSize(), 200);
}

function getFacilityIcon(facility) {
  const icons = {
    'Wi-Fi gratis': '📶',
    'AC': '❄️',
    'Parkir gratis': '🅿️',
    'Restoran': '🍽️',
    'Kolam renang luar': '🏊',
    'Spa': '💆',
    'Sarapan': '🍳',
    'Sarapan gratis': '🍳',
    'Sarapan berbayar': '🍳',
    'Pusat kebugaran': '🏋️',
    'Pusat bisnis': '💼',
    'Layanan kamar': '🛎️',
    'Layanan binatu': '👔',
    'Bar': '🍸',
    'Dapat diakses': '♿',
    'Bebas asap rokok': '🚭',
    'Jemputan bandara': '✈️',
    'Dapur di beberapa kamar': '🍳',
    'ATM': '🏧',
    'Toilet': '🚻',
    'Pompa angin': '💨',
    'Lapangan golf': '⛳',
  };
  return icons[facility] || '✓';
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
