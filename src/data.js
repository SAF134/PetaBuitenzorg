/**
 * PetaBuitenzorg — Data Layer
 * Handles loading and querying hotel & hospital data
 */

import hotelsData from '../data/hotels.json';
import hospitalsData from '../data/hospitals.json';
import mallsData from '../data/malls.json';
import gasStationsData from '../data/gasstations.json';
import { Geolocation } from '@capacitor/geolocation';

/**
 * Get all hotels, optionally filtered and sorted
 */
export function getHotels({ search = '', kategori = null, harga = null, minRating = null, fasilitas = [], sortBy = 'rating', maxDistance = null } = {}) {
    let results = [...hotelsData];

    if (search) {
        const q = search.toLowerCase();
        results = results.filter(h => {
            const name = h.nama.toLowerCase();
            const addr = h.alamat.toLowerCase();
            return name.includes(q) || addr.includes(q) || h.fasilitas.some(f => f.toLowerCase().includes(q));
        });
    }

    if (kategori !== null) {
        results = results.filter(h => h.kategori === Number(kategori));
    }

    if (harga !== null) {
        const val = Number(harga);
        if (val > 1000000) {
            results = results.filter(h => h.harga > 1000000);
        } else {
            results = results.filter(h => h.harga <= val);
        }
    }

    if (fasilitas && fasilitas.length > 0) {
        const searchFasilitas = fasilitas.map(f => f.toLowerCase());
        results = results.filter(h => {
            const hFasilitas = h.fasilitas.map(hf => hf.toLowerCase());
            return searchFasilitas.every(f => hFasilitas.includes(f));
        });
    }

    if (minRating !== null) {
        results = results.filter(h => h.rating >= Number(minRating));
    }

    if (maxDistance !== null && userLocation) {
        const radius = Number(maxDistance);
        results = results.filter(h => {
             const dist = calculateDistance(userLocation.lat, userLocation.lng, h.lat, h.lng);
             return dist <= radius;
        });
    }

    switch (sortBy) {
        case 'rating':
            results.sort((a, b) => b.rating - a.rating);
            break;
        case 'price-low':
            results.sort((a, b) => a.harga - b.harga);
            break;
        case 'price-high':
            results.sort((a, b) => b.harga - a.harga);
            break;
        case 'name':
            results.sort((a, b) => a.nama.localeCompare(b.nama));
            break;
        case 'distance-asc':
            if (userLocation) {
                results.sort((a, b) => {
                    const distA = calculateDistance(userLocation.lat, userLocation.lng, a.lat, a.lng);
                    const distB = calculateDistance(userLocation.lat, userLocation.lng, b.lat, b.lng);
                    return distA - distB;
                });
            }
            break;
        case 'distance-desc':
            if (userLocation) {
                results.sort((a, b) => {
                    const distA = calculateDistance(userLocation.lat, userLocation.lng, a.lat, a.lng);
                    const distB = calculateDistance(userLocation.lat, userLocation.lng, b.lat, b.lng);
                    return distB - distA;
                });
            }
            break;
    }

    return results;
}

/**
 * Get all hospitals, optionally filtered and sorted
 */
export function getHospitals({ search = '', jenis = null, kelas = null, minRating = null, sortBy = 'rating', maxDistance = null } = {}) {
    let results = [...hospitalsData];

    if (search) {
        const q = search.toLowerCase();
        results = results.filter(h =>
            h.nama.toLowerCase().includes(q) ||
            h.alamat.toLowerCase().includes(q)
        );
    }

    if (jenis) {
        results = results.filter(h => h.jenis === jenis);
    }

    if (kelas) {
        results = results.filter(h => h.kelas === kelas);
    }

    if (minRating !== null) {
        results = results.filter(h => h.rating >= Number(minRating));
    }

    if (maxDistance !== null && userLocation) {
        const radius = Number(maxDistance);
        results = results.filter(h => {
             const dist = calculateDistance(userLocation.lat, userLocation.lng, h.lat, h.lng);
             return dist <= radius;
        });
    }

    switch (sortBy) {
        case 'rating':
            results.sort((a, b) => b.rating - a.rating);
            break;
        case 'name':
            results.sort((a, b) => a.nama.localeCompare(b.nama));
            break;
        case 'distance-asc':
            if (userLocation) {
                results.sort((a, b) => {
                    const distA = calculateDistance(userLocation.lat, userLocation.lng, a.lat, a.lng);
                    const distB = calculateDistance(userLocation.lat, userLocation.lng, b.lat, b.lng);
                    return distA - distB;
                });
            }
            break;
        case 'distance-desc':
            if (userLocation) {
                results.sort((a, b) => {
                    const distA = calculateDistance(userLocation.lat, userLocation.lng, a.lat, a.lng);
                    const distB = calculateDistance(userLocation.lat, userLocation.lng, b.lat, b.lng);
                    return distB - distA;
                });
            }
            break;
    }

    return results;
}

