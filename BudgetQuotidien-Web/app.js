/* Budget Quotidien — PWA
   Même logique que la version SwiftUI : le budget conseillé est recalculé
   chaque jour = budget restant / jours restants. */

'use strict';

/* ------------------------------------------------------------------ */
/* Référentiels                                                        */
/* ------------------------------------------------------------------ */
const CATEGORIES = {
  Alimentation: { icon: '🍽️', color: '#2FB574', subs: ['Restaurant', 'Marché', 'Supermarché', 'Café'] },
  Transport:    { icon: '🚗', color: '#3B82F6', subs: ['Taxi', 'Essence', 'Bus', 'Moto'] },
  Factures:     { icon: '💡', color: '#F5A623', subs: ['Électricité', 'Eau', 'Internet', 'Loyer'] },
  Loisirs:      { icon: '🎮', color: '#8B5CF6', subs: ['Cinéma', 'Sortie', 'Sport', 'Streaming'] },
  Santé:        { icon: '➕', color: '#EC4899', subs: ['Pharmacie', 'Consultation', 'Analyses'] },
  Shopping:     { icon: '🛍️', color: '#14B8A6', subs: ['Vêtements', 'Électronique', 'Maison'] },
  Éducation:    { icon: '📚', color: '#6366F1', subs: ['Livres', 'Frais', 'Cours'] },
  Autres:       { icon: '•••', color: '#9BA1AC', subs: [] },
};
const INCOME_TYPES = {
  Salaire:        { icon: '💼', color: '#2FB574' },
  Prime:          { icon: '🎁', color: '#F5A623' },
  Remboursement:  { icon: '↩️', color: '#3B82F6' },
  Vente:          { icon: '🏷️', color: '#14B8A6' },
  Autre:          { icon: '➕', color: '#9BA1AC' },
};
const PAYMENTS = ['Espèces', 'Carte', 'Mobile Money', 'Virement'];
const CURRENCIES = { XOF: 'FCFA', XAF: 'FCFA', EUR: '€', USD: '$' };

/* ------------------------------------------------------------------ */
/* Formatage                                                           */
/* ------------------------------------------------------------------ */
function fractionDigits(code) { return (code === 'XOF' || code === 'XAF') ? 0 : 2; }
function symbolFor(code) { return CURRENCIES[code] || code; }

function money(amount, code = state.budget?.currency || 'XOF', showSymbol = true) {
  const n = Math.round(amount * (fractionDigits(code) ? 100 : 1)) / (fractionDigits(code) ? 100 : 1);
  const s = new Intl.NumberFormat('fr-FR', {
    minimumFractionDigits: 0, maximumFractionDigits: fractionDigits(code),
  }).format(n).replace(/ | /g, ' ');
  return showSymbol ? `${s} ${symbolFor(code)}` : s;
}
function compact(v) {
  const a = Math.abs(v);
  if (a >= 1e6) return (v / 1e6).toFixed(1).replace('.', ',') + 'M';
  if (a >= 1e3) return (v / 1e3).toFixed(0) + 'K';
  return Math.round(v).toString();
}

/* ------------------------------------------------------------------ */
/* Dates                                                               */
/* ------------------------------------------------------------------ */
function startOfDay(d) { const x = new Date(d); x.setHours(0, 0, 0, 0); return x; }
function isoDate(d) { const x = startOfDay(d); return `${x.getFullYear()}-${String(x.getMonth() + 1).padStart(2, '0')}-${String(x.getDate()).padStart(2, '0')}`; }
function parseDate(iso) { const [y, m, d] = iso.split('-').map(Number); return new Date(y, m - 1, d); }
function daysBetweenInclusive(a, b) {
  const ms = startOfDay(b) - startOfDay(a);
  return Math.max(Math.round(ms / 86400000) + 1, 1);
}
function sameDay(a, b) { return isoDate(a) === isoDate(b); }
function frDate(d, opts = { day: 'numeric', month: 'long', year: 'numeric' }) {
  return new Intl.DateTimeFormat('fr-FR', opts).format(new Date(d));
}
function frTime(d) { return new Intl.DateTimeFormat('fr-FR', { hour: '2-digit', minute: '2-digit' }).format(new Date(d)); }
function endOfCurrentMonth() { const n = new Date(); return new Date(n.getFullYear(), n.getMonth() + 1, 0); }

