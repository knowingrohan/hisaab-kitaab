
// hk-screens3.jsx — PDF Report + Overdue Screen
const { Icon, Avatar, C, TextInput, BottomSheet } = window;
const { SOCIETIES, formatDate } = window.HKData;

// ─── PDF REPORT SCREEN ───────────────────────────────────────────────────────
function PDFReportScreen({ customer, transactions, onBack }) {
  const [dateFrom, setDateFrom] = React.useState("");
  const [dateTo, setDateTo] = React.useState("");
  const [showPrint, setShowPrint] = React.useState(false);

  const filtered = transactions.filter(t => {
    const d = new Date(t.date);
    if (dateFrom && d < new Date(dateFrom)) return false;
    if (dateTo && d > new Date(dateTo + "T23:59:59")) return false;
    return true;
  });

  const totalGave = filtered.filter(t => t.type === "gave").reduce((s, t) => s + t.amount, 0);
  const totalGot  = filtered.filter(t => t.type === "got").reduce((s, t) => s + t.amount, 0);
  const balance   = totalGave - totalGot;
  const today     = new Date().toLocaleDateString("en-IN", { day: "2-digit", month: "short", year: "numeric" });

  return (
    <div style={{ flex: 1, display: "flex", flexDirection: "column", background: C.bg, overflow: "hidden" }}>
      {/* Header */}
      <div style={{ background: `linear-gradient(135deg, ${C.primaryDark}, ${C.primaryLight})`, padding: "12px 16px 16px" }}>
        <div style={{ display: "flex", alignItems: "center", gap: 12, marginBottom: 6 }}>
          <button onClick={onBack} style={{ background: "rgba(255,255,255,0.15)", border: "none", borderRadius: 8, padding: "7px 8px", cursor: "pointer" }}>
            <Icon name="back" size={20} color="#fff" />
          </button>
          <div>
            <div style={{ color: "#fff", fontWeight: 700, fontSize: 17 }}>Transaction Report</div>
            <div style={{ color: "#B0C6FF", fontSize: 12 }}>{customer.flat} · {customer.name}</div>
          </div>
          <button onClick={() => setShowPrint(true)} style={{ marginLeft: "auto", background: "rgba(255,255,255,0.15)", border: "none", borderRadius: 8, padding: "7px 10px", cursor: "pointer", color: "#fff", fontSize: 12, fontWeight: 700, fontFamily: "inherit", display: "flex", alignItems: "center", gap: 5 }}>
            <Icon name="pdf" size={15} color="#fff" /> Export
          </button>
        </div>
        {/* Date range filter */}
        <div style={{ display: "flex", gap: 8, marginTop: 8 }}>
          <div style={{ flex: 1 }}>
            <div style={{ color: "#B0C6FF", fontSize: 10, fontWeight: 600, marginBottom: 4, textTransform: "uppercase", letterSpacing: 0.4 }}>From</div>
            <input type="date" value={dateFrom} onChange={e => setDateFrom(e.target.value)}
              style={{ width: "100%", padding: "8px 10px", border: "none", borderRadius: 8, fontSize: 13, fontFamily: "inherit", outline: "none", background: "rgba(255,255,255,0.15)", color: "#fff", colorScheme: "dark", boxSizing: "border-box" }} />
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ color: "#B0C6FF", fontSize: 10, fontWeight: 600, marginBottom: 4, textTransform: "uppercase", letterSpacing: 0.4 }}>To</div>
            <input type="date" value={dateTo} onChange={e => setDateTo(e.target.value)}
              style={{ width: "100%", padding: "8px 10px", border: "none", borderRadius: 8, fontSize: 13, fontFamily: "inherit", outline: "none", background: "rgba(255,255,255,0.15)", color: "#fff", colorScheme: "dark", boxSizing: "border-box" }} />
          </div>
        </div>
      </div>

      <div style={{ flex: 1, overflowY: "auto", padding: "0 0 16px" }}>
        {/* Bill preview */}
        <div style={{ margin: "12px", background: C.card, borderRadius: 16, overflow: "hidden", boxShadow: "0 2px 12px rgba(0,0,0,0.08)" }}>
          {/* Bill header */}
          <div style={{ background: C.primary, padding: "16px 18px", display: "flex", justifyContent: "space-between", alignItems: "flex-start" }}>
            <div>
              <div style={{ color: "#fff", fontWeight: 900, fontSize: 18, letterSpacing: -0.3 }}>🧺 Hisaab Kitaab</div>
              <div style={{ color: "#B0C6FF", fontSize: 11, marginTop: 2 }}>Shivaswamy Iron & Laundry</div>
              <div style={{ color: "#B0C6FF", fontSize: 11 }}>UPI: shivaswamy@upi</div>
            </div>
            <div style={{ textAlign: "right" }}>
              <div style={{ color: "rgba(255,255,255,0.7)", fontSize: 10, textTransform: "uppercase", letterSpacing: 0.4 }}>Invoice Date</div>
              <div style={{ color: "#fff", fontSize: 12, fontWeight: 700 }}>{today}</div>
            </div>
          </div>

          {/* Customer info */}
          <div style={{ padding: "14px 18px", background: "#F8FAFF", borderBottom: `1px solid ${C.border}`, display: "flex", justifyContent: "space-between" }}>
            <div>
              <div style={{ fontSize: 10, color: C.textMuted, textTransform: "uppercase", letterSpacing: 0.4, fontWeight: 600 }}>Bill To</div>
              <div style={{ fontWeight: 800, fontSize: 15, color: C.text, marginTop: 3 }}>{customer.name}</div>
              <div style={{ fontSize: 12, color: C.textSub }}>{customer.flat} · {customer.society}</div>
              {customer.phone && <div style={{ fontSize: 12, color: C.textSub }}>{customer.phone}</div>}
            </div>
            <div style={{ textAlign: "right" }}>
              <div style={{ fontSize: 10, color: C.textMuted, textTransform: "uppercase", letterSpacing: 0.4, fontWeight: 600 }}>Period</div>
              <div style={{ fontSize: 11, color: C.textSub, marginTop: 3 }}>
                {dateFrom ? new Date(dateFrom).toLocaleDateString("en-IN", { day: "2-digit", month: "short" }) : "All time"}
              </div>
              <div style={{ fontSize: 11, color: C.textSub }}>
                {dateTo ? "to " + new Date(dateTo).toLocaleDateString("en-IN", { day: "2-digit", month: "short" }) : ""}
              </div>
            </div>
          </div>

          {/* Summary boxes */}
          <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gap: 0, borderBottom: `1px solid ${C.border}` }}>
            {[
              { label: "Total Laundry", val: totalGave, color: C.red, bg: C.redLight },
              { label: "Total Paid", val: totalGot, color: C.green, bg: C.greenLight },
              { label: "Balance Due", val: balance, color: balance > 0 ? C.red : C.green, bg: balance > 0 ? C.redLight : C.greenLight },
            ].map((s, i) => (
              <div key={s.label} style={{ padding: "12px 10px", textAlign: "center", borderRight: i < 2 ? `1px solid ${C.border}` : "none", background: s.bg }}>
                <div style={{ fontSize: 9, color: C.textSub, textTransform: "uppercase", letterSpacing: 0.4, fontWeight: 600 }}>{s.label}</div>
                <div style={{ fontSize: 16, fontWeight: 900, color: s.color, marginTop: 4 }}>₹{s.val}</div>
              </div>
            ))}
          </div>

          {/* Transaction table */}
          <div>
            <div style={{ display: "grid", gridTemplateColumns: "1fr 70px 70px", padding: "8px 12px", background: "#F0F2F5", fontSize: 9, fontWeight: 700, color: C.textSub, textTransform: "uppercase", letterSpacing: 0.5, borderBottom: `1px solid ${C.border}` }}>
              <span>Date / Note</span>
              <span style={{ textAlign: "center" }}>Laundry</span>
              <span style={{ textAlign: "center" }}>Paid</span>
            </div>
            {filtered.length === 0 && (
              <div style={{ padding: "20px", textAlign: "center", color: C.textMuted, fontSize: 13 }}>No transactions in this period</div>
            )}
            {filtered.map((t, i) => (
              <div key={t.id} style={{ display: "grid", gridTemplateColumns: "1fr 70px 70px", padding: "9px 12px", borderBottom: i < filtered.length - 1 ? `1px solid ${C.border}` : "none", background: i % 2 === 0 ? "#fff" : "#FAFBFF" }}>
                <div>
                  <div style={{ fontSize: 11, fontWeight: 600, color: C.text }}>
                    {new Date(t.date).toLocaleDateString("en-IN", { day: "2-digit", month: "short", year: "2-digit" })}
                  </div>
                  {t.desc && <div style={{ fontSize: 10, color: C.textMuted }}>{t.desc}</div>}
                </div>
                <div style={{ textAlign: "center", display: "flex", alignItems: "center", justifyContent: "center" }}>
                  {t.type === "gave" ? <span style={{ fontSize: 12, fontWeight: 700, color: C.red }}>₹{t.amount}</span> : <span style={{ fontSize: 11, color: C.textMuted }}>—</span>}
                </div>
                <div style={{ textAlign: "center", display: "flex", alignItems: "center", justifyContent: "center" }}>
                  {t.type === "got" ? <span style={{ fontSize: 12, fontWeight: 700, color: C.green }}>₹{t.amount}</span> : <span style={{ fontSize: 11, color: C.textMuted }}>—</span>}
                </div>
              </div>
            ))}
          </div>

          {/* Footer */}
          <div style={{ padding: "12px 18px", background: "#F8FAFF", borderTop: `1px solid ${C.border}` }}>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
              <div style={{ fontSize: 11, color: C.textMuted }}>Generated by Hisaab Kitaab</div>
              <div style={{ fontWeight: 800, fontSize: 14, color: balance > 0 ? C.red : C.green }}>
                {balance > 0 ? `Net Due: ₹${balance}` : "✓ Fully Settled"}
              </div>
            </div>
            {balance > 0 && (
              <div style={{ marginTop: 8, padding: "8px 10px", background: "#FEF3C7", borderRadius: 8, fontSize: 11, color: "#92400E", fontWeight: 600 }}>
                Pay via UPI: shivaswamy@upi · Amount: ₹{balance}
              </div>
            )}
          </div>
        </div>

        {/* Action buttons */}
        <div style={{ padding: "0 12px", display: "flex", flexDirection: "column", gap: 10 }}>
          <button onClick={() => setShowPrint(true)} style={{ width: "100%", padding: "14px", background: C.primary, color: "#fff", border: "none", borderRadius: 12, fontSize: 15, fontWeight: 700, cursor: "pointer", fontFamily: "inherit", display: "flex", alignItems: "center", justifyContent: "center", gap: 8 }}>
            <Icon name="pdf" size={18} color="#fff" /> Download / Print PDF
          </button>
          <button style={{ width: "100%", padding: "14px", background: "#25D366", color: "#fff", border: "none", borderRadius: 12, fontSize: 15, fontWeight: 700, cursor: "pointer", fontFamily: "inherit", display: "flex", alignItems: "center", justifyContent: "center", gap: 8 }}>
            <Icon name="whatsapp" size={18} color="#fff" /> Share via WhatsApp
          </button>
          <button style={{ width: "100%", padding: "14px", background: C.card, color: C.primary, border: `1.5px solid ${C.primary}`, borderRadius: 12, fontSize: 15, fontWeight: 700, cursor: "pointer", fontFamily: "inherit", display: "flex", alignItems: "center", justifyContent: "center", gap: 8 }}>
            <Icon name="sms" size={18} color={C.primary} /> Send via SMS
          </button>
        </div>
      </div>

      {/* Print confirmation sheet */}
      <BottomSheet open={showPrint} onClose={() => setShowPrint(false)} title="Export Report">
        <div style={{ padding: "16px 20px" }}>
          <div style={{ background: C.bg, borderRadius: 12, padding: "14px", marginBottom: 14 }}>
            <div style={{ fontWeight: 700, fontSize: 14, color: C.text, marginBottom: 6 }}>{customer.name} — Statement</div>
            <div style={{ fontSize: 12, color: C.textSub }}>
              {filtered.length} transactions · Balance: ₹{balance}
            </div>
          </div>
          {[
            { label: "Save as PDF to device", icon: "pdf", color: C.primary },
            { label: "Print via Bluetooth printer", icon: "pdf", color: C.primary },
            { label: "Share as PDF via WhatsApp", icon: "whatsapp", color: "#25D366" },
            { label: "Share as Image (screenshot)", icon: "image", color: C.primary },
          ].map(opt => (
            <button key={opt.label} onClick={() => setShowPrint(false)} style={{ width: "100%", padding: "13px 14px", background: C.bg, border: `1px solid ${C.border}`, borderRadius: 12, fontSize: 14, fontWeight: 600, cursor: "pointer", fontFamily: "inherit", display: "flex", alignItems: "center", gap: 10, marginBottom: 8, color: C.text }}>
              <Icon name={opt.icon} size={18} color={opt.color} />
              {opt.label}
            </button>
          ))}
        </div>
      </BottomSheet>
    </div>
  );
}

