
// All screens for Hisaab Kitaab prototype

// ─── ICONS (simple SVG inline) ───────────────────────────────────────────────
function Icon({ name, size = 20, color = "currentColor", strokeWidth = 2 }) {
  const s = { width: size, height: size, display: "inline-block", verticalAlign: "middle" };
  const paths = {
    search: <svg style={s} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth={strokeWidth}><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>,
    plus: <svg style={s} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth={strokeWidth}><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>,
    back: <svg style={s} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth={strokeWidth}><polyline points="15 18 9 12 15 6"/></svg>,
    phone: <svg style={s} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth={strokeWidth}><path d="M22 16.92v3a2 2 0 01-2.18 2 19.79 19.79 0 01-8.63-3.07A19.5 19.5 0 013.4 10.93a19.79 19.79 0 01-3.07-8.67A2 2 0 012.31 0h3a2 2 0 012 1.72c.127.96.361 1.903.7 2.81a2 2 0 01-.45 2.11L6.09 7.91a16 16 0 006 6l1.27-1.27a2 2 0 012.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0122 16.92z"/></svg>,
    settings: <svg style={s} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth={strokeWidth}><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 010 2.83 2 2 0 01-2.83 0l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 01-4 0v-.09A1.65 1.65 0 009 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 01-2.83-2.83l.06-.06A1.65 1.65 0 004.68 15a1.65 1.65 0 00-1.51-1H3a2 2 0 010-4h.09A1.65 1.65 0 004.6 9a1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 012.83-2.83l.06.06A1.65 1.65 0 009 4.68a1.65 1.65 0 001-1.51V3a2 2 0 014 0v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 012.83 2.83l-.06.06A1.65 1.65 0 0019.4 9a1.65 1.65 0 001.51 1H21a2 2 0 010 4h-.09a1.65 1.65 0 00-1.51 1z"/></svg>,
    pdf: <svg style={s} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth={strokeWidth}><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>,
    whatsapp: <svg style={s} viewBox="0 0 24 24" fill={color}><path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/></svg>,
    sms: <svg style={s} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth={strokeWidth}><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/></svg>,
    bell: <svg style={s} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth={strokeWidth}><path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 01-3.46 0"/></svg>,
    camera: <svg style={s} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth={strokeWidth}><path d="M23 19a2 2 0 01-2 2H3a2 2 0 01-2-2V8a2 2 0 012-2h4l2-3h6l2 3h4a2 2 0 012 2z"/><circle cx="12" cy="13" r="4"/></svg>,
    trash: <svg style={s} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth={strokeWidth}><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14H6L5 6"/><path d="M10 11v6"/><path d="M14 11v6"/><path d="M9 6V4h6v2"/></svg>,
    edit: <svg style={s} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth={strokeWidth}><path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>,
    chevronRight: <svg style={s} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth={strokeWidth}><polyline points="9 18 15 12 9 6"/></svg>,
    user: <svg style={s} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth={strokeWidth}><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>,
    lock: <svg style={s} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth={strokeWidth}><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>,
    globe: <svg style={s} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth={strokeWidth}><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg>,
    cloud: <svg style={s} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth={strokeWidth}><polyline points="16 16 12 12 8 16"/><line x1="12" y1="12" x2="12" y2="21"/><path d="M20.39 18.39A5 5 0 0018 9h-1.26A8 8 0 103 16.3"/></svg>,
    x: <svg style={s} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth={strokeWidth}><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>,
    check: <svg style={s} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth={strokeWidth}><polyline points="20 6 9 13 4 10"/></svg>,
    rupee: <svg style={s} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth={strokeWidth}><line x1="6" y1="3" x2="18" y2="3"/><line x1="6" y1="8" x2="18" y2="8"/><line x1="12" y1="8" x2="6" y2="21"/><line x1="6" y1="14" x2="15" y2="14"/></svg>,
    image: <svg style={s} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth={strokeWidth}><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>,
    warn: <svg style={s} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth={strokeWidth}><path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>,
    staff: <svg style={s} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth={strokeWidth}><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 00-3-3.87"/><path d="M16 3.13a4 4 0 010 7.75"/></svg>,
    owner: <svg style={s} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth={strokeWidth}><path d="M12 2L2 7l10 5 10-5-10-5z"/><path d="M2 17l10 5 10-5"/><path d="M2 12l10 5 10-5"/></svg>,
    logout: <svg style={s} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth={strokeWidth}><path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>,
  };
  return paths[name] || <svg style={s} viewBox="0 0 24 24"/>;
}

// ─── COLORS ──────────────────────────────────────────────────────────────────
const C = {
  primary: "#003886",
  primaryDark: "#002560",
  primaryLight: "#1A4FAA",
  red: "#C0392B",
  redLight: "#FDECEA",
  green: "#16A34A",
  greenLight: "#ECFDF5",
  bg: "#F0F2F5",
  card: "#FFFFFF",
  text: "#1A1C1C",
  textSub: "#5D5F5F",
  textMuted: "#9CA3AF",
  border: "#E2E4E9",
  warn: "#F59E0B",
};

// ─── HELPERS ─────────────────────────────────────────────────────────────────
const { formatDate, getInitials, SOCIETIES, ITEM_RATES } = window.HKData;

function Avatar({ name, size = 40, bg = C.primaryLight }) {
  return (
    <div style={{
      width: size, height: size, borderRadius: "50%", background: bg,
      color: "#fff", display: "flex", alignItems: "center", justifyContent: "center",
      fontWeight: 700, fontSize: size * 0.34, flexShrink: 0, fontFamily: "inherit"
    }}>{getInitials(name)}</div>
  );
}

function Chip({ label, active, onClick }) {
  return (
    <button onClick={onClick} style={{
      padding: "6px 14px", borderRadius: 20, border: active ? "none" : `1px solid ${C.border}`,
      background: active ? C.primary : C.card, color: active ? "#fff" : C.textSub,
      fontSize: 13, fontWeight: active ? 600 : 400, cursor: "pointer", whiteSpace: "nowrap",
      fontFamily: "inherit", transition: "all 0.15s"
    }}>{label}</button>
  );
}

function BottomSheet({ open, onClose, title, children, height = "auto" }) {
  if (!open) return null;
  return (
    <div style={{ position: "absolute", inset: 0, zIndex: 100 }}>
      <div onClick={onClose} style={{ position: "absolute", inset: 0, background: "rgba(0,0,0,0.45)" }} />
      <div style={{
        position: "absolute", bottom: 0, left: 0, right: 0,
        background: C.card, borderRadius: "20px 20px 0 0",
        maxHeight: "88%", overflow: "hidden", display: "flex", flexDirection: "column"
      }}>
        <div style={{ padding: "12px 16px 0", display: "flex", alignItems: "center", justifyContent: "space-between" }}>
          <div style={{ width: 40, height: 4, background: C.border, borderRadius: 2, margin: "0 auto" }} />
        </div>
        {title && <div style={{ padding: "10px 20px 12px", fontWeight: 700, fontSize: 17, color: C.text, borderBottom: `1px solid ${C.border}` }}>{title}</div>}
        <div style={{ overflowY: "auto", flex: 1, WebkitOverflowScrolling: "touch" }}>{children}</div>
      </div>
    </div>
  );
}