/* ------------------------------------------------------------------ */
/* Cœur métier — instantané du budget                                  */
/* ------------------------------------------------------------------ */
function snapshot(budget, today = new Date()) {
  const totalIncome = budget.incomes.reduce((s, i) => s + i.amount, 0);
  const totalBudget = budget.initialAmount + totalIncome;
  const totalSpent = budget.expenses.reduce((s, e) => s + e.amount, 0);
  const remaining = totalBudget - totalSpent;

  const start = parseDate(budget.startDate);
  const end = parseDate(budget.endDate);
  const totalDays = daysBetweenInclusive(start, end);
  const refToday = startOfDay(today) < start ? start : startOfDay(today);
  const daysRemaining = daysBetweenInclusive(refToday, end);
  const daysElapsed = Math.max(daysBetweenInclusive(start, today) - 1, 0);

  const initialDaily = totalBudget / totalDays;
  const recommended = Math.max(remaining, 0) / daysRemaining;   // recalcul quotidien
  const spentToday = budget.expenses.filter(e => sameDay(e.date, today)).reduce((s, e) => s + e.amount, 0);
  const remainingToday = recommended - spentToday;

  const dayConsumption = recommended > 0 ? spentToday / recommended : (spentToday > 0 ? 1 : 0);
  const monthConsumption = totalBudget > 0 ? Math.min(Math.max(totalSpent / totalBudget, 0), 1) : 0;

  let status = 'healthy';
  if (spentToday > recommended) status = 'over';
  else if (remainingToday <= recommended * 0.2) status = 'warning';

  return {
    totalIncome, totalBudget, totalSpent, remaining, initialAmount: budget.initialAmount,
    totalDays, daysElapsed, daysRemaining, initialDaily, recommended,
    spentToday, remainingToday, dayConsumption, monthConsumption, status,
  };
}

function respectedDays(budget, today = new Date()) {
  const start = parseDate(budget.startDate);
  const end = parseDate(budget.endDate);
  const ref = new Date(Math.min(startOfDay(today), startOfDay(end)));
  const reference = (budget.initialAmount + budget.incomes.reduce((s, i) => s + i.amount, 0))
    / daysBetweenInclusive(start, end);
  let respected = 0, exceeded = 0;
  for (let c = new Date(start); c <= ref; c.setDate(c.getDate() + 1)) {
    const spent = budget.expenses.filter(e => sameDay(e.date, c)).reduce((s, e) => s + e.amount, 0);
    if (spent > reference) exceeded++; else respected++;
  }
  return { respected, exceeded };
}

function remainingCurve(budget, today = new Date()) {
  const start = parseDate(budget.startDate);
  const total = budget.initialAmount + budget.incomes.reduce((s, i) => s + i.amount, 0);
  const days = daysBetweenInclusive(start, parseDate(budget.endDate));
  const byDay = {};
  budget.expenses.forEach(e => { const k = isoDate(e.date); byDay[k] = (byDay[k] || 0) + e.amount; });
  const points = [];
  let running = total;
  for (let i = 0; i < days; i++) {
    const day = new Date(start); day.setDate(day.getDate() + i);
    running -= (byDay[isoDate(day)] || 0);
    points.push({ date: new Date(day), value: running });
    if (startOfDay(day) >= startOfDay(today)) break;
  }
  return points;
}

function categoryTotals(budget) {
  const t = {};
  budget.expenses.forEach(e => { t[e.category] = (t[e.category] || 0) + e.amount; });
  return Object.entries(t).map(([category, total]) => ({ category, total })).sort((a, b) => b.total - a.total);
}

/* ------------------------------------------------------------------ */
/* État persistant                                                     */
/* ------------------------------------------------------------------ */
const STORE_KEY = 'budgetQuotidien.v1';
let state = load();

function load() {
  try {
    const raw = localStorage.getItem(STORE_KEY);
    if (raw) return JSON.parse(raw);
  } catch (e) {}
  return { onboarded: false, budget: null };
}
function save() { localStorage.setItem(STORE_KEY, JSON.stringify(state)); }
function uid() { return Date.now().toString(36) + Math.random().toString(36).slice(2, 7); }

/* ------------------------------------------------------------------ */
/* Retour haptique (si supporté)                                       */
/* ------------------------------------------------------------------ */
function haptic(ms = 8) { if (navigator.vibrate) navigator.vibrate(ms); }

/* ------------------------------------------------------------------ */
/* Rendu                                                               */
/* ------------------------------------------------------------------ */
const app = document.getElementById('app');
const tabbar = document.getElementById('tabbar');
const modalRoot = document.getElementById('modal-root');
let currentTab = 'home';

function render() {
  if (!state.onboarded) { tabbar.classList.add('hidden'); return renderOnboarding(); }
  if (!state.budget) { tabbar.classList.add('hidden'); return renderSetup(); }
  tabbar.classList.remove('hidden');
  document.querySelectorAll('.tab[data-tab]').forEach(t =>
    t.classList.toggle('active', t.dataset.tab === currentTab));
  ({ home: renderHome, history: renderHistory, budget: renderBudget, profile: renderProfile }[currentTab] || renderHome)();
}

