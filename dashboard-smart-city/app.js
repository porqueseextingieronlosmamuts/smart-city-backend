const API_BASE = 'http://127.0.0.1:8000'; // relative to current host; adjust if serving from different origin

const state = { sla: null, pasajeros: null, puntualidad: null };

function estadoColor(estado){
  if(!estado) return 'rojo';
  return estado === 'verde' ? 'verde' : (estado === 'amarillo' ? 'amarillo' : 'rojo');
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
    {key:'freshness', title:'Freshness (días)', unidad:'días'},
    {key:'unicidad', title:'Unicidad', unidad:'%'},
    {key:'uptime', title:'Uptime', unidad:'%'}
  ];

  dims.forEach(d => {
    const info = sla[d.key];
    const estado = info.estado;
    const color = estadoColor(estado);
    const card = document.createElement('div');
    card.className = 'col-12 col-md-6 col-lg-3';
    card.innerHTML = `
      <div class="card kpi-card">
        <div class="card-body">
          <div class="d-flex justify-content-between align-items-start">
            <div>
              <div class="text-muted small">${d.title}</div>
              <div class="kpi-value">${info.valor ?? '—'} <span class="text-muted small">${d.unidad}</span></div>
            </div>
            <div class="text-end">
              <div class="semaforo ${color}" style="width:18px;height:18px;border-radius:50%"></div>
              <div class="kpi-meta">${info.umbral ?? ''}</div>
            </div>
          </div>
          <div class="meta-row mt-3 small text-muted">Fuente: API /api/sla</div>
        </div>
      </div>
    `;
    container.appendChild(card);
  });

  // update last-updated
  document.getElementById('last-updated').textContent = new Date(sla.timestamp).toLocaleString();
}

function renderGlobalSemaforo(sla){
  const el = document.getElementById('global-semaforo');
  el.className = 'semaforo-large ' + estadoColor(sla.estado_general);
  document.getElementById('estado-general-text').textContent = sla.estado_general.toUpperCase();
}

let barChart=null,lineChart=null;

function renderBarChart(pasajeros){
  const labels = pasajeros.map(r=>r.franja_horaria);
  const data = pasajeros.map(r=>Number(r.total_pasajeros));
  const ctx = document.getElementById('barChart');
  if(barChart) barChart.destroy();
  barChart = new Chart(ctx, {
    type:'bar',
    data:{labels, datasets:[{label:'Total pasajeros', data, backgroundColor:'#0d6efd'}]},
    options:{responsive:true, plugins:{legend:{display:false}}}
  });
}

function renderLineChart(puntualidad){
  const labels = punctualLabels(puntualidad);
  const data = punctualData(puntualidad);
  const ctx = document.getElementById('lineChart');
  if(lineChart) lineChart.destroy();
  lineChart = new Chart(ctx, {
    type:'line',
    data:{labels, datasets:[{label:'Índice puntualidad %', data, borderColor:'#198754', backgroundColor:'rgba(25,135,84,0.08)', tension:0.2}]},
    options:{responsive:true, scales:{y:{beginAtZero:true}}}
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
  if(window.satChart) window.satChart.destroy();
  window.satChart = new Chart(ctx, {
    type:'bar',
    data:{labels, datasets:[{label:'Sat. promedio', data, backgroundColor:'#ffc107'}]},
    options:{responsive:true, plugins:{legend:{display:false}}, scales:{y:{beginAtZero:true, max:5}}}
  });
}

function renderTiempoEsperaTable(tiempo){
  const tbody = document.querySelector('#tiempo-espera-table tbody');
  tbody.innerHTML = '';
  tiempo.forEach(r=>{
    const tr = document.createElement('tr');
    tr.innerHTML = `
      <td>${r.paradero}</td>
      <td>${r.franja_horaria}</td>
      <td>${Number(r.tiempo_real).toFixed(2)}</td>
      <td>${Number(r.tiempo_prometido).toFixed(2)}</td>
      <td>${Number(r.desviacion_promedio_min).toFixed(2)}</td>
    `;
    tbody.appendChild(tr);
  });
}

function renderTopDesviacion(top){
  const list = document.getElementById('top-desviacion-list');
  list.innerHTML = '';
  top.forEach(r=>{
    const item = document.createElement('li');
    item.className = 'list-group-item d-flex justify-content-between align-items-center';
    item.innerHTML = `<span>${r.paradero}</span><span>${Number(r.desviacion_promedio_abs_min).toFixed(2)} min</span>`;
    list.appendChild(item);
  });
}

function renderQualityTable(sla){
  const tbody = document.querySelector('#quality-table tbody');
  tbody.innerHTML = '';
  const pct = sla.completitud.valor ?? 0;
  const rows = [
    {field:'tiempo_prometido', pct},
    {field:'tiempo_real', pct},
    {field:'pasajeros', pct},
  ];
  rows.forEach(r=>{
    const tr = document.createElement('tr');
    tr.innerHTML = `<td>${r.field}</td><td>${Number(r.pct).toFixed(2)}%</td><td>${(100-Number(r.pct)).toFixed(2)}%</td>`;
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
  }
}

// initial load
refreshAll();

// refresh periodically
setInterval(refreshAll, 30000);
