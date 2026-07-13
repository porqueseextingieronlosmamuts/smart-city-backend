const API_BASE = 'http://127.0.0.1:8000'; // relative to current host; adjust if serving from different origin

const state = { sla: null, pasajeros: null, puntualidad: null };

function estadoColor(estado){
  if(!estado) return 'rojo';
  return estado === 'verde' ? 'verde' : (estado === 'amarillo' ? 'amarillo' : 'rojo');
}

function escapeHtml(value){
  return String(value ?? '')
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');
}

function formatMetricValue(info){
  if(info?.valor === null || info?.valor === undefined || info?.valor === '') return '—';
  if (info?.key === 'freshness') return `${Number(info.valor).toFixed(2)} días`;
  return `${Number(info.valor).toFixed(2)}%`;
}

function renderLoadingState(){
  const kpiContainer = document.getElementById('kpi-cards');
  kpiContainer.innerHTML = Array.from({length: 4}, () => `
    <article class="kpi-card is-loading">
      <div class="skeleton skeleton-line" style="width: 42%;"></div>
      <div class="kpi-value skeleton skeleton-line" style="width: 62%; margin-top: 0.9rem;"></div>
      <div class="kpi-meta skeleton skeleton-line" style="width: 48%;"></div>
      <div class="kpi-support"></div>
    </article>
  `).join('');

  document.querySelector('#tiempo-espera-table tbody').innerHTML = `
    <tr><td colspan="5"><div class="table-empty">Cargando tiempo de espera...</div></td></tr>
  `;

  document.querySelector('#quality-table tbody').innerHTML = `
    <tr><td colspan="3"><div class="table-empty">Cargando calidad de datos...</div></td></tr>
  `;

  document.getElementById('top-desviacion-list').innerHTML = '<li class="list-empty">Cargando top desviaciones...</li>';
}

function renderErrorState(message){
  document.getElementById('kpi-cards').innerHTML = `<div class="list-empty" style="grid-column: 1 / -1;">${escapeHtml(message)}</div>`;
  document.querySelector('#tiempo-espera-table tbody').innerHTML = `
    <tr><td colspan="5"><div class="table-empty">${escapeHtml(message)}</div></td></tr>
  `;
  document.querySelector('#quality-table tbody').innerHTML = `
    <tr><td colspan="3"><div class="table-empty">${escapeHtml(message)}</div></td></tr>
  `;
  document.getElementById('top-desviacion-list').innerHTML = `<li class="list-empty">${escapeHtml(message)}</li>`;
}

async function fetchSLA(){
  const res = await fetch(API_BASE + '/api/sla');
  if(!res.ok) throw new Error('SLA API error');
  return res.json();
}

async function fetchPasajeros(){
  const res = await fetch(API_BASE + '/api/kpis/pasajeros');
  if(!res.ok) throw new Error('Pasajeros API error');
  return res.json();
}

async function fetchPuntualidad(){
  const res = await fetch(API_BASE + '/api/kpis/puntualidad');
  if(!res.ok) throw new Error('Puntualidad API error');
  return res.json();
}

async function fetchTiempoEspera(){
  const res = await fetch(API_BASE + '/api/kpis/tiempo-espera');
  if(!res.ok) throw new Error('Tiempo espera API error');
  return res.json();
}

async function fetchSatisfaccion(){
  const res = await fetch(API_BASE + '/api/kpis/satisfaccion');
  if(!res.ok) throw new Error('Satisfaccion API error');
  return res.json();
}

async function fetchTopDesviacion(){
  const res = await fetch(API_BASE + '/api/kpis/top-desviacion');
  if(!res.ok) throw new Error('Top desviacion API error');
  return res.json();
}

