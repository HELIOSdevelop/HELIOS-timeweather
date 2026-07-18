(function () {
    'use strict';

    var state = {
        visible: false,
        frozen: false,
        timeSpeed: 2,
        clock: { year: 2025, month: 6, day: 15, hour: 8, minute: 0 },
        currentWeather: null,
        use24h: true,
        selectedWeather: null,
        hasPending: false,
    };

    var WEATHERS = [
        'EXTRASUNNY','CLEAR','CLOUDS','SMOG','FOGGY',
        'OVERCAST','RAIN','THUNDER','CLEARING','NEUTRAL',
        'SNOW','SNOWLIGHT','BLIZZARD','XMAS','HALLOWEEN',
    ];

    var WEATHER_COLORS = {
        EXTRASUNNY: '#ffd700', CLEAR: '#4fc3f7', CLOUDS: '#90a4ae',
        SMOG: '#a1887f', FOGGY: '#b0bec5', OVERCAST: '#607d8b',
        RAIN: '#1565c0', THUNDER: '#7b1fa2', CLEARING: '#81c784',
        NEUTRAL: '#78909c', SNOW: '#ffffff', SNOWLIGHT: '#e0e0e0',
        BLIZZARD: '#cfd8dc', XMAS: '#c62828', HALLOWEEN: '#ff6f00',
    };

    var W_ICON = {
        EXTRASUNNY: '<circle cx="12" cy="12" r="4"/><path d="M12 2v2m0 16v2M2 12h2m16 0h2M4.9 4.9l1.4 1.4m11.3 11.3l1.4 1.4M4.9 19.1l1.4-1.4m11.3-11.3l1.4-1.4" stroke-linecap="round"/>',
        CLEAR: '<circle cx="12" cy="12" r="4.5"/><path d="M12 3v1m0 16v1M4 12h1m14 0h1M6.3 6.3l.7.7m10 10l.7.7M6.3 17.7l.7-.7m10-10l.7-.7" stroke-linecap="round" stroke-width="1.2"/>',
        CLOUDS: '<path d="M16.5 13H9a3.5 3.5 0 1 1 1-6.8A5 5 0 1 1 16.5 13z"/>',
        SMOG: '<path d="M4 9h16M4 13h16M4 17h16" stroke-linecap="round"/>',
        FOGGY: '<path d="M5 9h14M5 13h14M5 17h14" stroke-linecap="round" opacity=".4"/>',
        OVERCAST: '<path d="M17 14H8a4 4 0 1 1 1.2-7.9A5.5 5.5 0 1 1 17 14z"/>',
        RAIN: '<path d="M16 13H8a3.5 3.5 0 1 1 1-6.8A4.5 4.5 0 1 1 16 13z"/><path d="M9 17l-1 3m4-3l-1 3m4-3l-1 3" stroke-linecap="round" stroke-width="1.2"/>',
        THUNDER: '<path d="M16 13H8a3.5 3.5 0 1 1 1-6.8A4.5 4.5 0 1 1 16 13z"/><path d="M12 13l-3 5h3l-2 4" stroke-linejoin="round" stroke-width="1.3"/>',
        CLEARING: '<circle cx="10" cy="10" r="3.5"/><path d="M10 3v1m0 12v1M4 10H3m12 0h-1M5.6 5.6l.7.7m7 7l.7.7M5.6 14.4l.7-.7m7-7l.7-.7" stroke-linecap="round" stroke-width="1"/><path d="M16 12H8a3 3 0 1 1 .8-5.9" opacity=".4"/>',
        NEUTRAL: '<circle cx="12" cy="12" r="5" opacity=".35"/><path d="M12 3v1m0 16v1M4 12h1m14 0h1" opacity=".35" stroke-linecap="round"/>',
        SNOW: '<path d="M12 3v1m0 16v-1M4 12h1m14 0h-1M6.3 6.3l.7.7m10 10l.7-.7M6.3 17.7l.7-.7m10-10l.7.7" stroke-linecap="round" opacity=".4"/><circle cx="12" cy="3" r=".8"/><circle cx="12" cy="21" r=".8"/><circle cx="4" cy="12" r=".8"/><circle cx="20" cy="12" r=".8"/>',
        SNOWLIGHT: '<path d="M15 13H9a3 3 0 1 1 .8-5.8A3.5 3.5 0 1 1 15 13z"/><circle cx="10" cy="17" r=".7" opacity=".5"/><circle cx="14" cy="18" r=".7" opacity=".5"/>',
        BLIZZARD: '<path d="M16 13H8a3.5 3.5 0 1 1 1-6.8A4.5 4.5 0 1 1 16 13z"/><circle cx="8" cy="17" r=".7"/><circle cx="13" cy="17" r=".7"/><circle cx="18" cy="16" r=".7"/><circle cx="10" cy="20" r=".6"/><circle cx="15" cy="20" r=".6"/>',
        XMAS: '<path d="M12 3l-4 6h8zM10 9v5h4V9zM9 14h6M10 17h4" stroke-linejoin="round" stroke-linecap="round"/>',
        HALLOWEEN: '<path d="M12 4a4 4 0 0 0-4 4c0 1.5.8 2.5.8 4v3a1.5 1.5 0 0 0 1.5 1.5h3.4a1.5 1.5 0 0 0 1.5-1.5v-3c0-1.5.8-2.5.8-4a4 4 0 0 0-4-4z"/><circle cx="10" cy="9" r=".8" fill="currentColor"/><circle cx="14" cy="9" r=".8" fill="currentColor"/>',
    };

    function iconSVG(weather) {
        return '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linejoin="round" stroke-linecap="round">' + (W_ICON[weather] || '') + '</svg>';
    }

    var app = document.getElementById('app');
    var btnClose = document.getElementById('btnClose');
    var btnFreeze = document.getElementById('btnFreeze');
    var speedSlider = document.getElementById('speedSlider');
    var speedValue = document.getElementById('speedValue');
    var hourSlider = document.getElementById('hourSlider');
    var minuteSlider = document.getElementById('minuteSlider');
    var timeDisplay = document.getElementById('timeDisplay');
    var btnToggleFormat = document.getElementById('btnToggleFormat');
    var currentWeatherValue = document.getElementById('currentWeatherValue');
    var currentWeatherIcon = document.getElementById('currentWeatherIcon');
    var weatherGrid = document.getElementById('weatherGrid');
    var btnApply = document.getElementById('btnApply');
    var btnApplyClose = document.getElementById('btnApplyClose');
    var pendingDot = document.getElementById('pendingDot');
    var pendingText = document.getElementById('pendingText');

    function pad(n) { return String(n).padStart(2, '0'); }

    function fmtTime(h, m) {
        if (state.use24h) return pad(h) + ':' + pad(m);
        var ampm = h >= 12 ? 'PM' : 'AM';
        var h12 = h % 12 || 12;
        return h12 + ':' + pad(m) + ' ' + ampm;
    }

    function updateTimeDisplay(h, m) {
        timeDisplay.textContent = fmtTime(h, m);
    }

    function setPending() {
        state.hasPending = true;
        pendingDot.classList.add('active');
        pendingText.textContent = 'unsaved changes';
        pendingText.classList.add('active');
    }

    function clearPending() {
        state.hasPending = false;
        pendingDot.classList.remove('active');
        pendingText.textContent = '';
        pendingText.classList.remove('active');
    }

    function applyAll() {
        var h = parseInt(hourSlider.value);
        var m = parseInt(minuteSlider.value);
        var speed = parseFloat(speedSlider.value);
        var frozen = state.frozen;
        var weather = state.selectedWeather;

        nui('setTime', { hour: h, minute: m });
        nui('setTimeSpeed', { speed: speed });
        nui('setFreeze', { frozen: frozen });
        if (weather) nui('setWeather', { weather: weather });

        clearPending();
    }

    function resName() {
        var m = window.location.pathname.match(/\/([^/]+)\/ui\//);
        return m ? m[1] : 'helios-timeweather';
    }

    async function nui(ev, data) {
        var r = await fetch('https://' + resName() + '/' + ev, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data || {}),
        });
        return r.json();
    }

    function fmtSpeed(v) {
        return (v % 1 === 0 ? v.toFixed(0) : v.toFixed(1)) + 'x';
    }

    function buildWeatherGrid() {
        weatherGrid.innerHTML = '';
        for (var i = 0; i < WEATHERS.length; i++) {
            var w = WEATHERS[i];
            var btn = document.createElement('button');
            btn.className = 'weather-btn';
            btn.innerHTML = iconSVG(w) + '<span class="weather-btn-label">' + w + '</span>';
            btn.dataset.weather = w;
            btn.addEventListener('click', function () {
                var weather = this.dataset.weather;
                state.selectedWeather = weather;
                selectWeather(weather);
                setPending();
            });
            weatherGrid.appendChild(btn);
        }
    }

    function selectWeather(weather) {
        var btns = weatherGrid.querySelectorAll('.weather-btn');
        for (var i = 0; i < btns.length; i++) {
            var isMatch = btns[i].dataset.weather === weather;
            btns[i].classList.toggle('active', isMatch);
            if (isMatch) {
                var c = WEATHER_COLORS[weather] || '#4fc3f7';
                btns[i].style.cssText = 'background:' + c + ';color:#0d1117;border-color:' + c + ';font-weight:700;transform:none';
            } else {
                btns[i].style.cssText = '';
            }
        }
    }

    function updateCurrentDisplay(weather) {
        if (!weather) return;
        var col = WEATHER_COLORS[weather] || '#4fc3f7';
        currentWeatherValue.textContent = weather;
        currentWeatherValue.style.color = col;
        currentWeatherIcon.innerHTML = iconSVG(weather);
        currentWeatherIcon.querySelector('svg').style.color = col;
    }

    function handleSync(payload) {
        if (!payload) return;
        if (payload.frozen !== undefined) state.frozen = payload.frozen;
        if (payload.timeSpeed !== undefined) state.timeSpeed = payload.timeSpeed;
        if (payload.clock) state.clock = payload.clock;
        if (payload.weather) {
            state.currentWeather = payload.weather;
            state.selectedWeather = payload.weather;
        }

        speedSlider.value = state.timeSpeed;
        speedValue.textContent = fmtSpeed(state.timeSpeed);
        hourSlider.value = state.clock.hour;
        minuteSlider.value = state.clock.minute;
        updateTimeDisplay(state.clock.hour, state.clock.minute);
        btnFreeze.textContent = state.frozen ? 'UNFREEZE' : 'FREEZE';
        btnFreeze.style.cssText = state.frozen
            ? 'background:#f0883e;border-color:#f0883e;color:#0d1117'
            : '';

        if (state.currentWeather) {
            updateCurrentDisplay(state.currentWeather);
            selectWeather(state.currentWeather);
        }

        clearPending();
    }

    window.addEventListener('message', function (event) {
        var data = event.data;
        if (!data || !data.type) return;
        switch (data.type) {
            case 'open':
                state.visible = true;
                app.classList.add('visible');
                clearPending();
                nui('getInitialData', {});
                break;
            case 'sync':
                handleSync(data.payload);
                break;
        }
    });

    function closeUI() {
        state.visible = false;
        app.classList.remove('visible');
        nui('close', {});
    }
    function escapeUI() {
        state.visible = false;
        app.classList.remove('visible');
        nui('escape', {});
    }

    btnClose.addEventListener('click', closeUI);
    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape' && state.visible) {
            e.preventDefault();
            escapeUI();
        }
    });

    btnFreeze.addEventListener('click', function () {
        state.frozen = !state.frozen;
        this.textContent = state.frozen ? 'UNFREEZE' : 'FREEZE';
        this.style.cssText = state.frozen
            ? 'background:#f0883e;border-color:#f0883e;color:#0d1117'
            : '';
        setPending();
    });

    speedSlider.addEventListener('input', function () {
        speedValue.textContent = fmtSpeed(parseFloat(this.value));
    });
    speedSlider.addEventListener('change', function () {
        setPending();
    });

    hourSlider.addEventListener('input', function () {
        updateTimeDisplay(parseInt(this.value), parseInt(minuteSlider.value));
        setPending();
    });
    minuteSlider.addEventListener('input', function () {
        updateTimeDisplay(parseInt(hourSlider.value), parseInt(this.value));
        setPending();
    });

    btnToggleFormat.addEventListener('click', function () {
        state.use24h = !state.use24h;
        this.textContent = state.use24h ? '24H' : 'AM/PM';
        updateTimeDisplay(parseInt(hourSlider.value), parseInt(minuteSlider.value));
    });

    btnApply.addEventListener('click', applyAll);
    btnApplyClose.addEventListener('click', function () {
        applyAll();
        closeUI();
    });

    buildWeatherGrid();
})();