function FAB({ color, label, icon, onClick, right = 16 }) {
  return (
    <button onClick={onClick} style={{
      position: "absolute", bottom: 80, right, zIndex: 40,
      background: color, color: "#fff", border: "none", borderRadius: 28,
      padding: "14px 20px", display: "flex", alignItems: "center", gap: 8,
      fontSize: 14, fontWeight: 700, cursor: "pointer", boxShadow: `0 4px 16px ${color}55`,
      fontFamily: "inherit", letterSpacing: 0.3
    }}>
      {icon && <Icon name={icon} size={18} color="#fff" />}
      {label}
    </button>
  );
}

function TextInput({ label, value, onChange, placeholder, type = "text", required }) {
  return (
    <div style={{ marginBottom: 14 }}>
      <label style={{ fontSize: 12, fontWeight: 600, color: C.textSub, letterSpacing: 0.4, textTransform: "uppercase" }}>
        {label}{required && <span style={{ color: C.red }}> *</span>}
      </label>
      <input
        type={type} value={value} onChange={e => onChange(e.target.value)}
        placeholder={placeholder}
        style={{
          display: "block", width: "100%", marginTop: 6, padding: "11px 12px",
          border: `1.5px solid ${C.border}`, borderRadius: 10, fontSize: 15,
          color: C.text, background: "#FAFAFA", fontFamily: "inherit",
          outline: "none", boxSizing: "border-box"
        }}
      />
    </div>
  );
}

// ─── LOGIN SCREEN (Gmail-first) ───────────────────────────────────────────────
function LoginScreen({ onGoogleLogin, onRegister }) {
  const [loading, setLoading] = React.useState(false);
  const [demoRole, setDemoRole] = React.useState(null);

  function handleGoogle(role) {
    setLoading(true);
    setTimeout(() => { setLoading(false); onGoogleLogin(role || "customer"); }, 1200);
  }

  return (
    <div style={{ flex: 1, display: "flex", flexDirection: "column", background: C.primary, minHeight: 0 }}>
      {/* Hero */}
      <div style={{ padding: "52px 24px 28px", textAlign: "center" }}>
        <div style={{ fontSize: 48, marginBottom: 8 }}>🧺</div>
        <div style={{ color: "#fff", fontSize: 26, fontWeight: 900, letterSpacing: -0.5 }}>Hisaab Kitaab</div>
        <div style={{ color: "#B0C6FF", fontSize: 13, marginTop: 6, lineHeight: 1.5 }}>Iron Laundry — Digital Register<br/>Track pickups, payments & dues</div>
      </div>

      <div style={{ flex: 1, background: C.bg, borderRadius: "28px 28px 0 0", padding: "28px 20px 20px", display: "flex", flexDirection: "column" }}>
        <div style={{ fontSize: 14, fontWeight: 700, color: C.textSub, textAlign: "center", marginBottom: 20, textTransform: "uppercase", letterSpacing: 0.6 }}>Sign in to continue</div>

        {/* Google Sign In */}
        <button
          onClick={() => handleGoogle(null)}
          disabled={loading}
          style={{ width: "100%", padding: "14px 16px", background: C.card, border: `1.5px solid ${C.border}`, borderRadius: 14, fontSize: 15, fontWeight: 700, cursor: "pointer", fontFamily: "inherit", display: "flex", alignItems: "center", justifyContent: "center", gap: 12, marginBottom: 12, boxShadow: "0 2px 8px rgba(0,0,0,0.06)" }}
        >
          {loading ? (
            <div style={{ width: 20, height: 20, border: `3px solid ${C.border}`, borderTopColor: C.primary, borderRadius: "50%", animation: "spin 0.8s linear infinite" }} />
          ) : (
            <svg width="20" height="20" viewBox="0 0 48 48"><path fill="#4285F4" d="M47.5 24.6c0-1.6-.1-3.1-.4-4.6H24v8.7h13.2c-.6 3-2.3 5.5-4.9 7.2v6h7.9c4.6-4.3 7.3-10.6 7.3-17.3z"/><path fill="#34A853" d="M24 48c6.5 0 11.9-2.1 15.9-5.8l-7.9-6c-2.1 1.4-4.9 2.3-8 2.3-6.1 0-11.3-4.1-13.2-9.7H2.7v6.2C6.6 42.5 14.8 48 24 48z"/><path fill="#FBBC05" d="M10.8 28.8c-.5-1.4-.7-2.9-.7-4.4s.3-3 .7-4.4v-6.2H2.7C1 17.2 0 20.5 0 24s1 6.8 2.7 9.2l8.1-4.4z"/><path fill="#EA4335" d="M24 9.5c3.4 0 6.5 1.2 8.9 3.5l6.6-6.6C35.9 2.5 30.4 0 24 0 14.8 0 6.6 5.5 2.7 13.6l8.1 4.4C12.7 12.6 17.9 9.5 24 9.5z"/></svg>
          )}
          {loading ? "Signing in…" : "Continue with Google"}
        </button>

        <div style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: 12 }}>
          <div style={{ flex: 1, height: 1, background: C.border }} />
          <span style={{ fontSize: 12, color: C.textMuted }}>or try a demo role</span>
          <div style={{ flex: 1, height: 1, background: C.border }} />
        </div>

        {/* Demo role picker */}
        {[
          { id: "owner", label: "Owner", sub: "Full access — customers, staff & settings", icon: "owner", color: C.primary },
          { id: "staff", label: "Staff", sub: "Add entries based on assigned permissions", icon: "staff", color: "#7C3AED" },
          { id: "customer", label: "Customer", sub: "View your own transaction history only", icon: "user", color: C.green },
        ].map(r => (
          <div key={r.id} onClick={() => setDemoRole(r.id)} style={{ background: C.card, border: `2px solid ${demoRole === r.id ? r.color : C.border}`, borderRadius: 12, padding: "12px 14px", marginBottom: 8, display: "flex", alignItems: "center", gap: 12, cursor: "pointer", transition: "border-color 0.15s" }}>
            <div style={{ width: 38, height: 38, borderRadius: 10, background: demoRole === r.id ? r.color : C.bg, display: "flex", alignItems: "center", justifyContent: "center", transition: "background 0.15s", flexShrink: 0 }}>
              <Icon name={r.icon} size={20} color={demoRole === r.id ? "#fff" : r.color} />
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ fontWeight: 700, fontSize: 14, color: C.text }}>{r.label}</div>
              <div style={{ fontSize: 11, color: C.textSub, marginTop: 1 }}>{r.sub}</div>
            </div>
            {demoRole === r.id && <div style={{ width: 20, height: 20, borderRadius: "50%", background: r.color, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}><Icon name="check" size={12} color="#fff" strokeWidth={3} /></div>}
          </div>
        ))}

        {demoRole && (
          <button onClick={() => handleGoogle(demoRole)} style={{ width: "100%", marginTop: 6, padding: "14px", background: C.primary, color: "#fff", border: "none", borderRadius: 12, fontSize: 15, fontWeight: 700, cursor: "pointer", fontFamily: "inherit" }}>
            Preview as {demoRole.charAt(0).toUpperCase() + demoRole.slice(1)}
          </button>
        )}

        <button onClick={onRegister} style={{ width: "100%", marginTop: 10, padding: "12px", background: "transparent", color: C.primary, border: `1.5px solid ${C.primary}`, borderRadius: 12, fontSize: 14, fontWeight: 700, cursor: "pointer", fontFamily: "inherit" }}>
          New user? Register here
        </button>

        <div style={{ textAlign: "center", marginTop: 14, fontSize: 11, color: C.textMuted }}>
          Shivaswamy Iron & Laundry • Klassik Landmark
        </div>
      </div>
    </div>
  );
}