function renderKPICards(sla){
  const container = document.getElementById('kpi-cards');
  container.innerHTML = '';
  const dims = [
    {key:'completitud', title:'Completitud', unidad:'%'},
    {key:'freshness', title:'Freshness', unidad:'días'},
    {key:'unicidad', title:'Unicidad', unidad:'%'},
    {key:'uptime', title:'Uptime', unidad:'%'}
  ];

  dims.forEach(d => {
    const info = sla[d.key];
    const estado = info.estado;
    const color = estadoColor(estado);
    const card = document.createElement('div');
    card.className = 'kpi-card';
    card.innerHTML = `
      <div class="text-muted small">${d.title}</div>
      <div class="kpi-value">${formatMetricValue({...info, key: d.key})} <span class="text-muted small">${d.unidad}</span></div>
      <div class="kpi-meta">Umbral: ${escapeHtml(info.umbral ?? '—')}</div>
      <div class="kpi-support">
        <span>Fuente: API /api/sla</span>
        <span class="kpi-state kpi-state--${color}">${escapeHtml(estado ?? 'sin_datos')}</span>
      </div>
    `;
    container.appendChild(card);
  });

  // update last-updated
  document.getElementById('last-updated').textContent = new Date(sla.timestamp).toLocaleString();
}

function renderGlobalSemaforo(sla){
  const statusClass = 'semaforo-large ' + estadoColor(sla.estado_general);
  ['global-semaforo-main', 'global-semaforo-side'].forEach((id) => {
    const el = document.getElementById(id);
    if (el) el.className = statusClass;
  });

  const statusText = (sla.estado_general ?? 'sin_datos').toUpperCase();
  ['estado-general-text-main', 'estado-general-text-side'].forEach((id) => {
    const el = document.getElementById(id);
    if (el) el.textContent = statusText;
  });
}

let barChart=null,lineChart=null,satChartInstance=null;

const chartDefaults = {
  borderWidth: 2,
  borderRadius: 10,
  pointRadius: 3,
  pointHoverRadius: 5,
};

function renderBarChart(pasajeros){
  const labels = pasajeros.map(r=>r.franja_horaria);
  const data = pasajeros.map(r=>Number(r.total_pasajeros));
  const ctx = document.getElementById('barChart');
  if(barChart) barChart.destroy();
  barChart = new Chart(ctx, {
    type:'bar',
    data:{labels, datasets:[{label:'Total pasajeros', data, backgroundColor:'rgba(15, 157, 143, 0.82)', borderColor:'#0f9d8f', ...chartDefaults}]},
    options:{responsive:true, maintainAspectRatio:false, plugins:{legend:{display:false}}, scales:{x:{grid:{display:false}}, y:{beginAtZero:true, grid:{color:'rgba(15, 23, 42, 0.08)'}}}}
  });
}

function renderLineChart(puntualidad){
  const labels = punctualLabels(puntualidad);
  const data = punctualData(puntualidad);
  const ctx = document.getElementById('lineChart');
  if(lineChart) lineChart.destroy();
  lineChart = new Chart(ctx, {
    type:'line',
    data:{labels, datasets:[{label:'Índice puntualidad %', data, borderColor:'#0f172a', backgroundColor:'rgba(15, 157, 143, 0.08)', fill:true, tension:0.32, ...chartDefaults}]},
    options:{responsive:true, maintainAspectRatio:false, scales:{x:{grid:{display:false}}, y:{beginAtZero:true, grid:{color:'rgba(15, 23, 42, 0.08)'}}}, plugins:{legend:{display:false}}}
  });
}

function punctualLabels(puntualidad){
  return puntualidad.map(r=>r.paradero);
}
function punctualData(puntualidad){
  return puntualidad.map(r=>Number(r.indice_puntualidad_pct));
}

function renderSatisfaccionChart(satisfaccion){
  const labels = satisfaccion.map(r=>r.paradero);
  const data = satisfaccion.map(r=>Number(r.promedio_general));
  const ctx = document.getElementById('satChart');
  if(satChartInstance) satChartInstance.destroy();
  satChartInstance = new Chart(ctx, {
    type:'bar',
    data:{labels, datasets:[{label:'Sat. promedio', data, backgroundColor:'rgba(246, 183, 60, 0.82)', borderColor:'#f6b73c', ...chartDefaults}]},
    options:{responsive:true, maintainAspectRatio:false, plugins:{legend:{display:false}}, scales:{x:{grid:{display:false}}, y:{beginAtZero:true, max:5, grid:{color:'rgba(15, 23, 42, 0.08)'}}}}
  });
}

