/* Doctors page: data, filtering and rendering. */
(function () {
  'use strict';

  var doctors = [
  {
    "id": 1,
    "name": "Dr. A K M Kamrul Huda",
    "degree": "MBBS, FCPS",
    "department": "Diabetes & Endocrinology",
    "specialty": "Diabetes, Thyroid & Hormone Diseases Specialist",
    "image": "https://bdspecializedhospital.com/storage/app/public/media/1722152888.png"
  },
  {
    "id": 2,
    "name": "Prof. Dr. Hasib Rahman",
    "degree": "MBBS, FCPS, MS",
    "department": "Plastic & Aesthetic Surgery",
    "specialty": "Plastic & Aesthetic Surgeon",
    "image": "https://bdspecializedhospital.com/storage/app/public/media/1578904521.jpg"
  },
  {
    "id": 3,
    "name": "Prof. Dr. Abu Saleh Ahmed",
    "degree": "MBBS, FCPS, MD",
    "department": "Nephrology",
    "specialty": "Professor & Head, Department of Nephrology",
    "image": "https://bdspecializedhospital.com/storage/app/public/media/1786443279.jpg"
  },
  {
    "id": 4,
    "name": "Dr. Sabera Tarafdar",
    "degree": "MBBS, FCPS",
    "department": "Radiology & Imaging",
    "specialty": "Consultant, Radiology & Imaging",
    "image": "https://bdspecializedhospital.com/storage/app/public/media/1611986636.jpg"
  },
  {
    "id": 5,
    "name": "Dr. Syed Ariful Islam",
    "degree": "MBBS, DA, FCPS",
    "department": "Anaesthesia",
    "specialty": "Senior Consultant, Department of Anaesthesia",
    "image": "https://bdspecializedhospital.com/storage/app/public/media/1681107693.jpg"
  },
  {
    "id": 6,
    "name": "Prof. Dr. S. A. Khan",
    "degree": "MBBS, FCPS, MS",
    "department": "Urology",
    "specialty": "Senior Consultant & Coordinator, Urology",
    "image": "https://bdspecializedhospital.com/storage/app/public/media/1691573458.png"
  },
  {
    "id": 7,
    "name": "Prof. Brig Gen Mamun Mostafi (Rtd.)",
    "degree": "MBBS, FCPS",
    "department": "Nephrology",
    "specialty": "Specialist in Nephrology and Joint Disease",
    "image": "https://bdspecializedhospital.com/storage/app/public/media/1557718857.jpg"
  },
  {
    "id": 8,
    "name": "Prof. Dr. R.N. Sarker (Robin)",
    "degree": "MBBS, FCPS",
    "department": "Radiology & Imaging",
    "specialty": "Senior Consultant, CT, MRI & Interventional Radiology",
    "image": "https://bdspecializedhospital.com/storage/app/public/media/1678598425.jpg"
  }
];
  var departments = [
  "All Departments",
  "General & Laparoscopic Surgery",
  "Cardiology",
  "Plastic & Aesthetic Surgery",
  "Oncology",
  "Urology",
  "Pediatric & Neonatology",
  "Gastroenterology & Hepatology",
  "Nephrology",
  "Obstetrics & Gynecology",
  "Dermatology",
  "Diabetes & Endocrinology",
  "Cardiac Surgery",
  "ENT, Head & Neck Surgery",
  "Neurosurgery",
  "Neurology",
  "Vascular Surgery",
  "Orthopedics, Arthroscopy & Joint Replacement",
  "Thoracic Surgery",
  "Internal Medicine",
  "Respiratory Medicine",
  "Clinical Hematology",
  "ICU",
  "Radiology & Imaging",
  "Colorectal Surgery",
  "NICU",
  "Laboratory Medicine",
  "Psychiatry",
  "Dental and Maxillofacial Surgery",
  "Blood Bank",
  "Pediatric Surgery",
  "Health Check Up",
  "Rheumatology",
  "Surgical Oncology",
  "Hepatobiliary & Pancreatic Surgery",
  "Anaesthesia",
  "Physical Medicine",
  "Pediatric Cardiology"
];

  var form = document.getElementById('doctorFilterForm');
  var department = document.getElementById('doctorDepartment');
  var nameInput = document.getElementById('doctorName');
  var grid = document.getElementById('doctorGrid');
  var count = document.getElementById('doctorResultCount');
  var empty = document.getElementById('doctorEmptyState');
  var reset = document.getElementById('doctorReset');
  var emptyReset = document.getElementById('doctorEmptyReset');

  if (!form || !department || !nameInput || !grid) return;

  function escapeHtml(value) {
    return String(value).replace(/&/g, '&amp;').replace(/</g, '&lt;')
      .replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&#039;');
  }

  function imageFallback(img, name) {
    img.onerror = function () {
      var initials = name.split(/\s+/).filter(Boolean).slice(0, 2)
        .map(function (part) { return part.charAt(0).toUpperCase(); }).join('');
      var svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 520">' +
        '<rect width="600" height="520" fill="#edf4f1"/>' +
        '<circle cx="300" cy="190" r="82" fill="rgba(8,127,91,.18)"/>' +
        '<circle cx="300" cy="174" r="48" fill="#087f5b"/>' +
        '<path d="M190 365c0-67 49-112 110-112s110 45 110 112" fill="#087f5b"/>' +
        '<text x="300" y="465" text-anchor="middle" font-family="Arial,sans-serif" ' +
        'font-size="48" font-weight="700" fill="#087f5b">' + initials + '</text></svg>';
      img.src = 'data:image/svg+xml;charset=UTF-8,' + encodeURIComponent(svg);
      img.onerror = null;
    };
  }

  function renderDepartments() {
    departments.forEach(function (item) {
      var option = document.createElement('option');
      option.value = item === 'All Departments' ? '' : item;
      option.textContent = item;
      department.appendChild(option);
    });
  }

  function renderDoctors(list) {
    grid.innerHTML = '';
    if (count) count.textContent = list.length + (list.length === 1 ? ' Doctor' : ' Doctors');

    if (!list.length) {
      empty.classList.remove('d-none');
      return;
    }
    empty.classList.add('d-none');

    list.forEach(function (doctor) {
      var col = document.createElement('div');
      col.className = 'col-xl-3 col-lg-4 col-md-6';
      col.innerHTML =
        '<article class="doctor-result-card">' +
          '<div class="doctor-result-card__media">' +
            '<img src="' + escapeHtml(doctor.image) + '" alt="' + escapeHtml(doctor.name) + '" loading="lazy">' +
            '<span class="doctor-result-card__department">' + escapeHtml(doctor.department) + '</span>' +
          '</div>' +
          '<div class="doctor-result-card__body">' +
            '<h3>' + escapeHtml(doctor.name) + '</h3>' +
            '<p class="doctor-result-card__degree">' + escapeHtml(doctor.degree) + '</p>' +
            '<p class="doctor-result-card__specialty">' + escapeHtml(doctor.specialty) + '</p>' +
            '<div class="doctor-result-card__actions">' +
              '<a href="#appointment" class="btn btn--primary btn--sm"><i class="fa-regular fa-calendar-check me-1"></i> Make Appointment</a>' +
              '<a href="doctor-details.html?id=' + encodeURIComponent(doctor.id) + '" class="btn btn--outline btn--sm">More Details</a>' +
            '</div>' +
          '</div>' +
        '</article>';
      grid.appendChild(col);
      imageFallback(col.querySelector('img'), doctor.name);
    });
  }

  function filterDoctors() {
    var selected = department.value.trim().toLowerCase();
    var query = nameInput.value.trim().toLowerCase();

    var filtered = doctors.filter(function (doctor) {
      var departmentMatch = !selected || doctor.department.toLowerCase() === selected;
      var text = (doctor.name + ' ' + doctor.department + ' ' + doctor.specialty + ' ' + doctor.degree).toLowerCase();
      return departmentMatch && (!query || text.indexOf(query) !== -1);
    });

    renderDoctors(filtered);
  }

  function resetFilters() {
    department.value = '';
    nameInput.value = '';
    renderDoctors(doctors);
  }

  renderDepartments();
  renderDoctors(doctors);

  form.addEventListener('submit', function (event) {
    event.preventDefault();
    filterDoctors();
    document.getElementById('doctorResults').scrollIntoView({ behavior: 'smooth', block: 'start' });
  });

  nameInput.addEventListener('input', function () {
    if (nameInput.value.trim() === '') filterDoctors();
  });
  department.addEventListener('change', filterDoctors);
  reset.addEventListener('click', resetFilters);
  emptyReset.addEventListener('click', resetFilters);
}());