// ─── OVERDUE SCREEN ───────────────────────────────────────────────────────────
function OverdueScreen({ customers, transactions, threshold = 200, onBack, onCustomer }) {
  const [sending, setSending] = React.useState({});
  const [sentAll, setSentAll] = React.useState(false);

  const overdue = customers.filter(c => c.balance > threshold).sort((a, b) => b.balance - a.balance);

  // Group by society
  const bySociety = SOCIETIES.reduce((acc, s) => {
    const list = overdue.filter(c => c.society === s);
    if (list.length) acc[s] = list;
    return acc;
  }, {});

  const withPhone = overdue.filter(c => c.phone);
  const totalDue = overdue.reduce((s, c) => s + c.balance, 0);

  function sendReminder(cid) {
    setSending(p => ({ ...p, [cid]: "sending" }));
    setTimeout(() => setSending(p => ({ ...p, [cid]: "sent" })), 1000);
  }

  function sendAllReminders() {
    const ids = withPhone.map(c => c.id);
    ids.forEach((id, i) => setTimeout(() => setSending(p => ({ ...p, [id]: "sending" })), i * 300));
    setTimeout(() => {
      setSending(Object.fromEntries(ids.map(id => [id, "sent"])));
      setSentAll(true);
    }, ids.length * 300 + 800);
  }

  return (
    <div style={{ flex: 1, display: "flex", flexDirection: "column", background: C.bg, overflow: "hidden" }}>
      {/* Header */}
      <div style={{ background: `linear-gradient(135deg, #92400E, #F59E0B)`, padding: "12px 16px 16px" }}>
        <div style={{ display: "flex", alignItems: "center", gap: 12, marginBottom: 12 }}>
          <button onClick={onBack} style={{ background: "rgba(255,255,255,0.2)", border: "none", borderRadius: 8, padding: "7px 8px", cursor: "pointer" }}>
            <Icon name="back" size={20} color="#fff" />
          </button>
          <div>
            <div style={{ color: "#fff", fontWeight: 800, fontSize: 17 }}>⚠ Overdue Accounts</div>
            <div style={{ color: "rgba(255,255,255,0.8)", fontSize: 12 }}>Threshold: ₹{threshold}</div>
          </div>
        </div>
        {/* Summary */}
        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gap: 8 }}>
          {[
            { label: "Overdue", val: overdue.length, unit: "customers" },
            { label: "Total Due", val: "₹" + totalDue.toLocaleString("en-IN"), unit: "" },
            { label: "Can Remind", val: withPhone.length, unit: "with phone" },
          ].map(s => (
            <div key={s.label} style={{ background: "rgba(255,255,255,0.15)", borderRadius: 10, padding: "10px 8px", textAlign: "center" }}>
              <div style={{ color: "#fff", fontWeight: 900, fontSize: 16 }}>{s.val}</div>
              <div style={{ color: "rgba(255,255,255,0.75)", fontSize: 9, textTransform: "uppercase", letterSpacing: 0.4, marginTop: 2 }}>{s.label}</div>
            </div>
          ))}
        </div>
      </div>

      {/* Bulk send bar */}
      <div style={{ background: C.card, padding: "12px 14px", borderBottom: `1px solid ${C.border}`, display: "flex", alignItems: "center", gap: 10 }}>
        {sentAll ? (
          <div style={{ flex: 1, display: "flex", alignItems: "center", gap: 8, color: C.green, fontWeight: 700, fontSize: 14 }}>
            <Icon name="check" size={18} color={C.green} strokeWidth={3} /> All reminders sent!
          </div>
        ) : (
          <>
            <div style={{ flex: 1, fontSize: 13, color: C.textSub }}>
              <span style={{ fontWeight: 700, color: C.text }}>{withPhone.length}</span> customers have phone numbers
            </div>
            <button onClick={sendAllReminders} style={{ background: "#25D366", color: "#fff", border: "none", borderRadius: 10, padding: "10px 14px", fontSize: 13, fontWeight: 700, cursor: "pointer", fontFamily: "inherit", display: "flex", alignItems: "center", gap: 6, whiteSpace: "nowrap" }}>
              <Icon name="whatsapp" size={16} color="#fff" /> Send All
            </button>
          </>
        )}
      </div>

      {/* Grouped list */}
      <div style={{ flex: 1, overflowY: "auto", padding: "8px 0 16px" }}>
        {Object.entries(bySociety).map(([society, list]) => (
          <div key={society} style={{ marginBottom: 8 }}>
            <div style={{ padding: "8px 16px 4px", fontSize: 11, fontWeight: 700, color: C.textSub, textTransform: "uppercase", letterSpacing: 0.6, display: "flex", alignItems: "center", gap: 6 }}>
              <div style={{ flex: 1 }}>{society}</div>
              <div style={{ color: C.red, fontWeight: 800 }}>₹{list.reduce((s, c) => s + c.balance, 0).toLocaleString("en-IN")} due</div>
            </div>
            {list.map(c => {
              const status = sending[c.id];
              return (
                <div key={c.id} style={{ background: C.card, margin: "0 12px 6px", borderRadius: 14, padding: "12px 14px", boxShadow: "0 1px 4px rgba(0,0,0,0.06)", border: `1px solid ${status === "sent" ? "#BBF7D0" : "#FDE68A"}` }}>
                  <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
                    <div onClick={() => onCustomer(c)} style={{ display: "flex", alignItems: "center", gap: 10, flex: 1, cursor: "pointer" }}>
                      <Avatar name={c.name} size={40} bg={C.red} />
                      <div style={{ flex: 1, minWidth: 0 }}>
                        <div style={{ fontWeight: 700, fontSize: 14, color: C.text, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>{c.flat} · {c.name}</div>
                        <div style={{ fontSize: 11, color: C.textSub, marginTop: 1 }}>{c.phone || <span style={{ color: C.textMuted, fontStyle: "italic" }}>No phone</span>}</div>
                      </div>
                      <div style={{ fontWeight: 900, fontSize: 16, color: C.red }}>₹{c.balance}</div>
                    </div>
                    {/* Action buttons */}
                    <div style={{ display: "flex", gap: 6, marginLeft: 8 }}>
                      {c.phone ? (
                        status === "sent" ? (
                          <div style={{ width: 36, height: 36, borderRadius: 10, background: "#DCFCE7", display: "flex", alignItems: "center", justifyContent: "center" }}>
                            <Icon name="check" size={18} color={C.green} strokeWidth={3} />
                          </div>
                        ) : status === "sending" ? (
                          <div style={{ width: 36, height: 36, borderRadius: 10, background: "#F0FDF4", display: "flex", alignItems: "center", justifyContent: "center" }}>
                            <div style={{ width: 16, height: 16, border: `2.5px solid ${C.green}`, borderTopColor: "transparent", borderRadius: "50%", animation: "spin 0.7s linear infinite" }} />
                          </div>
                        ) : (
                          <button onClick={() => sendReminder(c.id)} style={{ width: 36, height: 36, borderRadius: 10, background: "#DCFCE7", border: "none", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center" }}>
                            <Icon name="whatsapp" size={18} color="#25D366" />
                          </button>
                        )
                      ) : (
                        <div style={{ width: 36, height: 36, borderRadius: 10, background: C.bg, display: "flex", alignItems: "center", justifyContent: "center" }} title="No phone number">
                          <Icon name="warn" size={18} color={C.textMuted} />
                        </div>
                      )}
                      <a href={c.phone ? `tel:${c.phone}` : "#"} style={{ width: 36, height: 36, borderRadius: 10, background: c.phone ? "#EEF2FF" : C.bg, display: "flex", alignItems: "center", justifyContent: "center", textDecoration: "none", opacity: c.phone ? 1 : 0.4 }}>
                        <Icon name="phone" size={17} color="#4338CA" />
                      </a>
                    </div>
                  </div>
                  {/* Balance bar */}
                  <div style={{ marginTop: 8 }}>
                    <div style={{ height: 4, borderRadius: 2, background: C.border, overflow: "hidden" }}>
                      <div style={{ height: "100%", width: `${Math.min(100, (c.balance / 1000) * 100)}%`, background: c.balance > 500 ? C.red : "#F59E0B", borderRadius: 2, transition: "width 0.5s" }} />
                    </div>
                    <div style={{ display: "flex", justifyContent: "space-between", marginTop: 3, fontSize: 10, color: C.textMuted }}>
                      <span>Threshold: ₹{threshold}</span>
                      <span style={{ fontWeight: 700, color: C.red }}>+₹{c.balance - threshold} over limit</span>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        ))}

        {overdue.length === 0 && (
          <div style={{ textAlign: "center", padding: "60px 24px", color: C.textMuted }}>
            <div style={{ fontSize: 44, marginBottom: 10 }}>🎉</div>
            <div style={{ fontWeight: 700, fontSize: 16, color: C.text }}>All accounts are clear!</div>
            <div style={{ fontSize: 13, marginTop: 6 }}>No customers above the ₹{threshold} threshold</div>
          </div>
        )}
      </div>
    </div>
  );
}

// ─── EXPORTS ─────────────────────────────────────────────────────────────────
Object.assign(window, { PDFReportScreen, OverdueScreen });