function renderTiempoEsperaTable(tiempo){
  const tbody = document.querySelector('#tiempo-espera-table tbody');
  tbody.innerHTML = '';
  if (!tiempo.length) {
    tbody.innerHTML = '<tr><td colspan="5"><div class="table-empty">No hay registros de tiempo de espera.</div></td></tr>';
    return;
  }
  tiempo.forEach(r=>{
    const tr = document.createElement('tr');
    tr.innerHTML = `
      <td>${escapeHtml(r.paradero)}</td>
      <td>${escapeHtml(r.franja_horaria)}</td>
      <td>${Number(r.tiempo_real_promedio_min).toFixed(2)}</td>
      <td>${Number(r.tiempo_prometido_promedio_min).toFixed(2)}</td>
      <td>${Number(r.desviacion_promedio_min).toFixed(2)}</td>
    `;
    tbody.appendChild(tr);
  });
}

function renderTopDesviacion(top){
  const list = document.getElementById('top-desviacion-list');
  list.innerHTML = '';
  if (!top.length) {
    list.innerHTML = '<li class="list-empty">No hay desvíos destacados para esta consulta.</li>';
    return;
  }
  top.forEach(r=>{
    const item = document.createElement('li');
    item.innerHTML = `<strong>${escapeHtml(r.paradero)}</strong><span>${Number(r.desviacion_promedio_abs_min).toFixed(2)} min</span>`;
    list.appendChild(item);
  });
}

function renderQualityTable(sla){
  const tbody = document.querySelector('#quality-table tbody');
  tbody.innerHTML = '';
  const rows = [
    {field:'Completitud', info:sla.completitud},
    {field:'Freshness', info:sla.freshness},
    {field:'Unicidad', info:sla.unicidad},
    {field:'Uptime', info:sla.uptime},
  ];
  if (!rows.length) {
    tbody.innerHTML = '<tr><td colspan="3"><div class="table-empty">No hay información de calidad disponible.</div></td></tr>';
    return;
  }
  rows.forEach(r=>{
    const tr = document.createElement('tr');
    tr.innerHTML = `<td>${escapeHtml(r.field)}</td><td>${formatMetricValue({...r.info, key: r.field.toLowerCase()})}</td><td>${escapeHtml(r.info?.estado ?? 'sin_datos')}</td>`;
    tbody.appendChild(tr);
  });
}

async function refreshAll(){
  try{
    const sla = await fetchSLA(); state.sla = sla;
    const pasajeros = await fetchPasajeros(); state.pasajeros = pasajeros;
    const puntualidad = await fetchPuntualidad(); state.puntualidad = puntualidad;
    const tiempoEspera = await fetchTiempoEspera();
    const satisfaccion = await fetchSatisfaccion();
    const topDesviacion = await fetchTopDesviacion();

    renderKPICards(sla);
    renderGlobalSemaforo(sla);
    renderBarChart(pasajeros);
    renderLineChart(puntualidad);
    renderSatisfaccionChart(satisfaccion);
    renderTiempoEsperaTable(tiempoEspera);
    renderTopDesviacion(topDesviacion);
    renderQualityTable(sla);
  }catch(err){
    console.error(err);
    // show minimal error in UI
    document.getElementById('last-updated').textContent = 'Error al obtener datos — revisa consola';
    ['estado-general-text-main', 'estado-general-text-side'].forEach((id) => {
      const el = document.getElementById(id);
      if (el) el.textContent = 'SIN DATOS';
    });
    renderErrorState('No se pudieron cargar los datos. Revisa la API local.');
  }
}

// initial load
renderLoadingState();
refreshAll();

// refresh periodically
setInterval(refreshAll, 30000);