/* ---- Onboarding ---- */
function renderOnboarding() {
  app.innerHTML = `
    <div class="stack center" style="min-height:80vh; justify-content:center; gap:24px;">
      <div style="width:170px;height:170px;border-radius:50%;background:var(--positive-soft);display:grid;place-items:center;margin:0 auto;font-size:78px;">👛</div>
      <div>
        <h1>Maîtrisez votre budget<br><span style="color:var(--positive)">au quotidien</span></h1>
        <p class="muted" style="margin-top:14px;padding:0 10px;">Suivez vos dépenses, respectez votre budget journalier et atteignez vos objectifs financiers.</p>
      </div>
      <div style="width:100%;">
        <button class="btn" id="startBtn">Commencer</button>
        <button class="btn secondary" id="startBtn2">J'ai déjà un compte</button>
      </div>
    </div>`;
  const go = () => { state.onboarded = true; save(); render(); };
  document.getElementById('startBtn').onclick = go;
  document.getElementById('startBtn2').onclick = go;
}

/* ---- Configuration du budget ---- */
function renderSetup(isFirst = true) {
  const today = isoDate(new Date());
  const end = isoDate(endOfCurrentMonth());
  app.innerHTML = `
    <div class="header"><h1>Nouveau budget</h1></div>
    <div class="field">
      <label>Budget de départ</label>
      <input class="input" id="f-amount" type="tel" inputmode="numeric" placeholder="300000" />
    </div>
    <div class="field">
      <label>Devise</label>
      <select class="input" id="f-currency">
        ${Object.keys(CURRENCIES).filter((c,i,a)=>a.indexOf(c)===i).map(c => `<option value="${c}">${symbolFor(c)} — ${c}</option>`).join('')}
      </select>
    </div>
    <div class="field"><label>Date de début</label><input class="input" id="f-start" type="date" value="${today}" /></div>
    <div class="field"><label>Date de fin</label><input class="input" id="f-end" type="date" value="${end}" /></div>
    <div class="card" id="daily-hint" style="background:var(--info-soft);box-shadow:none;"></div>
    <div style="margin-top:22px;"><button class="btn" id="createBtn">Créer mon budget</button></div>
    ${isFirst ? '' : '<button class="btn secondary" id="cancelSetup">Annuler</button>'}
  `;
  const amountEl = document.getElementById('f-amount');
  const startEl = document.getElementById('f-start');
  const endEl = document.getElementById('f-end');
  const currEl = document.getElementById('f-currency');
  currEl.value = 'XOF';

  function updateHint() {
    const amount = parseFloat(amountEl.value) || 0;
    const days = daysBetweenInclusive(parseDate(startEl.value), parseDate(endEl.value));
    const daily = amount > 0 ? amount / days : 0;
    document.getElementById('daily-hint').innerHTML =
      `<div class="row" style="gap:8px;"><span style="font-size:18px;">📅</span><strong>Vous avez ${days} jours</strong></div>
       <p class="small muted" style="margin:6px 0 0;">Budget quotidien cible : <strong>${money(daily, currEl.value)}</strong></p>`;
  }
  [amountEl, startEl, endEl, currEl].forEach(el => el.addEventListener('input', updateHint));
  updateHint();

  document.getElementById('createBtn').onclick = () => {
    const amount = parseFloat(amountEl.value) || 0;
    if (amount <= 0) { amountEl.focus(); return; }
    state.budget = {
      initialAmount: amount, startDate: startEl.value, endDate: endEl.value,
      currency: currEl.value, incomes: [], expenses: [],
    };
    save(); haptic(15); currentTab = 'home'; render();
  };
  if (!isFirst) document.getElementById('cancelSetup').onclick = () => closeSheet();
}

/* ---- Accueil ---- */
function gaugeSVG(consumption, status) {
  const r = 95, c = 2 * Math.PI * r;
  const frac = Math.min(Math.max(consumption, 0), 1);
  const color = status === 'over' ? 'var(--danger)' : status === 'warning' ? 'var(--warning)' : 'var(--positive)';
  return `<svg width="210" height="210" viewBox="0 0 210 210">
    <circle cx="105" cy="105" r="${r}" fill="none" stroke="var(--separator)" stroke-width="16"/>
    <circle cx="105" cy="105" r="${r}" fill="none" stroke="${color}" stroke-width="16" stroke-linecap="round"
      stroke-dasharray="${c}" stroke-dashoffset="${c * (1 - frac)}" style="transition:stroke-dashoffset .9s ease"/>
  </svg>`;
}

