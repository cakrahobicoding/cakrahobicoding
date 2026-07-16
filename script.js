// Kodebin — interaksi demo (tanpa backend, tanpa penyimpanan browser)

document.addEventListener('DOMContentLoaded', () => {

  // ---- Filter tag di index.html ----
  const filterRow = document.getElementById('filterRow');
  const cardGrid = document.getElementById('cardGrid');

  if (filterRow && cardGrid) {
    filterRow.addEventListener('click', (e) => {
      const btn = e.target.closest('.tag');
      if (!btn) return;

      filterRow.querySelectorAll('.tag').forEach(t => t.classList.remove('active'));
      btn.classList.add('active');

      const tag = btn.dataset.tag;
      cardGrid.querySelectorAll('.card').forEach(card => {
        const match = tag === 'semua' || card.dataset.tag === tag;
        card.style.display = match ? '' : 'none';
      });
    });
  }

  // ---- Simulasi form login ----
  const loginForm = document.getElementById('loginForm');
  if (loginForm) {
    loginForm.addEventListener('submit', (e) => {
      e.preventDefault();
      const btn = loginForm.querySelector('button[type="submit"]');
      const original = btn.textContent;
      btn.textContent = 'memeriksa…';
      btn.disabled = true;

      setTimeout(() => {
        window.location.href = 'admin.html';
      }, 600);
    });
  }

  // ---- Simulasi aksi tabel admin ----
  const pasteTable = document.getElementById('pasteTable');
  if (pasteTable) {
    pasteTable.addEventListener('click', (e) => {
      const btn = e.target.closest('button[data-action]');
      if (!btn) return;
      const row = btn.closest('tr');

      if (btn.dataset.action === 'hapus') {
        row.style.opacity = '0.35';
        btn.textContent = 'terhapus';
        btn.disabled = true;
      } else if (btn.dataset.action === 'lihat') {
        const judul = row.querySelector('.mono-strong').textContent;
        btn.textContent = 'dibuka ✓';
        setTimeout(() => { btn.textContent = 'lihat'; }, 1200);
      }
    });
  }

});
