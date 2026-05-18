
// hk-onboarding.jsx — First-run vendor setup wizard

const STEPS = [
  { id: "welcome",   title: "Welcome",        icon: "🧺" },
  { id: "profile",   title: "Your Profile",   icon: "👤" },
  { id: "upi",       title: "UPI Setup",      icon: "💳" },
  { id: "societies", title: "Societies",      icon: "🏘" },
  { id: "threshold", title: "Alert Settings", icon: "⚠️" },
  { id: "done",      title: "All Set!",       icon: "🎉" },
];

function StepDots({ current, total }) {
  const C = window.C;
  return (
    <div style={{ display: "flex", gap: 6, justifyContent: "center", marginBottom: 24 }}>
      {Array.from({ length: total }).map((_, i) => (
        <div key={i} style={{ width: i === current ? 20 : 7, height: 7, borderRadius: 4, background: i === current ? C.primary : i < current ? "#B0C6FF" : C.border, transition: "all 0.3s" }} />
      ))}
    </div>
  );
}

function OnboardingScreen({ onComplete }) {
  const C = window.C;
  const Icon = window.Icon;
  const [step, setStep] = React.useState(0);
  const [vendorName, setVendorName] = React.useState("");
  const [businessName, setBusinessName] = React.useState("");
  const [upiId, setUpiId] = React.useState("");
  const [societies, setSocieties] = React.useState(["Klassik Landmark"]);
  const [newSociety, setNewSociety] = React.useState("");
  const [threshold, setThreshold] = React.useState(200);
  const [err, setErr] = React.useState("");

  const canNext = () => {
    if (step === 1) return vendorName.trim().length > 0 && businessName.trim().length > 0;
    if (step === 2) return upiId.trim().length > 0 && upiId.includes("@");
    if (step === 3) return societies.length > 0;
    return true;
  };

  function next() {
    setErr("");
    if (!canNext()) { setErr("Please fill all required fields."); return; }
    if (step < STEPS.length - 1) setStep(s => s + 1);
    else onComplete({ vendorName, businessName, upiId, societies, threshold });
  }
  function back() { setErr(""); setStep(s => Math.max(0, s - 1)); }
  function addSociety() {
    if (!newSociety.trim()) return;
    if (societies.includes(newSociety.trim())) { setErr("Society already added."); return; }
    if (societies.length >= 5) { setErr("Max 5 societies allowed."); return; }
    setSocieties(s => [...s, newSociety.trim()]);
    setNewSociety(""); setErr("");
  }

  return (
    <div style={{ flex: 1, display: "flex", flexDirection: "column", background: C.bg, overflow: "hidden" }}>
      {/* Progress bar */}
      {step > 0 && step < STEPS.length - 1 && (
        <div style={{ height: 3, background: C.border }}>
          <div style={{ height: "100%", width: `${(step / (STEPS.length - 2)) * 100}%`, background: C.primary, transition: "width 0.4s ease" }} />
        </div>
      )}

      <div style={{ flex: 1, overflowY: "auto", display: "flex", flexDirection: "column" }}>
        {/* ── STEP 0: WELCOME ── */}
        {step === 0 && (
          <div style={{ flex: 1, display: "flex", flexDirection: "column", background: C.primary }}>
            <div style={{ flex: 1, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", padding: "40px 24px 0", textAlign: "center" }}>
              <div style={{ fontSize: 64, marginBottom: 16 }}>🧺</div>
              <div style={{ color: "#fff", fontSize: 28, fontWeight: 900, letterSpacing: -0.5, marginBottom: 8 }}>Welcome to<br />Hisaab Kitaab</div>
              <div style={{ color: "#B0C6FF", fontSize: 14, lineHeight: 1.7, maxWidth: 260 }}>
                Your digital register for iron & laundry. Let's set up your business in under 2 minutes.
              </div>
              <div style={{ display: "flex", gap: 16, marginTop: 28, flexWrap: "wrap", justifyContent: "center" }}>
                {["Track pickups", "Send reminders", "Collect payments"].map(f => (
                  <div key={f} style={{ background: "rgba(255,255,255,0.12)", borderRadius: 20, padding: "6px 14px", color: "#fff", fontSize: 12, fontWeight: 600 }}>✓ {f}</div>
                ))}
              </div>
            </div>
            <div style={{ background: C.bg, borderRadius: "28px 28px 0 0", padding: "28px 24px 24px" }}>
              <StepDots current={0} total={STEPS.length} />
              <button onClick={next} style={{ width: "100%", padding: "15px", background: C.primary, color: "#fff", border: "none", borderRadius: 14, fontSize: 16, fontWeight: 700, cursor: "pointer", fontFamily: "inherit" }}>
                Get Started →
              </button>
              <div style={{ textAlign: "center", marginTop: 12, fontSize: 12, color: C.textMuted }}>Takes about 2 minutes</div>
            </div>
          </div>
        )}

        {/* ── STEP 1: PROFILE ── */}
        {step === 1 && (
          <div style={{ flex: 1, display: "flex", flexDirection: "column", padding: "28px 20px 20px" }}>
            <div style={{ textAlign: "center", marginBottom: 24 }}>
              <div style={{ fontSize: 40, marginBottom: 8 }}>👤</div>
              <div style={{ fontSize: 20, fontWeight: 800, color: C.text }}>Tell us about yourself</div>
              <div style={{ fontSize: 13, color: C.textSub, marginTop: 4 }}>This will appear on bills and reminders</div>
            </div>
            <StepDots current={1} total={STEPS.length} />
            <div style={{ background: C.card, borderRadius: 16, padding: "20px 16px", boxShadow: "0 2px 8px rgba(0,0,0,0.06)" }}>
              <div style={{ marginBottom: 14 }}>
                <label style={{ fontSize: 12, fontWeight: 600, color: C.textSub, letterSpacing: 0.4, textTransform: "uppercase" }}>Your Name <span style={{ color: C.red }}>*</span></label>
                <input value={vendorName} onChange={e => setVendorName(e.target.value)} placeholder="e.g. Shivaswamy" style={{ display: "block", width: "100%", marginTop: 6, padding: "12px", border: `1.5px solid ${vendorName ? C.primary : C.border}`, borderRadius: 10, fontSize: 15, fontFamily: "inherit", outline: "none", boxSizing: "border-box" }} />
              </div>
              <div style={{ marginBottom: 0 }}>
                <label style={{ fontSize: 12, fontWeight: 600, color: C.textSub, letterSpacing: 0.4, textTransform: "uppercase" }}>Business Name <span style={{ color: C.red }}>*</span></label>
                <input value={businessName} onChange={e => setBusinessName(e.target.value)} placeholder="e.g. Shivaswamy Iron & Laundry" style={{ display: "block", width: "100%", marginTop: 6, padding: "12px", border: `1.5px solid ${businessName ? C.primary : C.border}`, borderRadius: 10, fontSize: 15, fontFamily: "inherit", outline: "none", boxSizing: "border-box" }} />
              </div>
            </div>
          </div>
        )}

        {/* ── STEP 2: UPI ── */}
        {step === 2 && (
          <div style={{ flex: 1, display: "flex", flexDirection: "column", padding: "28px 20px 20px" }}>
            <div style={{ textAlign: "center", marginBottom: 24 }}>
              <div style={{ fontSize: 40, marginBottom: 8 }}>💳</div>
              <div style={{ fontSize: 20, fontWeight: 800, color: C.text }}>Set your UPI ID</div>
              <div style={{ fontSize: 13, color: C.textSub, marginTop: 4 }}>Customers pay directly to this UPI ID</div>
            </div>
            <StepDots current={2} total={STEPS.length} />
            <div style={{ background: C.card, borderRadius: 16, padding: "20px 16px", marginBottom: 12, boxShadow: "0 2px 8px rgba(0,0,0,0.06)" }}>
              <label style={{ fontSize: 12, fontWeight: 600, color: C.textSub, letterSpacing: 0.4, textTransform: "uppercase" }}>UPI ID / VPA <span style={{ color: C.red }}>*</span></label>
              <input value={upiId} onChange={e => setUpiId(e.target.value)} placeholder="yourname@upi or @okicici" style={{ display: "block", width: "100%", marginTop: 6, padding: "12px", border: `1.5px solid ${upiId.includes("@") ? C.primary : C.border}`, borderRadius: 10, fontSize: 15, fontFamily: "inherit", outline: "none", boxSizing: "border-box" }} />
              <div style={{ fontSize: 11, color: C.textMuted, marginTop: 6 }}>e.g. shivaswamy@okicici, 9876543210@upi</div>
            </div>
            {upiId.includes("@") && (
              <div style={{ background: "#F0FDF4", borderRadius: 14, padding: "14px 16px", border: `1px solid #BBF7D0` }}>
                <div style={{ fontSize: 11, fontWeight: 700, color: C.green, textTransform: "uppercase", letterSpacing: 0.4, marginBottom: 8 }}>✓ Payment link preview</div>
                <div style={{ fontFamily: "monospace", fontSize: 11, color: C.textSub, wordBreak: "break-all", background: "#fff", padding: "8px 10px", borderRadius: 8, lineHeight: 1.6 }}>
                  upi://pay?pa={upiId}&am=<span style={{ color: C.red }}>AMOUNT</span>&tn=Hisaab+Kitaab
                </div>
                <div style={{ fontSize: 11, color: C.textSub, marginTop: 8 }}>This link will be included in every WhatsApp reminder automatically.</div>
              </div>
            )}
          </div>
        )}

        {/* ── STEP 3: SOCIETIES ── */}
        {step === 3 && (
          <div style={{ flex: 1, display: "flex", flexDirection: "column", padding: "28px 20px 20px" }}>
            <div style={{ textAlign: "center", marginBottom: 24 }}>
              <div style={{ fontSize: 40, marginBottom: 8 }}>🏘</div>
              <div style={{ fontSize: 20, fontWeight: 800, color: C.text }}>Add your societies</div>
              <div style={{ fontSize: 13, color: C.textSub, marginTop: 4 }}>Where do you serve? (up to 5)</div>
            </div>
            <StepDots current={3} total={STEPS.length} />
            <div style={{ background: C.card, borderRadius: 16, padding: "16px", marginBottom: 12, boxShadow: "0 2px 8px rgba(0,0,0,0.06)" }}>
              <div style={{ display: "flex", gap: 8, marginBottom: 14 }}>
                <input value={newSociety} onChange={e => setNewSociety(e.target.value)} onKeyDown={e => e.key === "Enter" && addSociety()} placeholder="Type society name…" style={{ flex: 1, padding: "10px 12px", border: `1.5px solid ${C.border}`, borderRadius: 10, fontSize: 14, fontFamily: "inherit", outline: "none" }} />
                <button onClick={addSociety} style={{ background: C.primary, color: "#fff", border: "none", borderRadius: 10, padding: "10px 14px", cursor: "pointer", fontWeight: 700, fontSize: 18 }}>+</button>
              </div>
              {societies.length === 0 && <div style={{ textAlign: "center", color: C.textMuted, fontSize: 13, padding: "12px 0" }}>Add at least one society</div>}
              <div style={{ display: "flex", flexWrap: "wrap", gap: 8 }}>
                {societies.map(s => (
                  <div key={s} style={{ display: "flex", alignItems: "center", gap: 6, background: "#EEF2FF", borderRadius: 20, padding: "6px 10px 6px 14px", border: `1px solid #C7D2FE` }}>
                    <span style={{ fontSize: 13, fontWeight: 600, color: "#4338CA" }}>{s}</span>
                    <button onClick={() => setSocieties(list => list.filter(x => x !== s))} style={{ background: "none", border: "none", cursor: "pointer", padding: 0, display: "flex", alignItems: "center" }}>
                      <Icon name="x" size={14} color="#6366F1" />
                    </button>
                  </div>
                ))}
              </div>
            </div>
            {err && <div style={{ color: C.red, fontSize: 13, background: C.redLight, padding: "8px 12px", borderRadius: 8, marginBottom: 10 }}>{err}</div>}
            <div style={{ background: "#FFF7ED", borderRadius: 12, padding: "12px 14px", border: "1px solid #FED7AA" }}>
              <div style={{ fontSize: 12, color: "#92400E", fontWeight: 600, marginBottom: 4 }}>💡 Tip</div>
              <div style={{ fontSize: 12, color: "#B45309", lineHeight: 1.6 }}>You can filter customers by society on the home screen. Add all societies you serve for easy management.</div>
            </div>
          </div>
        )}

        {/* ── STEP 4: THRESHOLD ── */}
        {step === 4 && (
          <div style={{ flex: 1, display: "flex", flexDirection: "column", padding: "28px 20px 20px" }}>
            <div style={{ textAlign: "center", marginBottom: 24 }}>
              <div style={{ fontSize: 40, marginBottom: 8 }}>⚠️</div>
              <div style={{ fontSize: 20, fontWeight: 800, color: C.text }}>Alert Settings</div>
              <div style={{ fontSize: 13, color: C.textSub, marginTop: 4 }}>When should we flag a customer as overdue?</div>
            </div>
            <StepDots current={4} total={STEPS.length} />
            <div style={{ background: C.card, borderRadius: 16, padding: "20px 16px", marginBottom: 12, boxShadow: "0 2px 8px rgba(0,0,0,0.06)" }}>
              <label style={{ fontSize: 12, fontWeight: 600, color: C.textSub, letterSpacing: 0.4, textTransform: "uppercase" }}>Overdue Threshold</label>
              <div style={{ display: "flex", alignItems: "center", marginTop: 10, gap: 10 }}>
                <span style={{ fontSize: 20, fontWeight: 800, color: C.primary }}>₹</span>
                <input type="number" value={threshold} onChange={e => setThreshold(Number(e.target.value))} min={50} max={10000} style={{ flex: 1, padding: "12px", border: `2px solid ${C.primary}`, borderRadius: 10, fontSize: 24, fontWeight: 800, fontFamily: "inherit", outline: "none", color: C.text }} />
              </div>
              <div style={{ marginTop: 14 }}>
                <div style={{ fontSize: 12, color: C.textSub, marginBottom: 10 }}>Quick select:</div>
                <div style={{ display: "flex", gap: 8, flexWrap: "wrap" }}>
                  {[100, 200, 300, 500, 1000].map(v => (
                    <button key={v} onClick={() => setThreshold(v)} style={{ padding: "8px 14px", borderRadius: 20, border: `1.5px solid ${threshold === v ? C.primary : C.border}`, background: threshold === v ? "#EEF2FF" : C.bg, color: threshold === v ? C.primary : C.text, fontSize: 13, fontWeight: 600, cursor: "pointer", fontFamily: "inherit" }}>₹{v}</button>
                  ))}
                </div>
              </div>
            </div>
            <div style={{ background: "#EEF2FF", borderRadius: 12, padding: "14px", border: "1px solid #C7D2FE" }}>
              <div style={{ fontSize: 13, color: "#4338CA", lineHeight: 1.7 }}>
                Customers with a balance above <strong>₹{threshold}</strong> will appear in the overdue list and the home screen warning badge.
              </div>
            </div>
          </div>
        )}

        {/* ── STEP 5: DONE ── */}
        {step === 5 && (
          <div style={{ flex: 1, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", padding: "32px 24px", textAlign: "center" }}>
            <div style={{ fontSize: 64, marginBottom: 16, animation: "fadeSlide 0.5s ease" }}>🎉</div>
            <div style={{ fontSize: 22, fontWeight: 900, color: C.text, marginBottom: 8 }}>You're all set, {vendorName}!</div>
            <div style={{ fontSize: 14, color: C.textSub, lineHeight: 1.7, maxWidth: 280, marginBottom: 28 }}>
              Your business is configured. Start adding customers and tracking pickups right away.
            </div>
            {/* Summary card */}
            <div style={{ background: C.card, borderRadius: 16, padding: "18px 20px", width: "100%", boxShadow: "0 2px 12px rgba(0,0,0,0.08)", marginBottom: 24, textAlign: "left" }}>
              {[
                { label: "Business", val: businessName },
                { label: "UPI ID", val: upiId },
                { label: "Societies", val: societies.join(", ") },
                { label: "Overdue threshold", val: "₹" + threshold },
              ].map(r => (
                <div key={r.label} style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", paddingBottom: 10, marginBottom: 10, borderBottom: `1px solid ${C.border}` }}>
                  <span style={{ fontSize: 12, color: C.textSub, fontWeight: 600, textTransform: "uppercase", letterSpacing: 0.4, paddingTop: 2 }}>{r.label}</span>
                  <span style={{ fontSize: 13, fontWeight: 700, color: C.text, textAlign: "right", maxWidth: "60%" }}>{r.val}</span>
                </div>
              ))}
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                <span style={{ fontSize: 12, color: C.textSub, fontWeight: 600, textTransform: "uppercase", letterSpacing: 0.4 }}>Status</span>
                <span style={{ fontSize: 13, fontWeight: 700, color: C.green }}>✓ Ready</span>
              </div>
            </div>
            <StepDots current={5} total={STEPS.length} />
          </div>
        )}
      </div>

      {/* Bottom nav */}
      {step > 0 && (
        <div style={{ padding: "12px 20px 16px", background: C.card, borderTop: `1px solid ${C.border}`, display: "flex", gap: 10 }}>
          {step < STEPS.length - 1 && (
            <button onClick={back} style={{ padding: "13px 20px", background: C.bg, border: `1.5px solid ${C.border}`, borderRadius: 12, fontSize: 15, fontWeight: 700, cursor: "pointer", fontFamily: "inherit", color: C.text }}>
              ← Back
            </button>
          )}
          <button onClick={next} style={{ flex: 1, padding: "13px", background: canNext() ? C.primary : C.border, color: "#fff", border: "none", borderRadius: 12, fontSize: 15, fontWeight: 700, cursor: canNext() ? "pointer" : "not-allowed", fontFamily: "inherit", transition: "background 0.2s" }}>
            {step === STEPS.length - 2 ? "Almost done →" : step === STEPS.length - 1 ? "🚀 Go to App" : "Continue →"}
          </button>
        </div>
      )}
      {err && step > 0 && step < STEPS.length - 1 && (
        <div style={{ padding: "0 20px 10px", color: C.red, fontSize: 13, fontWeight: 600 }}>⚠ {err}</div>
      )}
    </div>
  );
}

Object.assign(window, { OnboardingScreen });