// ─── HOME SCREEN ─────────────────────────────────────────────────────────────
function HomeScreen({ role, permissions = {}, customers, onCustomer, onAddCustomer, onSettings, onOverdue, onLogout }) {
  const [search, setSearch] = React.useState("");
  const [activeSociety, setActiveSociety] = React.useState("All");

  const filtered = customers.filter(c => {
    const matchSoc = activeSociety === "All" || c.society === activeSociety;
    const q = search.toLowerCase();
    const matchSearch = !q || c.name.toLowerCase().includes(q) || c.flat.toLowerCase().includes(q) || c.society.toLowerCase().includes(q);
    return matchSoc && matchSearch;
  });

  const overdue = customers.filter(c => c.balance > 200).length;
  const totalDue = customers.reduce((s, c) => s + Math.max(0, c.balance), 0);

  const societies = ["All", ...SOCIETIES];

  return (
    <div style={{ flex: 1, display: "flex", flexDirection: "column", background: C.bg, overflow: "hidden" }}>
      {/* Header */}
      <div style={{ background: `linear-gradient(135deg, ${C.primaryDark} 0%, ${C.primaryLight} 100%)`, padding: "14px 16px 16px" }}>
        <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 14 }}>
          <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
            <Avatar name="Shivaswamy" size={38} bg="rgba(255,255,255,0.2)" />
            <div>
              <div style={{ color: "#fff", fontWeight: 700, fontSize: 15 }}>Shivaswamy</div>
              <div style={{ color: "#B0C6FF", fontSize: 11 }}>Iron & Laundry • {role.charAt(0).toUpperCase() + role.slice(1)}</div>
            </div>
          </div>
          <div style={{ display: "flex", gap: 6 }}>
            {overdue > 0 && <div onClick={onOverdue} style={{ background: "#FBBF24", color: "#000", borderRadius: 12, padding: "3px 9px", fontSize: 12, fontWeight: 700, cursor: "pointer" }}>⚠ {overdue}</div>}
            {role === "owner" && <button onClick={onSettings} style={{ background: "rgba(255,255,255,0.15)", border: "none", borderRadius: 8, padding: "7px 8px", cursor: "pointer", color: "#fff" }}><Icon name="settings" size={18} color="#fff" /></button>}
            <button onClick={onLogout} style={{ background: "rgba(255,255,255,0.15)", border: "none", borderRadius: 8, padding: "7px 8px", cursor: "pointer" }}><Icon name="logout" size={18} color="#fff" /></button>
          </div>
        </div>
        {/* Summary card */}
        <div style={{ background: "rgba(255,255,255,0.12)", borderRadius: 12, padding: "12px 14px", display: "flex", justifyContent: "space-between" }}>
          <div>
            <div style={{ color: "#B0C6FF", fontSize: 11 }}>Total Outstanding</div>
            <div style={{ color: "#fff", fontSize: 20, fontWeight: 800 }}>₹{totalDue.toLocaleString("en-IN")}</div>
          </div>
          <div style={{ textAlign: "right" }}>
            <div style={{ color: "#B0C6FF", fontSize: 11 }}>Customers</div>
            <div style={{ color: "#fff", fontSize: 20, fontWeight: 800 }}>{customers.length}</div>
          </div>
        </div>
      </div>

      {/* Search */}
      <div style={{ padding: "12px 16px 8px", background: C.card, borderBottom: `1px solid ${C.border}` }}>
        <div style={{ background: C.bg, borderRadius: 10, display: "flex", alignItems: "center", padding: "8px 12px", gap: 8 }}>
          <Icon name="search" size={17} color={C.textMuted} />
          <input
            value={search} onChange={e => setSearch(e.target.value)}
            placeholder="Search by name, flat or society…"
            style={{ border: "none", background: "transparent", flex: 1, fontSize: 14, color: C.text, outline: "none", fontFamily: "inherit" }}
          />
          {search && <button onClick={() => setSearch("")} style={{ border: "none", background: "none", cursor: "pointer", padding: 0 }}><Icon name="x" size={16} color={C.textMuted} /></button>}
        </div>
        {/* Society tabs */}
        <div style={{ display: "flex", gap: 8, overflowX: "auto", paddingBottom: 4, marginTop: 10, scrollbarWidth: "none" }}>
          {societies.map(s => <Chip key={s} label={s === "All" ? "All Societies" : s} active={activeSociety === s} onClick={() => setActiveSociety(s)} />)}
        </div>
      </div>

      {/* Staff permissions banner */}
      {role === "staff" && (
        <div style={{ background: "#EEF2FF", borderBottom: `1px solid #C7D2FE`, padding: "8px 16px", display: "flex", alignItems: "center", gap: 8 }}>
          <Icon name="staff" size={15} color="#4338CA" />
          <span style={{ fontSize: 11, color: "#4338CA", fontWeight: 600, flex: 1 }}>Staff Mode</span>
          <div style={{ display: "flex", gap: 4, flexWrap: "wrap" }}>
            {permissions.add_customers && <span style={{ fontSize: 9, background: "#C7D2FE", color: "#3730A3", borderRadius: 4, padding: "2px 5px", fontWeight: 700 }}>ADD CUSTOMERS</span>}
            {permissions.send_reminders && <span style={{ fontSize: 9, background: "#C7D2FE", color: "#3730A3", borderRadius: 4, padding: "2px 5px", fontWeight: 700 }}>REMINDERS</span>}
            {permissions.call_customer && <span style={{ fontSize: 9, background: "#C7D2FE", color: "#3730A3", borderRadius: 4, padding: "2px 5px", fontWeight: 700 }}>CALL</span>}
          </div>
        </div>
      )}

      {/* Customer list */}
      <div style={{ flex: 1, overflowY: "auto", padding: "8px 0 72px", WebkitOverflowScrolling: "touch" }}>
        {filtered.length === 0 && (
          <div style={{ textAlign: "center", padding: "48px 24px", color: C.textMuted }}>
            <div style={{ fontSize: 40, marginBottom: 8 }}>🔍</div>
            <div style={{ fontSize: 15, fontWeight: 600 }}>No customers found</div>
            <div style={{ fontSize: 13, marginTop: 4 }}>Try a different search or filter</div>
          </div>
        )}
        {filtered.map((c, i) => <CustomerCard key={c.id} customer={c} onClick={() => onCustomer(c)} delay={i * 30} />)}
      </div>

      {/* FAB */}
      {(role === "owner" || (role === "staff" && permissions.add_customers !== false)) && (
        <FAB color={C.primary} label="Add Customer" icon="plus" onClick={onAddCustomer} />
      )}
    </div>
  );
}

