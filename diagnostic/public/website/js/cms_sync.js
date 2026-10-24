/**
 * Universal CMS Sync Engine for Public Hospital Portal
 * Synchronizes Admin CMS settings safely without breaking original HTML brand structure
 */
(function () {
    'use strict';

    function applyCmsData(data) {
        if (!data || !data.settings) return;
        var s = data.settings;

        // 1. Dynamic Theme Colors Injection
        var primary = s.primary_color || '#059669';
        var secondary = s.secondary_color || '#0f172a';
        var buttonColor = s.button_color || primary;

        var styleId = 'cms-dynamic-theme-style';
        var styleEl = document.getElementById(styleId);
        if (!styleEl) {
            styleEl = document.createElement('style');
            styleEl.id = styleId;
            document.head.appendChild(styleEl);
        }

        styleEl.innerHTML = `
            :root {
                --brand-primary: ${primary} !important;
                --color-primary: ${primary} !important;
                --primary: ${primary} !important;
                --brand-secondary: ${secondary} !important;
                --color-secondary: ${secondary} !important;
                --secondary: ${secondary} !important;
                --color-accent: ${buttonColor} !important;
            }
            .btn-primary, .button-primary, .btn-appointment, .theme-btn, .hero .btn-primary, header .btn-primary, input[type="submit"], .cta-btn {
                background-color: ${buttonColor} !important;
                border-color: ${buttonColor} !important;
            }
            .btn-primary:hover, .button-primary:hover, .btn-appointment:hover {
                filter: brightness(0.9);
            }
            .top-bar, .header-top {
                background-color: ${secondary} !important;
            }
        `;

        // 2. Safe Logo & Brand Name Sync
        // Only replace SVG logo if custom uploaded image URL is provided (not default logo.png)
        if (s.logo_url && s.logo_url !== 'assets/img/logo.png' && !s.logo_url.endsWith('/logo.png')) {
            var brandMarks = document.querySelectorAll('.brand-mark');
            brandMarks.forEach(function (mark) {
                mark.innerHTML = '<img src="' + s.logo_url + '" alt="Logo" style="width:44px;height:44px;border-radius:12px;object-fit:cover;">';
            });
            var logoImgs = document.querySelectorAll('.footer-logo img, .site-logo');
            logoImgs.forEach(function (img) {
                img.src = s.logo_url;
            });
        }

        // Only update brand text if custom non-default title is set
        if (s.site_title && s.site_title !== 'Lutfunnesa Diabetes & Diagnostic Center' && s.site_title !== 'Lutfunnesa') {
            document.title = s.site_title + ' | Public Hospital Portal';
            var brandStrongs = document.querySelectorAll('.brand-text strong');
            brandStrongs.forEach(function (el) {
                el.textContent = s.site_title;
            });
        }

        if (s.tagline && s.tagline !== 'Diabetes & Diagnostic Center' && s.tagline !== 'Modern Diabetes, Diagnostic & Multi-Speciality Hospital Care') {
            var brandSmalls = document.querySelectorAll('.brand-text small');
            brandSmalls.forEach(function (el) {
                el.textContent = s.tagline;
            });
        }

        // 3. Hero Banner & Carousel Sync
        if (s.hero_title) {
            var heroH1 = document.querySelector('.hero h1, .carousel-item.active h1, .hero-headline');
            if (heroH1) heroH1.textContent = s.hero_title;
        }
        if (s.hero_subtitle) {
            var heroP = document.querySelector('.hero p, .carousel-item.active p, .hero-subtext');
            if (heroP) heroP.textContent = s.hero_subtitle;
        }
        if (s.hero_bg_image && s.hero_bg_image !== 'assets/img/logo.png') {
            var heroImg = document.querySelector('.hero img, .carousel-item.active img, .hero-bg-img');
            if (heroImg) heroImg.src = s.hero_bg_image;
        }

        var cta1 = document.querySelector('.hero a.btn-primary, .hero a[href*="appointment"], .hero-cta1');
        if (cta1) {
            if (s.hero_cta1_text) cta1.textContent = s.hero_cta1_text;
            if (s.hero_cta1_link) cta1.href = s.hero_cta1_link;
        }

        var cta2 = document.querySelector('.hero a.btn-secondary, .hero a[href*="doctor"], .hero-cta2');
        if (cta2) {
            if (s.hero_cta2_text) cta2.textContent = s.hero_cta2_text;
            if (s.hero_cta2_link) cta2.href = s.hero_cta2_link;
        }

        // 4. Contact Details & Social Links
        if (s.hotline) {
            document.querySelectorAll('a[href^="tel:"], .hotline-val, .top-bar-phone').forEach(function (el) {
                el.href = 'tel:' + s.hotline;
                el.innerText = s.hotline;
            });
        }

        if (s.email) {
            document.querySelectorAll('a[href^="mailto:"], .contact-email-val').forEach(function (el) {
                el.href = 'mailto:' + s.email;
                el.innerText = s.email;
            });
        }

        if (s.address) {
            document.querySelectorAll('.hospital-address-val, .footer-address').forEach(function (el) {
                el.innerText = s.address;
            });
        }

        if (s.fb_link) {
            document.querySelectorAll('a[aria-label="Facebook"], a[href*="facebook"]').forEach(function (el) { el.href = s.fb_link; });
        }
        if (s.linkedin_link) {
            document.querySelectorAll('a[aria-label="LinkedIn"], a[href*="linkedin"]').forEach(function (el) { el.href = s.linkedin_link; });
        }
        if (s.youtube_link) {
            document.querySelectorAll('a[aria-label="YouTube"], a[href*="youtube"]').forEach(function (el) { el.href = s.youtube_link; });
        }
        if (s.instagram_link) {
            document.querySelectorAll('a[aria-label="Instagram"], a[href*="instagram"]').forEach(function (el) { el.href = s.instagram_link; });
        }

        // 5. Dynamic Doctors Grid Sync (if container exists and custom doctors added)
        if (data.doctors && data.doctors.length > 0) {
            var docContainer = document.querySelector('#dynamic-doctors-grid, .doctors-dynamic-grid');
            if (docContainer) {
                var html = '';
                data.doctors.forEach(function (doc) {
                    html += `
                        <div class="col-lg-3 col-md-6 mb-4">
                            <div class="card doctor-card border-0 shadow-sm h-100" style="border-radius:14px;overflow:hidden;">
                                <img src="${doc.image_url}" class="card-img-top" alt="${doc.name}" style="height:240px;object-fit:cover;">
                                <div class="card-body p-3">
                                    <span class="badge bg-success mb-2" style="font-size:11px;">${doc.department || 'Specialist'}</span>
                                    <h5 class="card-title h6 mb-1 font-weight-bold" style="color:#0f172a;">${doc.name}</h5>
                                    <p class="card-text text-muted small mb-2">${doc.qualification}</p>
                                    <span class="text-primary font-weight-bold small d-block mb-3">${doc.designation || 'Consultant'} (${doc.experience || '10+ Yrs'})</span>
                                    <a href="#appointment" class="btn btn-sm btn-outline-success w-100 font-weight-bold">Book Appointment</a>
                                </div>
                            </div>
                        </div>
                    `;
                });
                docContainer.innerHTML = html;
            }
        }

        // 6. Dynamic Services Grid Sync (if container exists and custom services added)
        if (data.services && data.services.length > 0) {
            var srvContainer = document.querySelector('#dynamic-services-grid, .services-dynamic-grid');
            if (srvContainer) {
                var srvHtml = '';
                data.services.forEach(function (srv) {
                    srvHtml += `
                        <div class="col-lg-4 col-md-6 mb-4">
                            <div class="card service-card border-0 shadow-sm h-100 p-3" style="border-radius:14px;border-left:4px solid ${primary} !important;">
                                <div class="d-flex align-items-center mb-3">
                                    <div class="icon-box text-success mr-3" style="font-size:24px;">
                                        <i class="${srv.icon_class || 'fa-solid fa-stethoscope'}"></i>
                                    </div>
                                    <div>
                                        <span class="badge bg-light text-dark mb-1">${srv.category || 'Clinical'}</span>
                                        <h5 class="h6 mb-0 font-weight-bold" style="color:#0f172a;">${srv.title}</h5>
                                    </div>
                                </div>
                                <p class="card-text text-muted small">${srv.description}</p>
                            </div>
                        </div>
                    `;
                });
                srvContainer.innerHTML = srvHtml;
            }
        }
    }

    // Fetch CMS API with fallback to static JSON
    fetch('/index.php?page=api_website_cms')
        .then(function (res) { return res.json(); })
        .then(function (data) {
            applyCmsData(data);
        })
        .catch(function () {
            fetch('assets/cms_data.json')
                .then(function (res) { return res.json(); })
                .then(function (data) { applyCmsData(data); })
                .catch(function () {});
        });
})();