/**
 * Get all malls, optionally filtered and sorted
 */
export function getMalls({ search = '', minRating = null, sortBy = 'rating', maxDistance = null } = {}) {
    let results = [...mallsData];

    if (search) {
        const q = search.toLowerCase();
        results = results.filter(m =>
            m.nama.toLowerCase().includes(q) ||
            m.alamat.toLowerCase().includes(q)
        );
    }

    if (minRating !== null) {
        results = results.filter(m => (m.rating || 0) >= Number(minRating));
    }

    if (maxDistance !== null && userLocation) {
        const radius = Number(maxDistance);
        results = results.filter(m => {
             const dist = calculateDistance(userLocation.lat, userLocation.lng, m.lat, m.lng);
             return dist <= radius;
        });
    }

    switch (sortBy) {
        case 'rating':
            results.sort((a, b) => (b.rating || 0) - (a.rating || 0));
            break;
        case 'name':
            results.sort((a, b) => a.nama.localeCompare(b.nama));
            break;
        case 'distance-asc':
            if (userLocation) {
                results.sort((a, b) => {
                    const distA = calculateDistance(userLocation.lat, userLocation.lng, a.lat, a.lng);
                    const distB = calculateDistance(userLocation.lat, userLocation.lng, b.lat, b.lng);
                    return distA - distB;
                });
            }
            break;
        case 'distance-desc':
            if (userLocation) {
                results.sort((a, b) => {
                    const distA = calculateDistance(userLocation.lat, userLocation.lng, a.lat, a.lng);
                    const distB = calculateDistance(userLocation.lat, userLocation.lng, b.lat, b.lng);
                    return distB - distA;
                });
            }
            break;
    }

    return results;
}

/**
 * Get all gas stations, optionally filtered and sorted
 */
export function getGasStations({ search = '', jenis = null, fasilitas = [], penawaran = [], minRating = null, sortBy = 'rating', maxDistance = null } = {}) {
    let results = [...gasStationsData];

    if (search) {
        const q = search.toLowerCase();
        results = results.filter(g =>
            g.nama.toLowerCase().includes(q) ||
            g.alamat.toLowerCase().includes(q)
        );
    }

    if (jenis) {
        results = results.filter(g => g.jenis === jenis);
    }

    if (fasilitas && fasilitas.length > 0) {
        results = results.filter(g =>
            fasilitas.every(f => (g.fasilitas || []).some(gf => gf.toLowerCase() === f.toLowerCase()))
        );
    }

    if (penawaran && penawaran.length > 0) {
        results = results.filter(g =>
            penawaran.every(p => (g.penawaran || []).some(gp => gp.toLowerCase() === p.toLowerCase()))
        );
    }

    if (minRating !== null) {
        results = results.filter(g => (g.rating || 0) >= Number(minRating));
    }

    if (maxDistance !== null && userLocation) {
        const radius = Number(maxDistance);
        results = results.filter(g => {
             const dist = calculateDistance(userLocation.lat, userLocation.lng, g.lat, g.lng);
             return dist <= radius;
        });
    }

    switch (sortBy) {
        case 'rating':
            results.sort((a, b) => (b.rating || 0) - (a.rating || 0));
            break;
        case 'name':
            results.sort((a, b) => a.nama.localeCompare(b.nama));
            break;
        case 'distance-asc':
            if (userLocation) {
                results.sort((a, b) => {
                    const distA = calculateDistance(userLocation.lat, userLocation.lng, a.lat, a.lng);
                    const distB = calculateDistance(userLocation.lat, userLocation.lng, b.lat, b.lng);
                    return distA - distB;
                });
            }
            break;
        case 'distance-desc':
            if (userLocation) {
                results.sort((a, b) => {
                    const distA = calculateDistance(userLocation.lat, userLocation.lng, a.lat, a.lng);
                    const distB = calculateDistance(userLocation.lat, userLocation.lng, b.lat, b.lng);
                    return distB - distA;
                });
            }
            break;
    }

    return results;
}

/**
 * Get a single hotel by id
 */
export function getHotelById(id) {
    return hotelsData.find(h => h.id === Number(id)) || null;
}

/**
 * Get a single hospital by id
 */
export function getHospitalById(id) {
    return hospitalsData.find(h => h.id === Number(id)) || null;
}

/**
 * Get a single mall by id
 */
export function getMallById(id) {
    return mallsData.find(m => m.id === Number(id)) || null;
}

/**
 * Get a single gas station by id
 */
export function getGasStationById(id) {
    return gasStationsData.find(g => g.id === Number(id)) || null;
}

/**
 * Get all places (both hotels and hospitals)
 */