function CustomerCard({ customer: c, onClick, delay }) {
  const isOverdue = c.balance > 200;
  const isPaid = c.balance <= 0;
  return (
    <div onClick={onClick} style={{
      background: C.card, margin: "0 12px 8px",
      borderRadius: 14, padding: "14px 16px",
      display: "flex", alignItems: "center", gap: 12, cursor: "pointer",
      boxShadow: "0 1px 4px rgba(0,0,0,0.06)",
      border: `1px solid ${isOverdue ? "#FBBF2440" : C.border}`,
      animation: `fadeSlide 0.3s ease ${delay}ms both`
    }}>
      <Avatar name={c.name} size={44} bg={isOverdue ? "#C0392B" : C.primaryLight} />
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontWeight: 700, fontSize: 15, color: C.text, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>{c.flat} · {c.name}</div>
        <div style={{ fontSize: 12, color: C.textSub, marginTop: 2 }}>{c.society}</div>
      </div>
      <div style={{ textAlign: "right" }}>
        <div style={{ fontWeight: 800, fontSize: 16, color: isPaid ? C.green : c.balance > 0 ? C.red : C.text }}>
          {isPaid ? "✓ Paid" : `₹${c.balance}`}
        </div>
        {isOverdue && <div style={{ fontSize: 10, background: "#FEF3C7", color: "#92400E", borderRadius: 6, padding: "2px 6px", marginTop: 3, fontWeight: 600 }}>OVERDUE</div>}
        {isPaid && <div style={{ fontSize: 10, background: C.greenLight, color: C.green, borderRadius: 6, padding: "2px 6px", marginTop: 3, fontWeight: 600 }}>SETTLED</div>}
      </div>
    </div>
  );
}

// ─── ADD CUSTOMER SCREEN ──────────────────────────────────────────────────────
function AddCustomerScreen({ onSave, onBack }) {
  const [name, setName] = React.useState("");
  const [flat, setFlat] = React.useState("");
  const [society, setSociety] = React.useState(SOCIETIES[0]);
  const [phone, setPhone] = React.useState("");
  const [err, setErr] = React.useState("");

  function handleSave() {
    if (!name.trim() || !flat.trim() || !phone.trim()) { setErr("Name, flat number and phone are required."); return; }
    onSave({ name: name.trim(), flat: flat.trim(), society, phone: phone.trim() });
  }

  return (
    <div style={{ flex: 1, display: "flex", flexDirection: "column", background: C.bg }}>
      <div style={{ background: `linear-gradient(135deg, ${C.primaryDark}, ${C.primaryLight})`, padding: "14px 16px 18px" }}>
        <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
          <button onClick={onBack} style={{ background: "rgba(255,255,255,0.15)", border: "none", borderRadius: 8, padding: "7px 8px", cursor: "pointer" }}><Icon name="back" size={20} color="#fff" /></button>
          <div style={{ color: "#fff", fontWeight: 700, fontSize: 17 }}>Add New Customer</div>
        </div>
      </div>
      <div style={{ flex: 1, overflowY: "auto", padding: "20px 16px" }}>
        <div style={{ background: C.card, borderRadius: 16, padding: "20px 16px", boxShadow: "0 2px 8px rgba(0,0,0,0.06)" }}>
          <TextInput label="Customer Name" value={name} onChange={setName} placeholder="e.g. Rohan Mahajan" required />
          <TextInput label="Flat Number" value={flat} onChange={setFlat} placeholder="e.g. G-9H, B-204" required />
          <div style={{ marginBottom: 14 }}>
            <label style={{ fontSize: 12, fontWeight: 600, color: C.textSub, letterSpacing: 0.4, textTransform: "uppercase" }}>Society <span style={{ color: C.red }}>*</span></label>
            <select value={society} onChange={e => setSociety(e.target.value)} style={{ display: "block", width: "100%", marginTop: 6, padding: "11px 12px", border: `1.5px solid ${C.border}`, borderRadius: 10, fontSize: 15, color: C.text, background: "#FAFAFA", fontFamily: "inherit", outline: "none" }}>
              {SOCIETIES.map(s => <option key={s} value={s}>{s}</option>)}
            </select>
          </div>
          <TextInput label="Phone Number" value={phone} onChange={setPhone} placeholder="e.g. 9876543210" type="tel" required />
          {err && <div style={{ color: C.red, fontSize: 13, marginBottom: 10, background: C.redLight, padding: "8px 12px", borderRadius: 8 }}>{err}</div>}
          <button onClick={handleSave} style={{ width: "100%", padding: "14px", background: C.primary, color: "#fff", border: "none", borderRadius: 12, fontSize: 16, fontWeight: 700, cursor: "pointer", fontFamily: "inherit", marginTop: 4 }}>
            Save Customer
          </button>
        </div>
      </div>
    </div>
  );
}