function renderHome() {
  const b = state.budget, s = snapshot(b), code = b.currency;
  const remColor = s.remainingToday < 0 ? 'var(--danger)' : 'var(--text)';
  app.innerHTML = `
    <div class="header">
      <div><h1>Aujourd'hui</h1><div class="small muted">${frDate(new Date())}</div></div>
      <button class="icon-btn" id="bellBtn">🔔</button>
    </div>

    <div class="card center">
      <div class="gauge-wrap"><div class="gauge">
        ${gaugeSVG(s.dayConsumption, s.status)}
        <div class="center">
          <div class="cap">Reste aujourd'hui</div>
          <div class="amount" style="color:${remColor}">${money(Math.max(s.remainingToday, 0), code, false)}</div>
          <div class="cap">${symbolFor(code)}</div>
        </div>
      </div></div>
      <div class="small muted">sur ${money(s.recommended, code)}</div>
    </div>

    <div class="grid2">
      ${statCard('⬇️', 'Dépensé aujourd\'hui', money(s.spentToday, code), 'var(--danger)')}
      ${statCard('🎯', 'Conseillé / jour', money(s.recommended, code), 'var(--positive)')}
    </div>

    <div class="card">
      <div class="row between"><strong>Budget restant du mois</strong>
        <strong style="color:${s.remaining < 0 ? 'var(--danger)' : 'var(--positive)'}">${money(s.remaining, code)}</strong></div>
      <div class="bar" style="margin:14px 0 10px;"><span style="width:${s.monthConsumption * 100}%;background:${s.remaining < 0 ? 'var(--danger)' : 'var(--positive)'}"></span></div>
      <div class="row between small muted"><span>${money(s.totalSpent, code)} dépensés</span><span>sur ${money(s.totalBudget, code)}</span></div>
    </div>

    <div class="grid2">
      ${statCard('📅', 'Jours restants', s.daysRemaining + ' jours', 'var(--info)')}
      ${statCard('📈', 'Budget initial / jour', money(s.initialDaily, code), 'var(--info)')}
    </div>
  `;
  document.getElementById('bellBtn').onclick = () => openNotifications();

  if (s.status === 'over') maybeOverspendAlert(s, code);
}

function statCard(icon, label, val, tint) {
  return `<div class="card stat"><div class="lbl"><span style="color:${tint}">${icon}</span> ${label}</div><div class="val">${val}</div></div>`;
}

let lastAlertKey = null;
function maybeOverspendAlert(s, code) {
  const key = isoDate(new Date());
  if (lastAlertKey === key) return;
  lastAlertKey = key;
  haptic([20, 40, 20]);
  modalRoot.innerHTML = `
    <div class="alert-backdrop" id="alertBd">
      <div class="alert">
        <div style="width:72px;height:72px;border-radius:50%;background:var(--danger-soft);display:grid;place-items:center;margin:0 auto 14px;font-size:32px;">⚠️</div>
        <h2>Budget dépassé !</h2>
        <p class="muted" style="margin:10px 0 4px;">Vous avez dépassé votre budget journalier de</p>
        <div style="font-size:32px;font-weight:800;color:var(--danger);margin-bottom:16px;">${money(s.spentToday - s.recommended, code)}</div>
        <button class="btn danger" id="alertDetails">Voir les détails</button>
        <button class="btn secondary" id="alertOk" style="color:var(--text-2)">OK</button>
      </div>
    </div>`;
  document.getElementById('alertOk').onclick = () => modalRoot.innerHTML = '';
  document.getElementById('alertDetails').onclick = () => { modalRoot.innerHTML = ''; currentTab = 'history'; render(); };
}

/* ---- Historique ---- */
let histRange = 'Jour';
function renderHistory() {
  const b = state.budget, code = b.currency, now = new Date();
  const inRange = e => {
    const d = new Date(e.date);
    if (histRange === 'Jour') return sameDay(d, now);
    if (histRange === 'Semaine') { const diff = (startOfDay(now) - startOfDay(d)) / 86400000; return diff >= 0 && diff < 7; }
    return d.getMonth() === now.getMonth() && d.getFullYear() === now.getFullYear();
  };
  const items = b.expenses.filter(inRange).sort((a, c) => new Date(c.date) - new Date(a.date));
  const groups = {};
  items.forEach(e => { const k = isoDate(e.date); (groups[k] = groups[k] || []).push(e); });

  app.innerHTML = `
    <div class="header"><h1>Dépenses</h1></div>
    <div class="segment">
      ${['Jour', 'Semaine', 'Mois'].map(r => `<button data-range="${r}" class="${r === histRange ? 'on' : ''}">${r}</button>`).join('')}
    </div>
    ${items.length === 0 ? `<div class="empty">Aucune dépense sur cette période.<br>Touchez « + » pour en ajouter.</div>` :
      Object.keys(groups).map(day => {
        const total = groups[day].reduce((s, e) => s + e.amount, 0);
        return `<div class="day-head"><span>${frDate(parseDate(day), { weekday: 'long', day: 'numeric', month: 'long' })}</span><span>Total : ${money(total, code)}</span></div>
        <div class="card" style="padding:6px 16px;">${groups[day].map(e => expenseRow(e, code)).join('')}</div>`;
      }).join('')}
  `;
  document.querySelectorAll('[data-range]').forEach(btn =>
    btn.onclick = () => { histRange = btn.dataset.range; haptic(); renderHistory(); });
  document.querySelectorAll('[data-del]').forEach(btn =>
    btn.onclick = () => { b.expenses = b.expenses.filter(x => x.id !== btn.dataset.del); save(); haptic(); renderHistory(); });
}

