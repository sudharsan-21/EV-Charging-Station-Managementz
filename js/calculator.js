/**
 * EV Charging Station Management System
 * Smart Charging Calculator Controller (js/calculator.js)
 * Enhanced with Luxury Brands: Porsche, Mercedes-Benz, BMW, Audi, Tesla, Volvo, Jaguar
 */

document.addEventListener('DOMContentLoaded', () => {
  const presetSelect = document.getElementById('pageCalcPreset');
  const batteryCapInput = document.getElementById('pageCalcCap');
  const powerSelect = document.getElementById('pageCalcPower');
  const currentSlider = document.getElementById('pageCurrentSlider');
  const targetSlider = document.getElementById('pageTargetSlider');
  const priceInput = document.getElementById('pageCalcPrice');

  const currentBadge = document.getElementById('pageCurrentBadge');
  const targetBadge = document.getElementById('pageTargetBadge');
  const deltaText = document.getElementById('pageDeltaText');
  const batteryFill = document.getElementById('pageBatteryFill');
  const soCRange = document.getElementById('pageSoCRange');
  const resEnergy = document.getElementById('pageResEnergy');
  const resTime = document.getElementById('pageResTime');
  const resCost = document.getElementById('pageResCost');

  const presets = {
    // Luxury Brands
    taycan: { cap: 93.4, power: 150 },
    eqs: { cap: 107.8, power: 150 },
    ix: { cap: 111.5, power: 150 },
    etron: { cap: 93.4, power: 150 },
    tesla3: { cap: 75.0, power: 150 },
    xc40: { cap: 78.0, power: 120 },
    i4: { cap: 83.9, power: 150 },
    ipace: { cap: 90.0, power: 60 },
    // Mainstream Brands
    nexon: { cap: 40.5, power: 60 },
    mgzs: { cap: 50.3, power: 60 },
    ioniq5: { cap: 72.6, power: 150 },
    tiago: { cap: 24.0, power: 22 },
    byd: { cap: 60.48, power: 60 },
    ev6: { cap: 77.4, power: 150 }
  };

  // Check URL params if arrived from vehicle card click
  const urlParams = new URLSearchParams(window.location.search);
  const paramVehicle = urlParams.get('vehicle');
  if (paramVehicle) {
    const matchedKey = Object.keys(presets).find(k => paramVehicle.toLowerCase().includes(k));
    if (matchedKey && presetSelect) {
      presetSelect.value = matchedKey;
      batteryCapInput.value = presets[matchedKey].cap;
      powerSelect.value = presets[matchedKey].power;
    }
  }

  if (presetSelect) {
    presetSelect.addEventListener('change', (e) => {
      const val = e.target.value;
      if (presets[val]) {
        batteryCapInput.value = presets[val].cap;
        powerSelect.value = presets[val].power;
        recalculate();
      }
    });
  }

  function recalculate() {
    let cur = parseInt(currentSlider.value);
    let tgt = parseInt(targetSlider.value);

    // Keep target at least current + 1
    if (cur >= tgt) {
      tgt = Math.min(100, cur + 1);
      targetSlider.value = tgt;
    }

    currentBadge.textContent = cur + '%';
    targetBadge.textContent = tgt + '%';

    const cap = parseFloat(batteryCapInput.value) || 40.5;
    const pwr = parseFloat(powerSelect.value) || 60;
    const prc = parseFloat(priceInput.value) || 15;

    const metrics = evApp.calculateChargingMetrics(cap, cur, tgt, pwr, prc);

    const delta = tgt - cur;
    deltaText.textContent = `+${delta}% (+${metrics.energyRequired} kWh)`;
    soCRange.textContent = `${cur}% ➔ ${tgt}%`;

    // Dynamic battery fill styling
    batteryFill.style.width = tgt + '%';
    batteryFill.textContent = tgt + '%';

    if (tgt < 30) {
      batteryFill.style.background = 'linear-gradient(90deg, #ef4444, #f97316)';
    } else if (tgt < 70) {
      batteryFill.style.background = 'linear-gradient(90deg, #f59e0b, #eab308)';
    } else {
      batteryFill.style.background = 'linear-gradient(90deg, #06b6d4, #00d084)';
    }

    resEnergy.innerHTML = `${metrics.energyRequired} <span class="fs-6 fw-normal text-muted">kWh</span>`;
    resTime.innerHTML = `${metrics.durationFormatted}`;
    resCost.textContent = `₹${metrics.estimatedCost.toFixed(2)}`;
  }

  [batteryCapInput, powerSelect, currentSlider, targetSlider, priceInput].forEach(el => {
    if (el) el.addEventListener('input', recalculate);
  });

  recalculate();
});