// ─── CUSTOMER DETAIL SCREEN ───────────────────────────────────────────────────
function CustomerDetailScreen({ customer, transactions, role, permissions = {}, onBack, onAddGave, onAddGot, onReport, onUpdateCustomer, onDeleteCustomer }) {
  const [showSettings, setShowSettings] = React.useState(false);
  const [showReminder, setShowReminder] = React.useState(false);
  const [editName, setEditName] = React.useState(customer.name);
  const [editPhone, setEditPhone] = React.useState(customer.phone);

  const totalGave = transactions.filter(t => t.type === "gave").reduce((s, t) => s + t.amount, 0);
  const totalGot = transactions.filter(t => t.type === "got").reduce((s, t) => s + t.amount, 0);
  const balance = totalGave - totalGot;

  return (
    <div style={{ flex: 1, display: "flex", flexDirection: "column", background: C.bg, overflow: "hidden" }}>
      {/* Header */}
      <div style={{ background: `linear-gradient(135deg, ${C.primaryDark}, ${C.primaryLight})`, padding: "12px 16px 16px" }}>
        <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 12 }}>
          <button onClick={onBack} style={{ background: "rgba(255,255,255,0.15)", border: "none", borderRadius: 8, padding: "7px 8px", cursor: "pointer" }}><Icon name="back" size={20} color="#fff" /></button>
          <div style={{ display: "flex", gap: 8 }}>
            {customer.phone && <a href={`tel:${customer.phone}`} style={{ background: "rgba(255,255,255,0.15)", border: "none", borderRadius: 8, padding: "7px 8px", cursor: "pointer", display: "flex", alignItems: "center", textDecoration: "none" }}><Icon name="phone" size={18} color="#fff" /></a>}
            {(role === "owner" || role === "staff") && <button onClick={() => setShowSettings(true)} style={{ background: "rgba(255,255,255,0.15)", border: "none", borderRadius: 8, padding: "7px 8px", cursor: "pointer" }}><Icon name="settings" size={18} color="#fff" /></button>}
          </div>
        </div>
        <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
          <Avatar name={customer.name} size={48} bg="rgba(255,255,255,0.2)" />
          <div>
            <div style={{ color: "#fff", fontWeight: 800, fontSize: 17 }}>{customer.flat} · {customer.name}</div>
            <div style={{ color: "#B0C6FF", fontSize: 12, marginTop: 2 }}>{customer.society} {customer.phone && `• ${customer.phone}`}</div>
          </div>
        </div>
        {/* Balance card */}
        <div style={{ marginTop: 14, background: "rgba(255,255,255,0.12)", borderRadius: 12, padding: "12px 14px" }}>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
            <div>
              <div style={{ color: "#B0C6FF", fontSize: 11 }}>You Will Get</div>
              <div style={{ color: balance > 0 ? "#FBBF24" : "#6EE7B7", fontSize: 22, fontWeight: 800 }}>₹{Math.abs(balance)}</div>
            </div>
            <div style={{ textAlign: "right", fontSize: 12, color: "#B0C6FF" }}>
              <div>Gave: <span style={{ color: "#FCA5A5" }}>₹{totalGave}</span></div>
              <div>Got: <span style={{ color: "#6EE7B7" }}>₹{totalGot}</span></div>
            </div>
          </div>
        </div>
        {/* Quick actions — filtered by permissions */}
        <div style={{ display: "flex", gap: 10, marginTop: 12, justifyContent: "center" }}>
          {[
            { icon: "pdf", label: "Report", action: onReport, perm: role === "owner" || permissions.view_invoices },
            { icon: "bell", label: "Reminder", action: () => setShowReminder(true), perm: role === "owner" || permissions.send_reminders },
            { icon: "whatsapp", label: "WhatsApp", action: () => {}, perm: role === "owner" || permissions.whatsapp },
            { icon: "sms", label: "SMS", action: () => {}, perm: role === "owner" || permissions.sms },
          ].filter(a => a.perm).map(a => (
            <button key={a.label} onClick={a.action} style={{ flex: 1, background: "rgba(255,255,255,0.12)", border: "none", borderRadius: 10, padding: "10px 4px", color: "#fff", cursor: "pointer", display: "flex", flexDirection: "column", alignItems: "center", gap: 4 }}>
              <Icon name={a.icon} size={20} color="#fff" />
              <span style={{ fontSize: 10, fontWeight: 600 }}>{a.label}</span>
            </button>
          ))}
        </div>
      </div>

      {/* Transactions */}
      <div style={{ flex: 1, overflowY: "auto", padding: "8px 0 80px", WebkitOverflowScrolling: "touch" }}>
        {/* Table header */}
        <div style={{ display: "grid", gridTemplateColumns: "1fr 90px 90px", padding: "8px 16px", fontSize: 11, fontWeight: 700, color: C.textSub, letterSpacing: 0.5, textTransform: "uppercase", borderBottom: `1px solid ${C.border}`, background: C.card, marginBottom: 4 }}>
          <span>Entries</span><span style={{ textAlign: "center" }}>You Gave</span><span style={{ textAlign: "center" }}>You Got</span>
        </div>
        {transactions.map((t, i) => <TransactionRow key={t.id} tx={t} />)}
        {transactions.length === 0 && (
          <div style={{ textAlign: "center", padding: "48px 24px", color: C.textMuted }}>
            <div style={{ fontSize: 36, marginBottom: 8 }}>📋</div>
            <div style={{ fontWeight: 600 }}>No transactions yet</div>
            <div style={{ fontSize: 13, marginTop: 4 }}>Tap "You Gave" to log the first entry</div>
          </div>
        )}
      </div>

      {/* FABs */}
      {(role === "owner" || role === "staff") && (
        <>
          <button onClick={onAddGave} style={{
            position: "absolute", bottom: 80, left: 16, zIndex: 40,
            background: C.red, color: "#fff", border: "none", borderRadius: 28,
            padding: "14px 20px", fontSize: 14, fontWeight: 700, cursor: "pointer",
            boxShadow: `0 4px 16px ${C.red}55`, fontFamily: "inherit", display: "flex", alignItems: "center", gap: 6
          }}>
            <Icon name="rupee" size={16} color="#fff" /> YOU GAVE
          </button>
          <button onClick={onAddGot} style={{
            position: "absolute", bottom: 80, right: 16, zIndex: 40,
            background: C.green, color: "#fff", border: "none", borderRadius: 28,
            padding: "14px 20px", fontSize: 14, fontWeight: 700, cursor: "pointer",
            boxShadow: `0 4px 16px ${C.green}55`, fontFamily: "inherit", display: "flex", alignItems: "center", gap: 6
          }}>
            <Icon name="rupee" size={16} color="#fff" /> YOU GOT
          </button>
        </>
      )}

      {/* Settings sheet */}
      <BottomSheet open={showSettings} onClose={() => setShowSettings(false)} title="Customer Settings">
        <div style={{ padding: "16px 20px" }}>
          <TextInput label="Customer Name" value={editName} onChange={setEditName} />
          <TextInput label="Phone Number" value={editPhone} onChange={setEditPhone} type="tel" />
          <button onClick={() => { onUpdateCustomer({ ...customer, name: editName, phone: editPhone }); setShowSettings(false); }} style={{ width: "100%", padding: "13px", background: C.primary, color: "#fff", border: "none", borderRadius: 12, fontSize: 15, fontWeight: 700, cursor: "pointer", fontFamily: "inherit", marginBottom: 10 }}>Save Changes</button>
          <button onClick={() => { onDeleteCustomer(customer.id); setShowSettings(false); }} style={{ width: "100%", padding: "13px", background: C.redLight, color: C.red, border: `1px solid ${C.red}`, borderRadius: 12, fontSize: 15, fontWeight: 700, cursor: "pointer", fontFamily: "inherit" }}>Remove Customer</button>
        </div>
      </BottomSheet>

      {/* Reminder sheet */}
      <BottomSheet open={showReminder} onClose={() => setShowReminder(false)} title="Send Reminder">
        <div style={{ padding: "16px 20px" }}>
          <div style={{ background: C.bg, borderRadius: 12, padding: "14px", marginBottom: 14, fontSize: 13, color: C.text, lineHeight: 1.7 }}>
            <div style={{ fontWeight: 600, marginBottom: 6 }}>Preview Message</div>
            Namaste {customer.name} ji, aapka Hisaab Kitaab balance ₹{balance} ho gaya hai. Please jaldi payment karein.
          </div>
          <div style={{ display: "flex", gap: 10 }}>
            <button style={{ flex: 1, padding: "13px", background: "#25D366", color: "#fff", border: "none", borderRadius: 12, fontSize: 14, fontWeight: 700, cursor: "pointer", fontFamily: "inherit", display: "flex", alignItems: "center", justifyContent: "center", gap: 6 }}>
              <Icon name="whatsapp" size={16} color="#fff" /> WhatsApp
            </button>
            <button style={{ flex: 1, padding: "13px", background: C.primary, color: "#fff", border: "none", borderRadius: 12, fontSize: 14, fontWeight: 700, cursor: "pointer", fontFamily: "inherit", display: "flex", alignItems: "center", justifyContent: "center", gap: 6 }}>
              <Icon name="sms" size={16} color="#fff" /> SMS
            </button>
          </div>
        </div>
      </BottomSheet>
    </div>
  );
}