function expenseRow(e, code) {
  const cat = CATEGORIES[e.category] || CATEGORIES.Autres;
  const title = e.details || e.category;
  const sub = [e.category, e.subcategory].filter(Boolean).join(' • ');
  return `<div class="list-item">
    <div class="disc-sm" style="background:${cat.color}26;color:${cat.color}">${cat.icon}</div>
    <div style="flex:1;min-width:0;">
      <div style="font-weight:600;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">${escapeHTML(title)}</div>
      <div class="tiny muted">${escapeHTML(sub)}</div>
    </div>
    <div style="text-align:right;">
      <div style="font-weight:600;">-${money(e.amount, code)}</div>
      <div class="tiny muted">${frTime(e.date)}</div>
    </div>
    <button data-del="${e.id}" style="background:none;border:none;color:var(--danger);font-size:18px;padding:4px 0 4px 8px;">✕</button>
  </div>`;
}

/* ---- Budget (détails + courbe) ---- */
function renderBudget() {
  const b = state.budget, s = snapshot(b), code = b.currency;
  app.innerHTML = `
    <div class="header"><h1>Budget du mois</h1><button class="icon-btn" id="addMoneyBtn">＋</button></div>
    <div class="card">
      <h2 style="margin-bottom:8px;">Vue d'ensemble</h2>
      ${statRow('Budget initial', money(s.initialAmount, code))}
      ${statRow('Argent ajouté', '+ ' + money(s.totalIncome, code), 'var(--positive)')}
      ${statRow('Budget total', money(s.totalBudget, code))}
      ${statRow('Total dépensé', money(s.totalSpent, code), 'var(--danger)')}
      ${statRow('Budget restant', money(s.remaining, code), s.remaining < 0 ? 'var(--danger)' : 'var(--positive)')}
    </div>
    <div class="card">
      <h2 style="margin-bottom:12px;">Évolution du budget</h2>
      ${lineChart(remainingCurve(b), s.totalBudget)}
    </div>
    <div class="card">
      <h2 style="margin-bottom:12px;">Statistiques</h2>
      ${statsBlock(b, code)}
    </div>
  `;
  document.getElementById('addMoneyBtn').onclick = openAddIncome;
}

function statRow(label, val, color = 'var(--text)') {
  return `<div class="row between" style="padding:9px 0;border-top:1px solid var(--separator);">
    <span class="muted small">${label}</span><strong style="color:${color}">${val}</strong></div>`;
}

function statsBlock(b, code) {
  const totals = categoryTotals(b);
  const grand = totals.reduce((s, t) => s + t.total, 0);
  if (!totals.length) return `<div class="empty" style="padding:20px;">Aucune dépense à analyser.</div>`;
  return donutChart(totals, grand, code) + `<div style="margin-top:14px;">` + totals.map(t => {
    const cat = CATEGORIES[t.category] || CATEGORIES.Autres;
    const pct = grand ? Math.round(t.total / grand * 100) : 0;
    return `<div class="list-item">
      <div class="disc-sm" style="background:${cat.color}26;color:${cat.color}">${cat.icon}</div>
      <span style="flex:1;">${t.category}</span>
      <span>${money(t.total, code)}</span>
      <span class="muted small" style="width:44px;text-align:right;">${pct}%</span>
    </div>`;
  }).join('') + `</div>`;
}

function donutChart(totals, grand, code) {
  const cx = 105, cy = 105, r = 78, w = 30, C = 2 * Math.PI * r;
  let offset = 0;
  const arcs = totals.map(t => {
    const frac = grand ? t.total / grand : 0;
    const cat = CATEGORIES[t.category] || CATEGORIES.Autres;
    const seg = `<circle cx="${cx}" cy="${cy}" r="${r}" fill="none" stroke="${cat.color}" stroke-width="${w}"
      stroke-dasharray="${frac * C} ${C}" stroke-dashoffset="${-offset * C}" transform="rotate(-90 ${cx} ${cy})"/>`;
    offset += frac;
    return seg;
  }).join('');
  return `<div style="position:relative;max-width:220px;margin:0 auto;">
    <svg class="donut" viewBox="0 0 210 210">${arcs}</svg>
    <div style="position:absolute;inset:0;display:flex;flex-direction:column;align-items:center;justify-content:center;">
      <strong style="font-size:20px;">${money(grand, code, false)}</strong><span class="tiny muted">Total</span></div>
  </div>`;
}

function lineChart(points, total) {
  if (points.length < 2) return `<div class="empty" style="padding:30px;">Pas encore assez de données.</div>`;
  const W = 320, H = 180, pad = 8;
  const max = Math.max(total, ...points.map(p => p.value));
  const min = Math.min(0, ...points.map(p => p.value));
  const xs = i => pad + (i / (points.length - 1)) * (W - pad * 2);
  const ys = v => H - pad - ((v - min) / (max - min || 1)) * (H - pad * 2);
  const line = points.map((p, i) => `${i ? 'L' : 'M'}${xs(i).toFixed(1)},${ys(p.value).toFixed(1)}`).join(' ');
  const area = `${line} L${xs(points.length - 1).toFixed(1)},${H - pad} L${xs(0).toFixed(1)},${H - pad} Z`;
  return `<svg class="linechart" viewBox="0 0 ${W} ${H}" preserveAspectRatio="none" style="height:200px;">
    <path d="${area}" fill="var(--positive-soft)"/>
    <path d="${line}" fill="none" stroke="var(--positive)" stroke-width="2.5" stroke-linejoin="round"/>
  </svg>`;
}

