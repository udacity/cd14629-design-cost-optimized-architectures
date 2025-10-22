#!/bin/bash
set -euxo pipefail

# --- Update system and install Apache ---
dnf -y update
dnf -y install httpd

# --- Enable and start Apache service ---
systemctl enable httpd
systemctl start httpd

# --- Write the HTML file ---
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Demo Shop — Billing</title>
  <style>
    :root{
      --bg: #0f1221;
      --panel: #171a2b;
      --muted: #98a2b3;
      --text: #eef2ff;
      --primary: #7c5cff;
      --ring: rgba(124, 92, 255, .35);
      --ok: #16a34a;
      --warn: #eab308;
      --err: #ef4444;
      --info: #3b82f6;
      --chip: #22253a;
      --chip-border: #2b2f48;
      --border: #262a41;
      --hover: #1d2140;
      --shadow: 0 0 0 1px var(--border), 0 10px 30px rgba(0,0,0,.35);
      --radius: 14px;
    }
    *{box-sizing:border-box}
    html,body{height:100%}
    body{margin:0;background:linear-gradient(180deg,#0b0e1b 0%,var(--bg) 100%);color:var(--text);font:500 16px/1.5 system-ui, -apple-system, Segoe UI, Roboto, Inter, "Helvetica Neue", Arial}
    .container{max-width:1200px;margin:24px auto;padding:0 20px}
    header{display:flex;align-items:center;gap:16px;margin-bottom:18px}
    .logo{display:grid;place-items:center;width:44px;height:44px;border-radius:12px;background:linear-gradient(135deg,var(--primary),#2dd4bf);box-shadow:var(--shadow)}
    .title h1{margin:0;font-size:20px;font-weight:700}
    .title p{margin:2px 0 0;color:var(--muted);font-size:13px}

    .panel{background:linear-gradient(180deg,#161a2c 0%,var(--panel) 100%);border:1px solid var(--border);border-radius:var(--radius);box-shadow:var(--shadow)}
    .toolbar{display:flex;flex-wrap:wrap;gap:10px;padding:14px;border-bottom:1px solid var(--border)}
    .toolbar .group{display:flex;gap:10px;align-items:center}
    input[type="text"], select, input[type="date"], input[type="number"]{
      background:#12162a;border:1px solid var(--border);color:var(--text);padding:10px 12px;border-radius:10px;outline:none;transition:border .2s, box-shadow .2s
    }
    input[type="text"]:focus, select:focus, input[type="date"]:focus, input[type="number"]:focus{box-shadow:0 0 0 3px var(--ring);border-color:var(--primary)}
    button{appearance:none;border:1px solid var(--border);background:#151935;color:var(--text);padding:10px 12px;border-radius:10px;cursor:pointer;transition:transform .03s ease, background .15s, border .15s}
    button:hover{background:var(--hover)}
    button:active{transform:translateY(1px)}
    .btn-primary{background:linear-gradient(180deg, #7c5cff, #6d4df6);border:0}
    .btn-primary:hover{filter:brightness(1.05)}

    .chip{display:inline-flex;align-items:center;gap:6px;padding:6px 10px;border:1px solid var(--chip-border);background:var(--chip);border-radius:999px;color:var(--muted);font-size:12px}
    .chip b{color:var(--text)}

    table{width:100%;border-collapse:separate;border-spacing:0 10px}
    thead th{color:var(--muted);font-weight:600;text-align:left;padding:10px 12px}
    tbody tr{background:#131732;border:1px solid var(--border)}
    tbody td{padding:12px;border-top:1px solid var(--border);border-bottom:1px solid var(--border)}
    tbody td:first-child{border-left:1px solid var(--border);border-top-left-radius:10px;border-bottom-left-radius:10px}
    tbody td:last-child{border-right:1px solid var(--border);border-top-right-radius:10px;border-bottom-right-radius:10px}

    .badge{padding:6px 10px;border-radius:999px;font-size:12px;font-weight:700;display:inline-flex;align-items:center;gap:6px}
    .paid{background:rgba(22,163,74,.12);color:#86efac;border:1px solid rgba(22,163,74,.35)}
    .partial{background:rgba(59,130,246,.14);color:#bfdbfe;border:1px solid rgba(59,130,246,.35)}
    .due{background:rgba(255,255,255,.06);color:#e5e7eb;border:1px dashed rgba(229,231,235,.25)}
    .overdue{background:rgba(239,68,68,.14);color:#fecaca;border:1px solid rgba(239,68,68,.35)}
    .refunded{background:rgba(234,179,8,.12);color:#fde68a;border:1px solid rgba(234,179,8,.35)}
    .void{background:rgba(148,163,184,.14);color:#e2e8f0;border:1px solid rgba(148,163,184,.35)}

    .actions{display:flex;gap:8px}

    .footer{display:flex;justify-content:space-between;align-items:center;padding:14px;border-top:1px solid var(--border)}
    .pagination{display:flex;align-items:center;gap:6px}
    .muted{color:var(--muted)}

    /* Dialogs */
    dialog{border:1px solid var(--border);background:linear-gradient(180deg,#151935,var(--panel));color:var(--text);border-radius:16px;box-shadow:var(--shadow);padding:0}
    dialog::backdrop{background:rgba(4,6,18,.65);backdrop-filter:blur(2px)}
    .sheet-header{padding:16px 18px;border-bottom:1px solid var(--border);display:flex;align-items:center;justify-content:space-between}
    .sheet-body{padding:18px;display:grid;grid-template-columns:1.2fr .8fr;gap:18px}
    @media (max-width: 900px){.sheet-body{grid-template-columns:1fr}}
    .card{background:#10142c;border:1px solid var(--border);border-radius:12px;padding:14px}
    .kv{display:grid;grid-template-columns:140px 1fr;gap:8px;font-size:14px}
    .kv div{padding:6px 0;border-bottom:1px dashed #263052}
    .kv div:last-child{border:0}
    .items{display:grid;gap:10px}
    .item{display:grid;grid-template-columns:1fr 80px 90px 100px;gap:10px;align-items:center;padding:10px;border:1px solid var(--border);border-radius:10px;background:#0f1430}
    .totals{display:grid;gap:8px}
    .totals .row{display:flex;justify-content:space-between}

    /* Small utility */
    .row-inline{display:flex;gap:10px;align-items:center}
  </style>
</head>
<body>
  <div class="container">
    <header aria-label="App header">
      <div class="logo" aria-hidden="true">
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" role="img" aria-label="Logo">
          <path d="M12 2l3.5 6 6.5.9-4.8 4.7 1.2 6.4L12 17l-6.4 3.9 1.2-6.4L2 8.9 8.5 8 12 2z" fill="white"/>
        </svg>
      </div>
      <div class="title">
        <h1>Demo Shop — Billing</h1>
        <p>Manage invoices, payments, and balances. Same styling as the Orders page.</p>
      </div>
      <div style="margin-left:auto" class="actions">
        <button id="exportCsv" title="Export visible invoices to CSV">Export CSV</button>
        <button class="btn-primary" id="newInvoice">Create Invoice</button>
      </div>
    </header>

    <section class="panel" aria-label="Billing panel">
      <div class="toolbar" role="group" aria-label="Filters and actions">
        <div class="group" style="flex:1 1 280px">
          <label for="search" class="sr-only">Search</label>
          <input id="search" type="text" placeholder="Search by invoice # or customer…" autocomplete="off" />
        </div>
        <div class="group">
          <select id="status" aria-label="Invoice status filter">
            <option value="">All statuses</option>
            <option>Paid</option>
            <option>Partially Paid</option>
            <option>Due</option>
            <option>Overdue</option>
            <option>Refunded</option>
            <option>Void</option>
          </select>
        </div>
        <div class="group">
          <input id="from" type="date" />
          <span class="muted" aria-hidden="true">→</span>
          <input id="to" type="date" />
        </div>
        <div class="group">
          <select id="sort" aria-label="Sort invoices">
            <option value="date_desc">Newest first</option>
            <option value="date_asc">Oldest first</option>
            <option value="total_desc">Amount: High → Low</option>
            <option value="total_asc">Amount: Low → High</option>
            <option value="balance_desc">Balance: High → Low</option>
            <option value="balance_asc">Balance: Low → High</option>
          </select>
        </div>
        <div class="group">
          <button id="clear">Clear filters</button>
        </div>
        <div class="group" style="margin-left:auto">
          <span class="chip" title="Invoices count"><b id="count">0</b> invoices</span>
        </div>
      </div>

      <div style="overflow:auto;padding:6px 10px 2px">
        <table role="table" aria-label="Invoices table">
          <thead>
            <tr>
              <th>Invoice</th>
              <th>Issued</th>
              <th>Due</th>
              <th>Customer</th>
              <th>Status</th>
              <th>Method</th>
              <th style="text-align:right">Amount</th>
              <th style="text-align:right">Balance</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody id="rows"></tbody>
        </table>
      </div>

      <div class="footer">
        <div class="muted" id="summary">Showing 0–0 of 0</div>
        <div class="pagination" role="navigation" aria-label="Pagination">
          <button id="prev">Prev</button>
          <span class="chip"><span id="page">1</span> / <span id="pages">1</span></span>
          <button id="next">Next</button>
          <select id="pageSize" aria-label="Rows per page">
            <option>5</option>
            <option selected>10</option>
            <option>20</option>
            <option>50</option>
          </select>
        </div>
      </div>
    </section>
  </div>

  <!-- Invoice Details -->
  <dialog id="sheet" aria-label="Invoice details">
    <div class="sheet-header">
      <div class="row-inline">
        <div class="chip"><b id="sheetId">INV-1001</b><span id="sheetStatus" class="badge due">Due</span></div>
      </div>
      <div class="actions">
        <button id="recordPayment">Record payment</button>
        <button id="sendInvoice">Send invoice</button>
        <button id="close">Close</button>
      </div>
    </div>
    <div class="sheet-body">
      <div class="card">
        <h3 style="margin:0 0 8px">Line Items</h3>
        <div class="items" id="sheetItems"></div>
        <div class="totals" style="margin-top:12px">
          <div class="row"><span class="muted">Subtotal</span><b id="sheetSubtotal">$0.00</b></div>
          <div class="row"><span class="muted">Discount</span><span id="sheetDiscount">$0.00</span></div>
          <div class="row"><span class="muted">Tax</span><span id="sheetTax">$0.00</span></div>
          <div class="row"><span class="muted">Paid</span><span id="sheetPaid">$0.00</span></div>
          <div class="row" style="border-top:1px dashed #2b2f48;padding-top:8px"><span>Total</span><b id="sheetTotal">$0.00</b></div>
          <div class="row"><span>Balance due</span><b id="sheetBalance">$0.00</b></div>
        </div>
      </div>
      <div class="card">
        <h3 style="margin:0 0 8px">Customer & Billing</h3>
        <div class="kv" id="sheetKv"></div>
        <h3 style="margin:16px 0 8px">Payment History</h3>
        <div class="items" id="sheetPayments"></div>
      </div>
    </div>
  </dialog>

  <!-- Simple Create Invoice Modal (demo) -->
  <dialog id="createModal" aria-label="Create invoice">
    <div class="sheet-header">
      <h3 style="margin:0">Create Invoice</h3>
      <button id="createClose">Close</button>
    </div>
    <div class="sheet-body" style="grid-template-columns:1fr">
      <div class="card">
        <div class="row-inline" style="margin-bottom:10px">
          <input id="ciCustomer" type="text" placeholder="Customer name" style="flex:1" />
          <input id="ciAmount" type="number" min="1" step="0.01" placeholder="Amount (AUD)" style="width:220px" />
        </div>
        <div class="row-inline" style="margin-bottom:10px">
          <input id="ciEmail" type="text" placeholder="Email" style="flex:1" />
          <select id="ciMethod" style="width:220px">
            <option>Card</option>
            <option>Bank Transfer</option>
            <option>PayPal</option>
          </select>
        </div>
        <div class="row-inline" style="margin-bottom:10px">
          <label class="muted" for="ciDiscount">Discount %</label>
          <input id="ciDiscount" type="number" min="0" max="100" step="1" placeholder="0" style="width:120px" />
          <label class="muted" for="ciTax">Tax %</label>
          <input id="ciTax" type="number" min="0" max="30" step="1" placeholder="10" style="width:120px" />
        </div>
        <button class="btn-primary" id="ciCreate">Create</button>
      </div>
    </div>
  </dialog>

  <template id="rowTpl">
    <tr>
      <td><button class="link" data-open aria-label="Open invoice"></button></td>
      <td data-issued></td>
      <td data-due></td>
      <td data-customer></td>
      <td data-status></td>
      <td data-method></td>
      <td style="text-align:right" data-amount></td>
      <td style="text-align:right" data-balance></td>
      <td>
        <div class="actions">
          <button data-open>View</button>
          <button data-download title="Download PDF">PDF</button>
        </div>
      </td>
    </tr>
  </template>

  <script>
    // --------------------------- Demo Data ---------------------------------
    const rnd = (min, max) => Math.floor(Math.random() * (max - min + 1)) + min;
    const pick = (arr) => arr[rnd(0, arr.length - 1)];
    const names = ["Olivia", "Liam", "Noah", "Emma", "Ava", "Sophia", "Mason", "James", "Isabella", "Lucas", "Amelia", "Ethan", "Mia", "Henry", "Harper"];
    const streets = ["Willow St", "Maple Ave", "Cedar Rd", "Oak Lane", "Sunset Blvd", "Lakeview Dr", "Parkside Ave"];
    const cities = ["Sydney", "Melbourne", "Brisbane", "Perth", "Adelaide"];

    const catalog = [
      {sku:"SUB-MONTH", name:"Pro Subscription (Monthly)", price: 49.0},
      {sku:"SUB-ANNUAL", name:"Pro Subscription (Annual)", price: 499.0},
      {sku:"SETUP", name:"Account Setup Fee", price: 149.0},
      {sku:"ADD-SEAT", name:"Additional Seat", price: 19.0},
      {sku:"COURSE-AWS", name:"AWS Course Bundle", price: 299.0},
    ];

    function dateAdd(d, days){ const t = new Date(d); t.setDate(t.getDate()+days); return t; }

    function makeInvoice(i){
      const id = 1000 + i;
      const issued = new Date(); issued.setDate(issued.getDate() - rnd(0, 60));
      const due = dateAdd(issued, pick([7,14,21,30]));
      const name = pick(names) + " " + String.fromCharCode(65 + rnd(0, 20)) + ".";
      const addr = `${rnd(12, 98)} ${pick(streets)}, ${pick(cities)}`;
      const email = name.toLowerCase().replace(/\s/g,'.').replace(/\.$/,'') + "@example.com";
      const method = pick(["Card","Bank Transfer","PayPal"]);
      const items = Array.from({length:rnd(1,3)}, ()=>{ const it = pick(catalog); return {...it, qty:rnd(1,3)}; });
      const subtotal = +items.reduce((s, it)=> s + it.price*it.qty, 0).toFixed(2);
      const discountPct = pick([0,0,0,10]);
      const discount = +(subtotal * discountPct/100).toFixed(2);
      const taxPct = 10;
      const tax = +((subtotal - discount) * taxPct/100).toFixed(2);
      const total = +(subtotal - discount + tax).toFixed(2);
      const alreadyPaid = pick([0,0,0, rnd(20, Math.min(total, 300))]);
      const payments = alreadyPaid ? [{date: dateAdd(issued, rnd(0,10)), amount: alreadyPaid, method}] : [];
      let status = 'Due';
      const today = new Date();
      const balance = +(total - payments.reduce((s,p)=>s+p.amount,0)).toFixed(2);
      if(balance <= 0) status = 'Paid';
      else if(payments.length && balance > 0) status = 'Partially Paid';
      if(status !== 'Paid' && today > due && balance > 0) status = 'Overdue';
      return { id, issued, due, customer:{name, email, address:addr}, method, items, subtotal, discount, tax, total, payments, status };
    }

    const allInvoices = Array.from({length: 48}, (_, i) => makeInvoice(i));

    // --------------------------- State & Elements ---------------------------
    const els = {
      rows: document.getElementById('rows'),
      search: document.getElementById('search'),
      status: document.getElementById('status'),
      from: document.getElementById('from'),
      to: document.getElementById('to'),
      sort: document.getElementById('sort'),
      clear: document.getElementById('clear'),
      count: document.getElementById('count'),
      summary: document.getElementById('summary'),
      page: document.getElementById('page'),
      pages: document.getElementById('pages'),
      prev: document.getElementById('prev'),
      next: document.getElementById('next'),
      pageSize: document.getElementById('pageSize'),
      exportCsv: document.getElementById('exportCsv'),
      newInvoice: document.getElementById('newInvoice'),
      sheet: document.getElementById('sheet'),
      sheetId: document.getElementById('sheetId'),
      sheetStatus: document.getElementById('sheetStatus'),
      sheetItems: document.getElementById('sheetItems'),
      sheetSubtotal: document.getElementById('sheetSubtotal'),
      sheetDiscount: document.getElementById('sheetDiscount'),
      sheetTax: document.getElementById('sheetTax'),
      sheetPaid: document.getElementById('sheetPaid'),
      sheetTotal: document.getElementById('sheetTotal'),
      sheetBalance: document.getElementById('sheetBalance'),
      sheetKv: document.getElementById('sheetKv'),
      sheetPayments: document.getElementById('sheetPayments'),
      recordPayment: document.getElementById('recordPayment'),
      sendInvoice: document.getElementById('sendInvoice'),
      close: document.getElementById('close'),
      createModal: document.getElementById('createModal'),
      createClose: document.getElementById('createClose'),
      ciCustomer: document.getElementById('ciCustomer'),
      ciAmount: document.getElementById('ciAmount'),
      ciEmail: document.getElementById('ciEmail'),
      ciMethod: document.getElementById('ciMethod'),
      ciDiscount: document.getElementById('ciDiscount'),
      ciTax: document.getElementById('ciTax'),
      ciCreate: document.getElementById('ciCreate'),
    };

    const state = { page: 1, pageSize: 10, query: '', status: '', from: '', to: '', sort: 'date_desc' };
    const fmt = new Intl.NumberFormat('en-AU', { style: 'currency', currency: 'AUD' });
    const dfmt = new Intl.DateTimeFormat('en-AU', { dateStyle: 'medium' });

    // --------------------------- Helpers -----------------------------------
    function invoiceBalance(inv){
      const paid = inv.payments.reduce((s,p)=>s+p.amount,0);
      return +(inv.total - paid).toFixed(2);
    }
    function statusBadge(status){
      const cls = { 'Paid':'paid', 'Partially Paid':'partial', 'Due':'due', 'Overdue':'overdue', 'Refunded':'refunded', 'Void':'void' }[status] || 'due';
      return `<span class="badge ${cls}">${status}</span>`;
    }
    function inRange(d){
      const t = d.getTime();
      const fromOk = !state.from || t >= new Date(state.from + 'T00:00:00').getTime();
      const toOk = !state.to || t <= new Date(state.to + 'T23:59:59').getTime();
      return fromOk && toOk;
    }
    function matches(inv){
      const q = state.query.trim().toLowerCase();
      const hit = !q || String(inv.id).includes(q) || inv.customer.name.toLowerCase().includes(q) || inv.customer.email.toLowerCase().includes(q);
      const st = !state.status || inv.status === state.status;
      return hit && st && inRange(inv.issued);
    }
    function sortInvoices(list){
      const s = state.sort;
      return [...list].sort((a,b)=>{
        if(s==='date_desc') return b.issued - a.issued;
        if(s==='date_asc') return a.issued - b.issued;
        if(s==='total_desc') return b.total - a.total;
        if(s==='total_asc') return a.total - b.total;
        if(s==='balance_desc') return invoiceBalance(b) - invoiceBalance(a);
        if(s==='balance_asc') return invoiceBalance(a) - invoiceBalance(b);
        return 0;
      });
    }

    // --------------------------- Render ------------------------------------
    function render(){
      const filtered = allInvoices.filter(matches);
      const sorted = sortInvoices(filtered);
      const total = sorted.length;
      const pages = Math.max(1, Math.ceil(total / state.pageSize));
      state.page = Math.min(state.page, pages);
      const start = (state.page - 1) * state.pageSize;
      const end = Math.min(start + state.pageSize, total);
      const slice = sorted.slice(start, end);

      els.rows.innerHTML = '';
      const tpl = document.getElementById('rowTpl');
      slice.forEach(inv => {
        const tr = tpl.content.firstElementChild.cloneNode(true);
        tr.querySelectorAll('[data-open]').forEach(b=>{ b.textContent = `INV-${inv.id}`; b.addEventListener('click', ()=>openInvoice(inv)); });
        tr.querySelector('[data-issued]').textContent = dfmt.format(inv.issued);
        tr.querySelector('[data-due]').textContent = dfmt.format(inv.due);
        tr.querySelector('[data-customer]').textContent = inv.customer.name;
        tr.querySelector('[data-status]').innerHTML = statusBadge(inv.status);
        tr.querySelector('[data-method]').textContent = inv.method;
        tr.querySelector('[data-amount]').textContent = fmt.format(inv.total);
        tr.querySelector('[data-balance]').textContent = fmt.format(invoiceBalance(inv));
        tr.querySelector('[data-download]').addEventListener('click', ()=>alert(`Pretend we downloaded INV-${inv.id}.pdf`));
        els.rows.appendChild(tr);
      });

      els.count.textContent = total;
      els.summary.textContent = total ? `Showing ${start+1}–${end} of ${total}` : 'No matching invoices';
      els.page.textContent = state.page; els.pages.textContent = pages;
      els.prev.disabled = state.page <= 1; els.next.disabled = state.page >= pages;
    }

    // --------------------------- Invoice Sheet -----------------------------
    let current = null;
    function openInvoice(inv){
      current = inv;
      els.sheetId.textContent = `INV-${inv.id}`;
      els.sheetStatus.className = 'badge ' + (
        {'Paid':'paid','Partially Paid':'partial','Due':'due','Overdue':'overdue','Refunded':'refunded','Void':'void'}[inv.status]||'due'
      );
      els.sheetStatus.textContent = inv.status;

      els.sheetItems.innerHTML = '';
      inv.items.forEach(it=>{
        const row = document.createElement('div');
        row.className = 'item';
        row.innerHTML = `
          <div><div><b>${it.name}</b></div><div class="muted">SKU: ${it.sku}</div></div>
          <div>x${it.qty}</div>
          <div>${fmt.format(it.price)}</div>
          <div style="text-align:right">${fmt.format(it.price*it.qty)}</div>`;
        els.sheetItems.appendChild(row);
      });
      const paid = inv.payments.reduce((s,p)=>s+p.amount,0);
      els.sheetSubtotal.textContent = fmt.format(inv.subtotal);
      els.sheetDiscount.textContent = fmt.format(inv.discount);
      els.sheetTax.textContent = fmt.format(inv.tax);
      els.sheetTotal.textContent = fmt.format(inv.total);
      els.sheetPaid.textContent = fmt.format(paid);
      els.sheetBalance.textContent = fmt.format(+((inv.total - paid).toFixed(2)));

      els.sheetKv.innerHTML = `
        <div><span class="muted">Customer</span><span>${inv.customer.name}</span></div>
        <div><span class="muted">Email</span><span>${inv.customer.email}</span></div>
        <div><span class="muted">Address</span><span>${inv.customer.address}</span></div>
        <div><span class="muted">Method</span><span>${inv.method}</span></div>
        <div><span class="muted">Issued</span><span>${dfmt.format(inv.issued)}</span></div>
        <div><span class="muted">Due</span><span>${dfmt.format(inv.due)}</span></div>
      `;

      els.sheetPayments.innerHTML = inv.payments.length ? '' : '<div class="muted">No payments yet.</div>';
      inv.payments.forEach(p=>{
        const row = document.createElement('div');
        row.className = 'item';
        row.style.gridTemplateColumns = '1fr 120px';
        row.innerHTML = `<div>${dfmt.format(p.date)} — ${inv.method}</div><div style="text-align:right">${fmt.format(p.amount)}</div>`;
        els.sheetPayments.appendChild(row);
      });
      els.sheet.showModal();
    }

    els.close.addEventListener('click', ()=> els.sheet.close());
    els.recordPayment.addEventListener('click', ()=>{
      if(!current) return;
      const remaining = invoiceBalance(current);
      const amount = Math.max(0, +prompt('Enter payment amount (AUD):', remaining) || 0);
      if(amount <= 0) return;
      current.payments.push({date:new Date(), amount, method: current.method});
      const bal = invoiceBalance(current);
      if(bal <= 0) current.status = 'Paid';
      else current.status = 'Partially Paid';
      render(); openInvoice(current);
    });
    els.sendInvoice.addEventListener('click', ()=>{
      if(!current) return; alert(`Pretend we emailed invoice INV-${current.id} to ${current.customer.email}.`);
    });

    // --------------------------- CSV Export --------------------------------
    function toCsv(rows){
      const esc = (v) => '"' + String(v).replace(/"/g,'""') + '"';
      const header = ['Invoice','Issued','Due','Customer','Status','Method','Amount','Balance'];
      const lines = [header.join(',')];
      rows.forEach(inv=>{
        lines.push([
          'INV-'+inv.id,
          dfmt.format(inv.issued),
          dfmt.format(inv.due),
          inv.customer.name,
          inv.status,
          inv.method,
          inv.total,
          invoiceBalance(inv)
        ].map(esc).join(','));
      });
      return lines.join('\n');
    }
    function download(filename, text){
      const a = document.createElement('a');
      a.href = URL.createObjectURL(new Blob([text], {type:'text/csv'}));
      a.download = filename; a.click();
      setTimeout(()=>URL.revokeObjectURL(a.href), 5000);
    }
    els.exportCsv.addEventListener('click', ()=>{
      const filtered = sortInvoices(allInvoices.filter(matches));
      download('invoices.csv', toCsv(filtered));
    });

    // --------------------------- Create Invoice ----------------------------
    els.newInvoice.addEventListener('click', ()=>{
      els.ciCustomer.value = '';
      els.ciAmount.value = '';
      els.ciEmail.value = '';
      els.ciDiscount.value = '0';
      els.ciTax.value = '10';
      els.ciMethod.value = 'Card';
      els.createModal.showModal();
    });
    els.createClose.addEventListener('click', ()=> els.createModal.close());
    els.ciCreate.addEventListener('click', ()=>{
      const name = els.ciCustomer.value.trim() || 'Walk-in Customer';
      const amount = Math.max(0.01, +els.ciAmount.value || 0);
      const email = els.ciEmail.value.trim() || 'customer@example.com';
      const method = els.ciMethod.value;
      const discountPct = Math.max(0, +els.ciDiscount.value || 0);
      const taxPct = Math.max(0, +els.ciTax.value || 0);
      const items = [{sku:'CUSTOM', name:'Custom Line Item', price: amount, qty:1}];
      const subtotal = amount;
      const discount = +(subtotal * discountPct/100).toFixed(2);
      const tax = +((subtotal - discount) * taxPct/100).toFixed(2);
      const total = +(subtotal - discount + tax).toFixed(2);
      const inv = {
        id: 1000 + allInvoices.length,
        issued: new Date(),
        due: new Date(Date.now() + 1000*60*60*24*14), // +14 days
        customer:{name, email, address: `${rnd(10,99)} ${pick(streets)}, ${pick(cities)}`},
        method, items, subtotal, discount, tax, total, payments: [], status:'Due'
      };
      allInvoices.unshift(inv);
      state.page = 1; render(); els.createModal.close(); openInvoice(inv);
    });

    // --------------------------- Events ------------------------------------
    els.search.addEventListener('input', e => { state.query = e.target.value; state.page = 1; render(); });
    els.status.addEventListener('change', e => { state.status = e.target.value; state.page = 1; render(); });
    els.from.addEventListener('change', e => { state.from = e.target.value; state.page = 1; render(); });
    els.to.addEventListener('change', e => { state.to = e.target.value; state.page = 1; render(); });
    els.sort.addEventListener('change', e => { state.sort = e.target.value; render(); });
    els.clear.addEventListener('click', () => { state.query=''; state.status=''; state.from=''; state.to=''; state.sort='date_desc'; els.search.value=''; els.status.value=''; els.from.value=''; els.to.value=''; els.sort.value='date_desc'; render(); });

    els.pageSize.addEventListener('change', e => { state.pageSize = +e.target.value; state.page = 1; render(); });
    els.prev.addEventListener('click', () => { if(state.page>1){ state.page--; render(); }});
    els.next.addEventListener('click', () => { state.page++; render(); });

    window.addEventListener('keydown', (e)=>{ if(e.key==='Escape'){ if(els.sheet.open) els.sheet.close(); if(els.createModal.open) els.createModal.close(); }});

    // Initial render
    render();
  </script>
</body>
</html>
EOF

# --- Set permissions ---
chown apache:apache /var/www/html/index.html
chmod 644 /var/www/html/index.html

# --- Ensure Apache is running ---
systemctl restart httpd