function TransactionRow({ tx }) {
  const isGave = tx.type === "gave";
  return (
    <div style={{
      display: "grid", gridTemplateColumns: "1fr 90px 90px",
      padding: "12px 16px", background: C.card, marginBottom: 2,
      borderLeft: `3px solid ${isGave ? C.red : C.green}`
    }}>
      <div>
        <div style={{ fontSize: 12, fontWeight: 600, color: C.text }}>{formatDate(tx.date)}</div>
        <div style={{ fontSize: 11, color: C.textSub, marginTop: 2 }}>Bal. ₹{Math.abs(tx.balance)}</div>
        {tx.desc && <div style={{ fontSize: 11, color: C.textMuted, marginTop: 1 }}>{tx.desc}</div>}
      </div>
      <div style={{ display: "flex", alignItems: "center", justifyContent: "center" }}>
        {isGave ? <span style={{ fontWeight: 800, fontSize: 16, color: C.red }}>₹{tx.amount}</span> : <span style={{ color: C.textMuted, fontSize: 14 }}>–</span>}
      </div>
      <div style={{ display: "flex", alignItems: "center", justifyContent: "center" }}>
        {!isGave ? <span style={{ fontWeight: 800, fontSize: 16, color: C.green }}>₹{tx.amount}</span> : <span style={{ color: C.textMuted, fontSize: 14 }}>–</span>}
      </div>
    </div>
  );
}