/* ---- Profil ---- */
function renderProfile() {
  const b = state.budget;
  app.innerHTML = `
    <div class="header"><h1>Profil</h1></div>
    <div class="card" style="padding:6px 16px;">
      ${settingRow('📊', 'Statistiques', 'var(--info)', 'stats')}
      ${settingRow('🏆', 'Résumé mensuel', 'var(--warning)', 'summary')}
      ${settingRow('💰', 'Ajouter de l\'argent', 'var(--positive)', 'addmoney')}
      ${settingRow('🔁', 'Nouveau budget', 'var(--info)', 'newbudget')}
    </div>
    <div class="card" style="padding:6px 16px;">
      ${settingRow('🔔', 'Notifications', 'var(--warning)', 'notif')}
      ${settingRow('📤', 'Réinitialiser les données', 'var(--danger)', 'reset')}
    </div>
    <p class="center muted small" style="margin-top:18px;">Budget Quotidien — v1.0.0 (PWA)</p>
    <p class="center muted tiny">Devise : ${symbolFor(b.currency)} · ${b.expenses.length} dépense(s)</p>
  `;
  document.querySelectorAll('[data-setting]').forEach(el => el.onclick = () => {
    const a = el.dataset.setting;
    if (a === 'stats') openStats();
    else if (a === 'summary') openSummary();
    else if (a === 'addmoney') openAddIncome();
    else if (a === 'newbudget') openSetupFull();
    else if (a === 'notif') openNotifications();
    else if (a === 'reset') confirmReset();
  });
}
function settingRow(icon, label, tint, action) {
  return `<div class="list-item" data-setting="${action}" style="cursor:pointer;">
    <div class="disc-sm" style="background:${tint};color:#fff;border-radius:9px;font-size:15px;">${icon}</div>
    <span style="flex:1;">${label}</span><span class="muted">›</span></div>`;
}

/* ------------------------------------------------------------------ */
/* Feuilles modales                                                    */
/* ------------------------------------------------------------------ */
function openSheet(innerHTML, onMount) {
  modalRoot.innerHTML = `<div class="sheet-backdrop" id="sheetBd"><div class="sheet">${innerHTML}</div></div>`;
  document.getElementById('sheetBd').addEventListener('click', e => { if (e.target.id === 'sheetBd') closeSheet(); });
  if (onMount) onMount();
}
function closeSheet() { modalRoot.innerHTML = ''; }

