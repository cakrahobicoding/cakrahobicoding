// Efek salju jatuh
const snowContainer = document.getElementById('snow');
const FLAKE_COUNT = 40;
for (let i = 0; i < FLAKE_COUNT; i++) {
  const flake = document.createElement('div');
  flake.className = 'flake';
  flake.textContent = '❅';
  flake.style.left = Math.random() * 100 + 'vw';
  flake.style.fontSize = (10 + Math.random() * 10) + 'px';
  flake.style.animationDuration = (8 + Math.random() * 10) + 's';
  flake.style.animationDelay = (Math.random() * 10) + 's';
  snowContainer.appendChild(flake);
}

// Overlay "click to enter" — hilang saat diklik
const enterScreen = document.getElementById('enterScreen');
if (enterScreen) {
  enterScreen.addEventListener('click', () => {
    enterScreen.classList.add('hidden');
    setTimeout(() => enterScreen.remove(), 500);
  });
}