// ─── ADD ENTRY SCREENS ────────────────────────────────────────────────────────
function AddGaveScreen({ customer, onSave, onBack }) {
  const today = new Date().toISOString().split("T")[0];
  const [amount, setAmount] = React.useState("");
  const [desc, setDesc] = React.useState("");
  const [date, setDate] = React.useState(today);
  const [photos, setPhotos] = React.useState([]);
  const amt = Number(amount) || 0;

  return (
    <div style={{ flex: 1, display: "flex", flexDirection: "column", background: C.bg, overflow: "hidden" }}>
      {/* Header */}
      <div style={{ background: `linear-gradient(135deg, ${C.primaryDark}, ${C.red})`, padding: "12px 16px 16px" }}>
        <div style={{ display: "flex", alignItems: "center", gap: 12, marginBottom: 10 }}>
          <button onClick={onBack} style={{ background: "rgba(255,255,255,0.15)", border: "none", borderRadius: 8, padding: "7px 8px", cursor: "pointer" }}><Icon name="back" size={20} color="#fff" /></button>
          <div>
            <div style={{ color: "#fff", fontWeight: 700, fontSize: 16 }}>Pickup Entry</div>
            <div style={{ color: "#FFD0CC", fontSize: 12 }}>{customer.flat} · {customer.name}</div>
          </div>
        </div>
        <div style={{ background: "rgba(255,255,255,0.12)", borderRadius: 10, padding: "10px 14px", display: "flex", justifyContent: "space-between", alignItems: "center" }}>
          <span style={{ color: "#FFD0CC", fontSize: 13 }}>Amount to charge</span>
          <span style={{ color: "#fff", fontSize: 22, fontWeight: 800 }}>₹{amt || "—"}</span>
        </div>
      </div>

      <div style={{ flex: 1, overflowY: "auto", padding: "14px 16px 20px" }}>
        {/* Amount */}
        <div style={{ background: C.card, borderRadius: 16, padding: "16px", marginBottom: 12, boxShadow: "0 1px 4px rgba(0,0,0,0.06)" }}>
          <label style={{ fontSize: 12, fontWeight: 600, color: C.textSub, letterSpacing: 0.4, textTransform: "uppercase" }}>
            Total Laundry Amount <span style={{ color: C.red }}>*</span>
          </label>
          <div style={{ display: "flex", alignItems: "center", marginTop: 8, border: `2px solid ${amt > 0 ? C.red : C.border}`, borderRadius: 12, overflow: "hidden", transition: "border-color 0.2s" }}>
            <span style={{ padding: "12px 14px", background: C.redLight, fontWeight: 700, fontSize: 18, color: C.red }}>₹</span>
            <input
              type="number" value={amount} onChange={e => setAmount(e.target.value)}
              placeholder="0" autoFocus
              style={{ flex: 1, padding: "12px", border: "none", fontSize: 28, fontWeight: 800, outline: "none", fontFamily: "inherit", color: C.text }}
            />
          </div>
          <div style={{ fontSize: 11, color: C.textMuted, marginTop: 6 }}>Enter the total amount for this pickup batch</div>
        </div>

        {/* Description */}
        <div style={{ background: C.card, borderRadius: 16, padding: "16px", marginBottom: 12, boxShadow: "0 1px 4px rgba(0,0,0,0.06)" }}>
          <label style={{ fontSize: 12, fontWeight: 600, color: C.textSub, letterSpacing: 0.4, textTransform: "uppercase" }}>Laundry Description</label>
          <textarea
            value={desc} onChange={e => setDesc(e.target.value)}
            placeholder="e.g. 7 pants, 2 shirts, 1 saree…" rows={3}
            style={{ display: "block", width: "100%", marginTop: 8, padding: "10px 12px", border: `1.5px solid ${C.border}`, borderRadius: 10, fontSize: 14, fontFamily: "inherit", resize: "none", outline: "none", boxSizing: "border-box", lineHeight: 1.5 }}
          />
        </div>

        {/* Date picker */}
        <div style={{ background: C.card, borderRadius: 16, padding: "16px", marginBottom: 12, boxShadow: "0 1px 4px rgba(0,0,0,0.06)" }}>
          <label style={{ fontSize: 12, fontWeight: 600, color: C.textSub, letterSpacing: 0.4, textTransform: "uppercase" }}>Pickup Date</label>
          <div style={{ display: "flex", alignItems: "center", gap: 10, marginTop: 8 }}>
            <input
              type="date" value={date} onChange={e => setDate(e.target.value)}
              max={today}
              style={{ flex: 1, padding: "11px 12px", border: `1.5px solid ${C.border}`, borderRadius: 10, fontSize: 15, fontFamily: "inherit", outline: "none", color: C.text, background: "#FAFAFA" }}
            />
            {date !== today && (
              <div style={{ background: "#FEF3C7", color: "#92400E", borderRadius: 8, padding: "6px 10px", fontSize: 11, fontWeight: 600 }}>Past entry</div>
            )}
          </div>
          <div style={{ fontSize: 11, color: C.textMuted, marginTop: 6 }}>Default is today. Change for late/backdated entries.</div>
        </div>

        {/* Photo upload */}
        <div style={{ background: C.card, borderRadius: 16, padding: "16px", marginBottom: 16, boxShadow: "0 1px 4px rgba(0,0,0,0.06)" }}>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 12 }}>
            <div style={{ fontWeight: 700, fontSize: 13, color: C.textSub, textTransform: "uppercase", letterSpacing: 0.5 }}>Bag Photos</div>
            <div style={{ fontSize: 11, color: C.textMuted }}>Max 2 photos</div>
          </div>
          <div style={{ display: "flex", gap: 10 }}>
            {photos.map((p, i) => (
              <div key={i} style={{ position: "relative", width: 90, height: 90, borderRadius: 12, overflow: "hidden", border: `1.5px solid ${C.border}` }}>
                <img src={p} style={{ width: "100%", height: "100%", objectFit: "cover" }} alt="" />
                <button onClick={() => setPhotos(ps => ps.filter((_, j) => j !== i))} style={{ position: "absolute", top: 3, right: 3, width: 22, height: 22, borderRadius: "50%", background: "rgba(0,0,0,0.65)", border: "none", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center" }}>
                  <Icon name="x" size={12} color="#fff" />
                </button>
              </div>
            ))}
            {photos.length < 2 && (
              <label style={{ width: 90, height: 90, borderRadius: 12, border: `2px dashed ${C.border}`, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", cursor: "pointer", gap: 5, background: C.bg }}>
                <Icon name="camera" size={26} color={C.textMuted} />
                <span style={{ fontSize: 10, color: C.textMuted, fontWeight: 600 }}>Add Photo</span>
                <input type="file" accept="image/*" style={{ display: "none" }} onChange={e => {
                  const f = e.target.files[0]; if (!f) return;
                  const url = URL.createObjectURL(f); setPhotos(prev => [...prev, url]);
                }} />
              </label>
            )}
          </div>
        </div>

        <button
          onClick={() => amt > 0 && onSave({ type: "gave", amount: amt, desc: desc || "Laundry pickup", date: date + "T" + new Date().toTimeString().slice(0,8), photos })}
          disabled={amt === 0}
          style={{ width: "100%", padding: "15px", background: amt > 0 ? C.red : C.border, color: "#fff", border: "none", borderRadius: 14, fontSize: 16, fontWeight: 700, cursor: amt > 0 ? "pointer" : "not-allowed", fontFamily: "inherit" }}
        >
          Save Pickup — ₹{amt || 0}
        </button>
      </div>
    </div>
  );
}

function AddGotScreen({ customer, balance, onSave, onBack }) {
  const [amount, setAmount] = React.useState("");
  const [mode, setMode] = React.useState("Cash");
  const [note, setNote] = React.useState("");
  const quick = [50, 100, 200, 500, balance].filter((v, i, a) => v > 0 && a.indexOf(v) === i);

  return (
    <div style={{ flex: 1, display: "flex", flexDirection: "column", background: C.bg, overflow: "hidden" }}>
      <div style={{ background: `linear-gradient(135deg, ${C.primaryDark}, ${C.green})`, padding: "12px 16px 16px" }}>
        <div style={{ display: "flex", alignItems: "center", gap: 12, marginBottom: 10 }}>
          <button onClick={onBack} style={{ background: "rgba(255,255,255,0.15)", border: "none", borderRadius: 8, padding: "7px 8px", cursor: "pointer" }}><Icon name="back" size={20} color="#fff" /></button>
          <div style={{ color: "#fff", fontWeight: 700, fontSize: 17 }}>You Got — {customer.flat} · {customer.name}</div>
        </div>
        <div style={{ background: "rgba(255,255,255,0.12)", borderRadius: 10, padding: "10px 14px", fontSize: 13, color: "#A7F3D0" }}>
          Outstanding balance: <span style={{ color: "#fff", fontWeight: 800 }}>₹{balance}</span>
        </div>
      </div>
      <div style={{ flex: 1, overflowY: "auto", padding: "20px 16px" }}>
        <div style={{ background: C.card, borderRadius: 16, padding: "20px 16px", boxShadow: "0 1px 4px rgba(0,0,0,0.06)", marginBottom: 12 }}>
          <label style={{ fontSize: 12, fontWeight: 600, color: C.textSub, letterSpacing: 0.4, textTransform: "uppercase" }}>Amount Received <span style={{ color: C.red }}>*</span></label>
          <div style={{ display: "flex", alignItems: "center", marginTop: 8, border: `2px solid ${C.green}`, borderRadius: 12, overflow: "hidden" }}>
            <span style={{ padding: "12px 14px", background: C.greenLight, fontWeight: 700, fontSize: 18, color: C.green }}>₹</span>
            <input type="number" value={amount} onChange={e => setAmount(e.target.value)} placeholder="0" style={{ flex: 1, padding: "12px", border: "none", fontSize: 24, fontWeight: 800, outline: "none", fontFamily: "inherit", color: C.text }} />
          </div>
          {/* Quick chips */}
          <div style={{ display: "flex", gap: 8, marginTop: 12, flexWrap: "wrap" }}>
            {quick.map(v => (
              <button key={v} onClick={() => setAmount(String(v))} style={{ padding: "7px 14px", borderRadius: 20, border: `1.5px solid ${amount == v ? C.green : C.border}`, background: amount == v ? C.greenLight : C.bg, color: amount == v ? C.green : C.text, fontSize: 13, fontWeight: 600, cursor: "pointer", fontFamily: "inherit" }}>
                {v === balance ? `₹${v} (Full)` : `₹${v}`}
              </button>
            ))}
          </div>
        </div>

        {/* Payment mode */}
        <div style={{ background: C.card, borderRadius: 16, padding: "16px", marginBottom: 12, boxShadow: "0 1px 4px rgba(0,0,0,0.06)" }}>
          <div style={{ fontSize: 12, fontWeight: 600, color: C.textSub, marginBottom: 10, textTransform: "uppercase", letterSpacing: 0.4 }}>Payment Mode</div>
          <div style={{ display: "flex", gap: 8 }}>
            {["Cash", "Online"].map(m => (
              <button key={m} onClick={() => setMode(m)} style={{ flex: 1, padding: "10px", borderRadius: 10, border: `1.5px solid ${mode === m ? C.green : C.border}`, background: mode === m ? C.greenLight : C.bg, color: mode === m ? C.green : C.text, fontSize: 14, fontWeight: 600, cursor: "pointer", fontFamily: "inherit" }}>{m}</button>
            ))}
          </div>
        </div>

        <TextInput label="Note (optional)" value={note} onChange={setNote} placeholder="e.g. paid via PhonePe" />

        <button
          onClick={() => amount > 0 && onSave({ type: "got", amount: Number(amount), desc: note || mode })}
          disabled={!amount || Number(amount) <= 0}
          style={{ width: "100%", padding: "15px", background: amount > 0 ? C.green : C.border, color: "#fff", border: "none", borderRadius: 14, fontSize: 16, fontWeight: 700, cursor: amount > 0 ? "pointer" : "not-allowed", fontFamily: "inherit" }}>
          Save — ₹{amount || 0} Received
        </button>
      </div>
    </div>
  );
}

// ─── SETTINGS SCREEN ─────────────────────────────────────────────────────────
function SettingsScreen({ onBack, role, onStaffSettings }) {
  const [appLock, setAppLock] = React.useState(false);
  const sections = [
    { title: "Settings", icon: "settings", color: C.primary, items: [
      { label: "SMS Settings", icon: "sms" },
      { label: "Payment Settings", icon: "rupee" },
      { label: "Item Pricing", icon: "edit" },
      { label: "Alert Threshold", icon: "warn" },
      { label: "Recycle Bin", icon: "trash" },
      { label: "App Lock", icon: "lock", toggle: true, val: appLock, onToggle: () => setAppLock(v => !v) },
      { label: "Language", icon: "globe" },
      { label: "Backup Information", icon: "cloud" },
      ...(role === "owner" ? [{ label: "Staff Management", icon: "staff", action: onStaffSettings }, { label: "Societies", icon: "globe" }] : []),
    ]},
    { title: "Help & Support", icon: "bell", color: C.primary, items: [
      { label: "Call Support", icon: "phone" },
      { label: "FAQ", icon: "pdf" },
    ]},
  ];
  return (
    <div style={{ flex: 1, display: "flex", flexDirection: "column", background: C.bg, overflow: "hidden" }}>
      <div style={{ background: `linear-gradient(135deg, ${C.primaryDark}, ${C.primaryLight})`, padding: "12px 16px 18px" }}>
        <div style={{ display: "flex", alignItems: "center", gap: 12, marginBottom: 14 }}>
          <button onClick={onBack} style={{ background: "rgba(255,255,255,0.15)", border: "none", borderRadius: 8, padding: "7px 8px", cursor: "pointer" }}><Icon name="back" size={20} color="#fff" /></button>
          <div style={{ color: "#fff", fontWeight: 700, fontSize: 17 }}>Settings</div>
        </div>
        <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
          <Avatar name="Shivaswamy" size={52} bg="rgba(255,255,255,0.2)" />
          <div>
            <div style={{ color: "#fff", fontWeight: 800, fontSize: 16 }}>Shivaswamy</div>
            <div style={{ color: "#B0C6FF", fontSize: 12 }}>Iron & Laundry • {role.charAt(0).toUpperCase() + role.slice(1)}</div>
            <div style={{ color: "#B0C6FF", fontSize: 11, marginTop: 2 }}>UPI: shivaswamy@upi</div>
          </div>
        </div>
      </div>
      <div style={{ flex: 1, overflowY: "auto", padding: "12px 12px 24px" }}>
        {sections.map(sec => (
          <div key={sec.title} style={{ marginBottom: 16 }}>
            <div style={{ display: "flex", alignItems: "center", gap: 8, padding: "6px 4px 10px", color: C.primary, fontWeight: 700, fontSize: 15 }}>
              <Icon name={sec.icon} size={18} color={C.primary} /> {sec.title}
            </div>
            <div style={{ background: C.card, borderRadius: 16, overflow: "hidden", boxShadow: "0 1px 4px rgba(0,0,0,0.06)" }}>
              {sec.items.map((item, i) => (
                <div key={item.label} onClick={item.action || undefined} style={{ display: "flex", alignItems: "center", padding: "14px 16px", borderBottom: i < sec.items.length - 1 ? `1px solid ${C.border}` : "none", cursor: item.toggle ? "default" : "pointer" }}>
                  <div style={{ width: 34, height: 34, borderRadius: 9, background: C.bg, display: "flex", alignItems: "center", justifyContent: "center", marginRight: 12 }}>
                    <Icon name={item.icon} size={18} color={C.primary} />
                  </div>
                  <span style={{ flex: 1, fontSize: 15, color: C.text }}>{item.label}</span>
                  {item.toggle ? (
                    <div onClick={item.onToggle} style={{ width: 44, height: 24, borderRadius: 12, background: item.val ? C.primary : C.border, position: "relative", cursor: "pointer", transition: "background 0.2s" }}>
                      <div style={{ position: "absolute", top: 2, left: item.val ? 22 : 2, width: 20, height: 20, borderRadius: "50%", background: "#fff", transition: "left 0.2s", boxShadow: "0 1px 3px rgba(0,0,0,0.2)" }} />
                    </div>
                  ) : <Icon name="chevronRight" size={18} color={C.textMuted} />}
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

// ─── EXPORTS ─────────────────────────────────────────────────────────────────
Object.assign(window, {
  LoginScreen, HomeScreen, AddCustomerScreen,
  CustomerDetailScreen, AddGaveScreen, AddGotScreen, SettingsScreen,
  Icon, Avatar, C, TextInput, BottomSheet
});