/* ---- Ajouter une dépense (clavier) ---- */
let draftExpense;
function openAddExpense() {
  if (!state.budget) return;
  draftExpense = { amount: 0, category: 'Alimentation', subcategory: '', details: '', method: 'Espèces', date: new Date().toISOString() };
  openSheet(addExpenseHTML(), bindAddExpense);
}
function addExpenseHTML() {
  const code = state.budget.currency;
  return `
    <div class="sheet-head"><span></span><span class="t">Nouvelle dépense</span><span></span></div>
    <div class="sheet-body">
      <div class="amount-display"><span class="big" id="ae-amount">0</span> <span class="muted">${symbolFor(code)}</span></div>
      <label class="small muted">Catégorie</label>
      <div class="chip-scroll" id="ae-cats">
        ${Object.entries(CATEGORIES).map(([name, c]) => `
          <button class="cat ${name === 'Alimentation' ? 'on' : ''}" data-cat="${name}">
            <span class="disc" style="background:${c.color}26;color:${c.color}">${c.icon}</span>${name}</button>`).join('')}
      </div>
      <div class="chip-scroll" id="ae-subs"></div>
      <div class="field"><input class="input" id="ae-details" placeholder="Description (ex. Déjeuner au maquis)"/></div>
      <div class="field"><label>Paiement</label>
        <select class="input" id="ae-method">${PAYMENTS.map(p => `<option>${p}</option>`).join('')}</select></div>
    </div>
    <div class="keypad" id="ae-keypad">
      ${['1','2','3','4','5','6','7','8','9'].map(k => `<button class="key" data-k="${k}">${k}</button>`).join('')}
      <button class="key ${fractionDigits(code) ? '' : 'blank'}" data-k=".">${fractionDigits(code) ? '.' : ''}</button>
      <button class="key" data-k="0">0</button>
      <button class="key" data-k="back">⌫</button>
    </div>
    <div class="sheet-actions">
      <button class="btn secondary" id="ae-cancel">Annuler</button>
      <button class="btn" id="ae-save" disabled>Enregistrer</button>
    </div>`;
}
function bindAddExpense() {
  const code = state.budget.currency;
  let raw = '';
  const amountEl = document.getElementById('ae-amount');
  const saveBtn = document.getElementById('ae-save');
  const refresh = () => {
    draftExpense.amount = parseFloat(raw) || 0;
    amountEl.textContent = draftExpense.amount ? money(draftExpense.amount, code, false) : '0';
    saveBtn.disabled = draftExpense.amount <= 0;
  };
  document.getElementById('ae-keypad').addEventListener('click', e => {
    const k = e.target.closest('[data-k]')?.dataset.k; if (!k) return; haptic();
    if (k === 'back') raw = raw.slice(0, -1);
    else if (k === '.') { if (fractionDigits(code) && !raw.includes('.')) raw += raw ? '.' : '0.'; }
    else { if (raw.includes('.') && raw.split('.')[1].length >= fractionDigits(code)) return; raw = raw === '0' ? k : raw + k; }
    refresh();
  });
  renderSubs();
  document.getElementById('ae-cats').addEventListener('click', e => {
    const btn = e.target.closest('[data-cat]'); if (!btn) return; haptic();
    draftExpense.category = btn.dataset.cat; draftExpense.subcategory = '';
    document.querySelectorAll('#ae-cats .cat').forEach(c => c.classList.toggle('on', c.dataset.cat === draftExpense.category));
    renderSubs();
  });
  function renderSubs() {
    const subs = (CATEGORIES[draftExpense.category] || {}).subs || [];
    document.getElementById('ae-subs').innerHTML = subs.map(s =>
      `<button class="pill ${draftExpense.subcategory === s ? 'on' : ''}" data-sub="${s}"
        style="${draftExpense.subcategory === s ? `background:${CATEGORIES[draftExpense.category].color}` : ''}">${s}</button>`).join('');
    document.querySelectorAll('#ae-subs [data-sub]').forEach(p => p.onclick = () => {
      draftExpense.subcategory = draftExpense.subcategory === p.dataset.sub ? '' : p.dataset.sub; haptic(); renderSubs();
    });
  }
  document.getElementById('ae-cancel').onclick = closeSheet;
  document.getElementById('ae-save').onclick = () => {
    if (draftExpense.amount <= 0) return;
    draftExpense.details = document.getElementById('ae-details').value.trim();
    draftExpense.method = document.getElementById('ae-method').value;
    state.budget.expenses.push({ id: uid(), ...draftExpense });
    save(); haptic(15); closeSheet(); currentTab = 'home'; render();
  };
}

/* ---- Ajouter de l'argent ---- */
function openAddIncome() {
  if (!state.budget) return;
  const code = state.budget.currency;
  openSheet(`
    <div class="sheet-head"><span></span><span class="t">Ajouter de l'argent</span><span></span></div>
    <div class="sheet-body">
      <div class="amount-display"><input id="ai-amount" class="input" type="tel" inputmode="numeric" placeholder="50000"
        style="font-size:34px;text-align:center;font-weight:800;color:var(--positive);box-shadow:none;background:none;"/>
        <div class="muted">${symbolFor(code)}</div></div>
      <label class="small muted">Type</label>
      <div class="card" style="padding:6px 12px;margin:8px 0 16px;">
        ${Object.entries(INCOME_TYPES).map(([name, t], i) => `
          <div class="list-item" data-type="${name}" style="cursor:pointer;">
            <div class="disc-sm" style="background:${t.color}26;color:${t.color}">${t.icon}</div>
            <span style="flex:1;">${name}</span>
            <span class="sel" style="color:${i === 0 ? 'var(--positive)' : 'var(--separator)'}">${i === 0 ? '●' : '○'}</span>
          </div>`).join('')}
      </div>
      <div class="field"><label>Description</label><input class="input" id="ai-details" placeholder="Salaire mensuel"/></div>
    </div>
    <div class="sheet-actions">
      <button class="btn secondary" id="ai-cancel">Annuler</button>
      <button class="btn" id="ai-save">Enregistrer</button>
    </div>`, () => {
    let type = 'Salaire';
    document.querySelectorAll('[data-type]').forEach(el => el.onclick = () => {
      type = el.dataset.type; haptic();
      document.querySelectorAll('[data-type] .sel').forEach(s => { s.textContent = '○'; s.style.color = 'var(--separator)'; });
      const sel = el.querySelector('.sel'); sel.textContent = '●'; sel.style.color = 'var(--positive)';
    });
    document.getElementById('ai-cancel').onclick = closeSheet;
    document.getElementById('ai-save').onclick = () => {
      const amount = parseFloat(document.getElementById('ai-amount').value) || 0;
      if (amount <= 0) { document.getElementById('ai-amount').focus(); return; }
      state.budget.incomes.push({ id: uid(), amount, type, details: document.getElementById('ai-details').value.trim(), date: new Date().toISOString() });
      save(); haptic(15); closeSheet(); render();
    };
  });
}

/* ---- Statistiques (feuille) ---- */
function openStats() {
  const b = state.budget, code = b.currency;
  openSheet(`<div class="sheet-head"><span></span><span class="t">Statistiques</span><button id="st-close">Fermer</button></div>
    <div class="sheet-body"><div class="card">${statsBlock(b, code)}</div></div>`,
    () => document.getElementById('st-close').onclick = closeSheet);
}

