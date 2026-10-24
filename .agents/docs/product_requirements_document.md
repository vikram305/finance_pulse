# Product Requirements Document (PRD)

## 1. Product Vision & Positioning
* **Working Title:** Pulse (The Financial Sandbox)
* **Category:** Offline-First Financial Resilience & Simulation Utility
* **Core Value Proposition:** A private, zero-latency simulation engine for visualizing the downstream impact of major life transitions.
* **Market Differentiator:** Operates entirely offline. 100% Free and Open Source. No ads, no bank logins, no data harvesting, no automated micro-budgeting, and no guilt. Positioned as "anti-greed" consumer software.

## 2. Target Audience
* **Demographic:** Professionals (Ages 25–38) experiencing or planning significant lifestyle transitions.
* **Use Cases:** Planning a wedding, relocating cities, evaluating a vehicle purchase, or assessing the runway for a career pivot.
* **Psychology:** Highly protective of data privacy; overwhelmed by spreadsheet building; paralyzed by compounding financial variables.

## 3. Web-to-Mobile Acquisition Funnel

1. **Discovery (The Billboard):** Users find the SEO-optimized HTML landing page (`getpulse.com`) via organic search.
2. **The Hook (The Web Playground):** Users click "Try the Sandbox" and are instantly taken to the Flutter Web (WASM) session-scoped playground. They experience the 10-Second Strawman onboarding with zero installation friction. The web session state is backed by IndexedDB but is treated as volatile — users are shown a persistent header warning that clearing browser cache will erase their sandbox.
3. **The Lock-In (The Mobile App):** After building their scenario, users are prompted to export a `.pulse` file (requires entering a one-time PIN — see ADR-004) and download the native iOS/Android app to import it. The native app is the only path to: the full Panic Room, the Projected Resilience Score, persistent encrypted storage, and biometric security.

### Web Playground Feature Exclusions (Hard Walls)
The following features are **intentionally absent** from the Flutter Web build. Their absence is the product mechanic that drives mobile downloads:

| Feature | Web | Mobile |
| :--- | :---: | :---: |
| Strawman Onboarding & Sandbox Engine | ✅ | ✅ |
| A/B Scenario Forking | ✅ | ✅ |
| `.pulse` Export (ephemeral PIN) | ✅ | ✅ |
| `.pulse` Import | ❌ | ✅ |
| Panic Room (Shock chips) | ❌ | ✅ |
| Projected Resilience Score | ❌ | ✅ |
| Persistent encrypted storage (Isar) | ❌ | ✅ |
| Biometric / presentation shielding | ❌ | ✅ |

## 4. Core User Journeys (Native App)

### 4.1 The 10-Second Hook (Onboarding)
1. User opens the app (no splash screen, no account creation).
2. UI prompts for **Current Liquid Balance** and **Monthly Net Income**.
3. A dismissible notice informs the user: *"The Strawman blocks below are auto-generated estimates. The accuracy of your Projected Resilience Score depends on how much you correct them."*
4. App instantly transitions to the dashboard, displaying a 12-month trajectory chart populated with auto-generated "Strawman" blocks (Rent, Living Costs, EMI).
5. User taps a block to correct the value; the chart animates to the new trajectory instantly.

### 4.2 The Sandbox Engine (Single & Forked Scenarios)

#### Single-Scenario Flow
1. User drags a new "Event Block" onto their timeline.
2. User configures block parameters (Name, Amount, Polarity, Start Month, Duration).
3. The chart immediately redraws the projection against the baseline.

#### A/B Scenario Forking Flow
1. User taps "Fork Scenario" to create a named alternative (e.g., *"Scenario A: Buy a Car"* vs. *"Scenario B: Use Ubers"*).
2. Both Scenarios are displayed simultaneously on the same chart canvas as two distinct Bezier trajectory lines, rendered in contrasting colours with a legend.
3. User configures Event Blocks independently per Scenario. Adding a block to Scenario A does not affect Scenario B.
4. The chart updates both trajectories in real time as blocks are edited in either Scenario.
5. User can rename, duplicate, or delete any Scenario except the last remaining one.

### 4.3 The Panic Room (Stress Test)
The Panic Room applies stress shocks **at the app level, across all active Scenarios simultaneously**. This is its primary power: the user sees which of their competing futures is more resilient under the same external shock.

1. User enters the Panic Room. Both Scenario trajectories remain visible on the chart.
2. A **Projected Resilience Score** (0–100) is shown **per Scenario** side-by-side (e.g., *"Scenario A: 34 | Scenario B: 71"*). The score is labelled "Projected Resilience" — never "Resilience Score" — to make clear it is simulation-based, not derived from verified actuals.
3. User taps a quick-toggle "Shock" chip (e.g., *Job Loss*, *Medical Emergency*). The shock is injected as a `FinancialShock` event into **every active Scenario's** projection engine simultaneously.
4. Both trajectory lines visually crash (or diverge). The diagnostic panel updates per Scenario: *"Scenario A: 2 months survival cash | Scenario B: 6 months survival cash."*
5. The comparison makes the resilience gap undeniable. The user can toggle Shock chips on and off freely; each change recalculates all Scenarios in real time.

## 5. Feature Scope Boundary

| Feature Category | In Scope for V1 | Out of Scope for V1 |
| :--- | :--- | :--- |
| **Data Ingestion** | Manual two-input start, gamified block correction | Bank sync, SMS scraping, PDF/CSV parsing |
| **Simulation** | Time-bound events, draggable sliders, named A/B Scenario forking | Live investment growth models, multi-currency |
| **Analytics** | Runway calculation, per-Scenario Projected Resilience Score (0–100), cross-Scenario Shock comparison | Categorized past-expense pie charts |
| **Platform** | iOS, Android, Session-scoped Flutter Web Playground | Centralized cloud databases, user accounts |
| **Portability** | Ephemeral-PIN-encrypted `.pulse` export (web), PIN-encrypted `.pulse` import/export (mobile) | Cloud sync, cross-device auto-backup |