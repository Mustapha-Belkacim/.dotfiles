# Slide patterns

Copy-paste blocks. All classes are defined in `assets/theme.css` — do not invent new
CSS unless a pattern genuinely doesn't exist here; extend `theme.css` if you must, so
every deck stays consistent.

Every `<section>` must carry an `<aside class="notes">` with the spoken narrative.

## Section head elements

```html
<span class="eyebrow">Deep Dive · KEY-1042</span>
<h2>Plain words <span class="grad">accented words</span></h2>   <!-- .grad = blue, .grad-warm = orange -->
<p class="lead">One-sentence framing sentence.</p>
```

## KPI row (from commit data)

```html
<div class="grid g4" style="margin-top:14px;">
  <div class="card kpi"><div class="n">26</div><div class="l">Tickets closed</div></div>
</div>
```

## Problem → fix

```html
<div class="pf" style="margin-top:8px;">
  <div class="card prob"><h3>🔴 Root cause</h3><p class="small muted">…</p></div>
  <div class="card fix"><h3>🟢 Fix</h3><p class="small muted">…</p></div>
</div>
```

## Business / technical value pair

```html
<div class="grid g2" style="margin-top:16px;">
  <div class="card" style="border-left:3px solid var(--gold);">
    <h3>💼 Business value</h3><p class="tiny muted">…</p></div>
  <div class="card" style="border-left:3px solid var(--accent);">
    <h3>⚙️ Technical value</h3><p class="tiny muted">…</p></div>
</div>
```

## Ticket table

```html
<table style="margin-top:14px;">
  <thead><tr><th>Ticket</th><th>Failure</th><th>Fix</th></tr></thead>
  <tbody>
    <tr><td><span class="mono">KEY-1007</span></td><td>…</td><td>…</td></tr>
  </tbody>
</table>
```

## Code walkthrough

```html
<pre style="margin-top:14px;"><code data-trim data-line-numbers class="language-python">
…real code from the diff, ≤ 12 lines…
</code></pre>
<p class="small center" style="margin-top:10px;">One-line explanation of why it's safe.</p>
```

## Flow diagram

```html
<div class="flow">
  <div class="node"><span class="ic">🗄️</span><b>Source</b>system</div>
  <div class="arrow">→</div>
  <div class="node"><span class="ic">⚙️</span><b>Adapter</b>extract</div>
</div>
```

## Stage pipeline

```html
<div class="stages">
  <div class="stg done"><b>dev</b>merged</div>
  <div class="arrow">→</div>
  <div class="stg"><b>prd</b>pending</div>
</div>
```

## Checklist (lessons)

```html
<ul class="checklist small">
  <li><b>Short imperative headline.</b> One sentence of evidence.</li>
</ul>
```

## Pills

```html
<span class="pill hard">Blocker</span>   <!-- red -->
<span class="pill warm">Risk</span>      <!-- orange -->
<span class="pill soft">Info</span>      <!-- blue -->
<span class="pill good">Resolved</span>  <!-- green -->
```

## Cards grid with coloured left borders (workstreams)

Order the accent colours: `var(--alert)`, `var(--warm)`, `var(--accent)`, `var(--gold)`,
then `var(--ok)`.

```html
<div class="card" style="border-left:3px solid var(--alert);">
  <h3>1 · Workstream title</h3>
  <p class="tiny muted">KEY-101 · 102 — what it covers</p>
</div>
```

## Title / closing slide

```html
<section data-background-color="#081226">
  <div class="center">
    <span class="eyebrow">Sprint Readout · 11 – 24 Aug 2026</span>
    <h1>Plain <span class="grad">accent</span></h1>
    <p class="lead" style="margin-top:24px;">line one<br/>line two</p>
    <div class="stripe center-block"></div>
    <p class="small muted" style="margin-top:26px;">{{TEAM_NAME}} · {{PRESENTER_NAME}} · Team Presentation</p>
  </div>
  <div class="footer"><span>{{FOOTER_LEFT}}</span><span>Sprint Readout</span></div>
</section>
```

## Layout budget

Slides are 1280×760, `.reveal` font-size 30px, `section` is top-aligned. Content that
overflows is silently clipped, so per slide keep to roughly:

- one `h2` + one `.lead` + **one** main block (grid, table or `pre`)
- tables ≤ 6 rows, `pre` ≤ 12 lines, grids ≤ 4 cards
- if it doesn't fit, split into two slides rather than shrinking text