/* ---- Résumé mensuel ---- */
function openSummary() {
  const b = state.budget, s = snapshot(b), code = b.currency;
  const d = respectedDays(b);
  const tracked = Math.max(d.respected + d.exceeded, 1);
  const rate = Math.round(d.respected / tracked * 100);
  const savings = Math.max(s.remaining, 0);
  openSheet(`
    <div class="sheet-head"><span></span><span class="t">Résumé mensuel</span><button id="sm-close">Fermer</button></div>
    <div class="sheet-body">
      <div class="card center">
        <div class="trophy">${rate >= 70 ? '🏆' : '🚩'}</div>
        <h1 style="margin:8px 0;">${rate >= 70 ? 'Bravo !' : 'Continuez !'}</h1>
        <p class="muted">${rate >= 70 ? 'Vous avez bien géré votre budget ce mois-ci.' : 'Chaque jour compte pour progresser.'}</p>
      </div>
      <div class="grid2">
        ${statCard('％', 'Taux de réussite', rate + '%', 'var(--positive)')}
        ${statCard('✅', 'Jours respectés', d.respected + '/' + tracked, 'var(--info)')}
        ${statCard('💵', 'Économisé', money(savings, code), 'var(--positive)')}
        ${statCard('⚠️', 'Jours dépassés', String(d.exceeded), 'var(--danger)')}
      </div>
      <div class="card">
        ${statRow('Budget initial', money(s.initialAmount, code))}
        ${statRow('Argent ajouté', money(s.totalIncome, code), 'var(--positive)')}
        ${statRow('Total dépensé', money(s.totalSpent, code), 'var(--danger)')}
        ${statRow('Économies réalisées', money(savings, code), 'var(--positive)')}
      </div>
    </div>`, () => document.getElementById('sm-close').onclick = closeSheet);
}

/* ---- Notifications ---- */
function openNotifications() {
  const b = state.budget, s = snapshot(b), code = b.currency;
  const feed = [];
  if (s.status === 'over') feed.push(['⚠️', 'var(--danger)', `Budget dépassé de ${money(s.spentToday - s.recommended, code)} aujourd'hui.`]);
  else if (s.status === 'warning') feed.push(['🔶', 'var(--warning)', `Il reste ${money(s.remainingToday, code)} pour aujourd'hui.`]);
  else feed.push(['🎯', 'var(--info)', `Il vous reste ${money(s.remainingToday, code)} à dépenser aujourd'hui.`]);
  feed.push(['📅', 'var(--info)', `${s.daysRemaining} jours restants, conseillé ${money(s.recommended, code)}/jour.`]);
  if (s.spentToday === 0) feed.push(['☀️', 'var(--warning)', "Aucune dépense enregistrée aujourd'hui. Pensez à suivre vos dépenses."]);
  openSheet(`<div class="sheet-head"><span></span><span class="t">Notifications</span><button id="nt-close">Fermer</button></div>
    <div class="sheet-body"><div class="card" style="padding:6px 16px;">
      ${feed.map(([i, c, t]) => `<div class="list-item"><div class="disc-sm" style="background:${c}26;color:${c}">${i}</div><span style="flex:1;">${t}</span></div>`).join('')}
    </div><p class="tiny muted center" style="margin-top:14px;">Les notifications système complètes sont disponibles dans la version App Store native.</p></div>`,
    () => document.getElementById('nt-close').onclick = closeSheet);
}

/* ---- Réinitialiser ---- */
function confirmReset() {
  openSheet(`<div class="sheet-head"><span></span><span class="t">Réinitialiser</span><button id="rs-close">Annuler</button></div>
    <div class="sheet-body"><div class="card center"><p>Cette action efface le budget et toutes les dépenses. Continuer ?</p>
    <button class="btn danger" id="rs-do" style="margin-top:14px;">Tout effacer</button></div></div>`, () => {
    document.getElementById('rs-close').onclick = closeSheet;
    document.getElementById('rs-do').onclick = () => { state = { onboarded: true, budget: null }; save(); closeSheet(); currentTab = 'home'; render(); };
  });
}

/* ------------------------------------------------------------------ */
/* Utilitaires                                                         */
/* ------------------------------------------------------------------ */
function escapeHTML(str) { return String(str || '').replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c])); }

/* ------------------------------------------------------------------ */
/* Navigation                                                          */
/* ------------------------------------------------------------------ */
tabbar.addEventListener('click', e => {
  const btn = e.target.closest('.tab'); if (!btn) return;
  if (btn.dataset.action === 'add-expense') { haptic(12); openAddExpense(); return; }
  if (btn.dataset.tab) { currentTab = btn.dataset.tab; haptic(); render(); }
});

/* Le « Nouveau budget » depuis le profil ouvre le formulaire plein écran */
function openSetupFull() { state.budget = null; save(); render(); }

render();