export function getAllPlaces() {
    return {
        hotels: hotelsData.map(h => ({ ...h, type: 'hotel' })),
        hospitals: hospitalsData.map(h => ({ ...h, type: 'rumah-sakit' })),
        malls: mallsData.map(m => ({ ...m, type: 'mall' })),
        gasStations: gasStationsData.map(g => ({ ...g, type: 'spbu' })),
    };
}

/**
 * Format price as Indonesian Rupiah
 */
export function formatPrice(number) {
    return new Intl.NumberFormat('id-ID', {
        style: 'currency',
        currency: 'IDR',
        minimumFractionDigits: 0,
        maximumFractionDigits: 0,
    }).format(number);
}

/**
 * Generate star rating HTML
 */
export function renderStars(rating) {
    const fullStars = Math.floor(rating);
    const hasHalf = rating % 1 >= 0.3;
    const emptyStars = 5 - fullStars - (hasHalf ? 1 : 0);

    let html = '';
    for (let i = 0; i < fullStars; i++) {
        html += `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="currentColor" stroke="currentColor" stroke-width="2"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>`;
    }
    if (hasHalf) {
        html += `<svg class="star-half" xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="currentColor" stroke="currentColor" stroke-width="2"><defs><linearGradient id="half"><stop offset="50%" stop-color="currentColor"/><stop offset="50%" stop-color="transparent"/></linearGradient></defs><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2" fill="url(#half)"/></svg>`;
    }
    for (let i = 0; i < emptyStars; i++) {
        html += `<svg class="star-empty" xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>`;
    }

    return html;
}

/**
 * Generate star category for hotels
 */
export function getStarLabel(kategori) {
    return '★'.repeat(kategori);
}

/**
 * Global State for Filters
 * Memastikan filter tetap tersimpan saat berpindah halaman/kembali dari detail
 */
export let persistedFilters = {
    hotel: { search: '', sortBy: 'rating', kategori: null, harga: null, minRating: null, fasilitas: [] },
    'rumah-sakit': { search: '', sortBy: 'rating', jenis: null, kelas: null, minRating: null },
    mall: { search: '', sortBy: 'rating', minRating: null },
    spbu: { search: '', sortBy: 'rating', jenis: null, minRating: null, fasilitas: [], penawaran: [] }
};

/**
 * Geolocation State
 */
export let userLocation = null;

/**
 * Mendapatkan lokasi saat ini dengan paksa (biasanya untuk tombol 'Cari Lokasi')
 */
export async function fetchCurrentLocation() {
    try {
        const permissions = await Geolocation.checkPermissions();
        
        if (permissions.location === 'denied') {
            console.warn("Izin lokasi ditolak");
            return null;
        }

        if (permissions.location !== 'granted') {
            const request = await Geolocation.requestPermissions();
            if (request.location !== 'granted') {
                console.warn("Izin lokasi tidak diberikan setelah diminta");
                return null;
            }
        }

        const position = await Geolocation.getCurrentPosition({
            enableHighAccuracy: true,
            timeout: 10000,
            maximumAge: 0
        });

        userLocation = {
            lat: position.coords.latitude,
            lng: position.coords.longitude
        };

        return userLocation;
    } catch (error) {
        console.warn("Gagal mendapatkan lokasi:", error.message);
        return null;
    }
}

/**
 * Inisialisasi lokasi. Jika lokasi sudah ada di global state, gunakan itu.
 * Jika tidak ada, baru cari lokasi baru.
 */
export async function initLocation(onLocationUpdate) {
    // Jika sudah ada lokasi tersimpan, langsung kirim balik
    if (userLocation) {
        if (typeof onLocationUpdate === 'function') {
            onLocationUpdate(userLocation);
        }
        return userLocation;
    }

    const location = await fetchCurrentLocation();
    if (location && typeof onLocationUpdate === 'function') {
        onLocationUpdate(location);
    }
    return location;
}

/**
 * Calculate distance between two coordinates using Haversine formula
 * Calibrated with a road factor for urban areas like Bogor
 * @returns distance in kilometers
 */
export function calculateDistance(lat1, lon1, lat2, lon2, useRoadFactor = true) {
    const R = 6371.008; // Radius rata-rata bumi yang lebih presisi (WGS84)
    const dLat = deg2rad(lat2 - lat1);
    const dLon = deg2rad(lon2 - lon1);
    const a =
        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) *
        Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    let distance = R * c; 

    // Kalibrasi Jarak Jalan (Road Factor)
    // Di Bogor, jarak tempuh rata-rata ~1.3 - 1.4x lebih jauh dari garis lurus 
    // karena jalur searah dan kontur jalan.
    if (useRoadFactor) {
        const ROAD_FACTOR = 1.35; 
        distance = distance * ROAD_FACTOR;
    }

    return distance;
}

function deg2rad(deg) {
    return deg * (Math.PI / 180);
}

/**
 * Format distance for display
 */
export function formatDistance(km) {
    if (km < 1) {
        return Math.round(km * 1000) + ' m';
    }
    return km.toFixed(1) + ' km';
}
