
// Pull shared components from window (set by hk-screens.jsx)
const { Icon, Avatar, C, TextInput, BottomSheet } = window;
const { SOCIETIES } = window.HKData;

// ─── REGISTRATION SCREEN ─────────────────────────────────────────────────────
function RegistrationScreen({ onRegister, onBack }) {
  const [name, setName] = React.useState("");
  const [phone, setPhone] = React.useState("");
  const [email, setEmail] = React.useState("");
  const [society, setSociety] = React.useState(SOCIETIES[0]);
  const [flat, setFlat] = React.useState("");
  const [err, setErr] = React.useState("");

  function handleSubmit() {
    if (!name.trim() || !phone.trim() || !email.trim() || !flat.trim()) {
      setErr("All fields are required."); return;
    }
    if (!/\S+@\S+\.\S+/.test(email)) { setErr("Enter a valid email address."); return; }
    if (!/^\d{10}$/.test(phone)) { setErr("Enter a valid 10-digit phone number."); return; }
    onRegister({ name, phone, email, society, flat, role: "customer" });
  }

  return (
    <div style={{ flex: 1, display: "flex", flexDirection: "column", background: C.bg }}>
      {/* Header */}
      <div style={{ background: `linear-gradient(135deg, ${C.primaryDark}, ${C.primaryLight})`, padding: "14px 16px 20px" }}>
        <div style={{ display: "flex", alignItems: "center", gap: 12, marginBottom: 12 }}>
          <button onClick={onBack} style={{ background: "rgba(255,255,255,0.15)", border: "none", borderRadius: 8, padding: "7px 8px", cursor: "pointer" }}>
            <Icon name="back" size={20} color="#fff" />
          </button>
          <div>
            <div style={{ color: "#fff", fontWeight: 800, fontSize: 18 }}>Create Account</div>
            <div style={{ color: "#B0C6FF", fontSize: 12 }}>Register to view your laundry history</div>
          </div>
        </div>
      </div>

      <div style={{ flex: 1, overflowY: "auto", padding: "20px 16px" }}>
        <div style={{ background: C.card, borderRadius: 16, padding: "20px 16px", boxShadow: "0 2px 8px rgba(0,0,0,0.06)", marginBottom: 16 }}>
          <div style={{ fontWeight: 700, fontSize: 13, color: C.textSub, textTransform: "uppercase", letterSpacing: 0.5, marginBottom: 16 }}>Personal Details</div>
          <TextInput label="Full Name" value={name} onChange={setName} placeholder="e.g. Rohan Mahajan" required />
          <TextInput label="Phone Number" value={phone} onChange={setPhone} placeholder="10-digit mobile number" type="tel" required />
          <TextInput label="Email Address" value={email} onChange={setEmail} placeholder="your@email.com" type="email" required />
        </div>

        <div style={{ background: C.card, borderRadius: 16, padding: "20px 16px", boxShadow: "0 2px 8px rgba(0,0,0,0.06)", marginBottom: 16 }}>
          <div style={{ fontWeight: 700, fontSize: 13, color: C.textSub, textTransform: "uppercase", letterSpacing: 0.5, marginBottom: 16 }}>Residence Details</div>
          <div style={{ marginBottom: 14 }}>
            <label style={{ fontSize: 12, fontWeight: 600, color: C.textSub, letterSpacing: 0.4, textTransform: "uppercase" }}>
              Society <span style={{ color: C.red }}>*</span>
            </label>
            <select value={society} onChange={e => setSociety(e.target.value)} style={{ display: "block", width: "100%", marginTop: 6, padding: "11px 12px", border: `1.5px solid ${C.border}`, borderRadius: 10, fontSize: 15, color: C.text, background: "#FAFAFA", fontFamily: "inherit", outline: "none" }}>
              {SOCIETIES.map(s => <option key={s} value={s}>{s}</option>)}
            </select>
          </div>
          <TextInput label="Flat Number" value={flat} onChange={setFlat} placeholder="e.g. G-9H, B-204" required />
        </div>

        {err && (
          <div style={{ color: C.red, fontSize: 13, marginBottom: 14, background: C.redLight, padding: "10px 14px", borderRadius: 10, fontWeight: 600 }}>
            ⚠ {err}
          </div>
        )}

        {/* Google register */}
        <button onClick={handleSubmit} style={{ width: "100%", padding: "15px", background: C.primary, color: "#fff", border: "none", borderRadius: 14, fontSize: 15, fontWeight: 700, cursor: "pointer", fontFamily: "inherit", marginBottom: 10, display: "flex", alignItems: "center", justifyContent: "center", gap: 10 }}>
          <svg width="18" height="18" viewBox="0 0 48 48"><path fill="#fff" d="M47.5 24.6c0-1.6-.1-3.1-.4-4.6H24v8.7h13.2c-.6 3-2.3 5.5-4.9 7.2v6h7.9c4.6-4.3 7.3-10.6 7.3-17.3z"/><path fill="#fff" d="M24 48c6.5 0 11.9-2.1 15.9-5.8l-7.9-6c-2.1 1.4-4.9 2.3-8 2.3-6.1 0-11.3-4.1-13.2-9.7H2.7v6.2C6.6 42.5 14.8 48 24 48z"/><path fill="#fff" d="M10.8 28.8c-.5-1.4-.7-2.9-.7-4.4s.3-3 .7-4.4v-6.2H2.7C1 17.2 0 20.5 0 24s1 6.8 2.7 9.2l8.1-4.4z"/><path fill="#fff" d="M24 9.5c3.4 0 6.5 1.2 8.9 3.5l6.6-6.6C35.9 2.5 30.4 0 24 0 14.8 0 6.6 5.5 2.7 13.6l8.1 4.4C12.7 12.6 17.9 9.5 24 9.5z"/></svg>
          Register with Google
        </button>
        <div style={{ fontSize: 11, color: C.textMuted, textAlign: "center", lineHeight: 1.6 }}>
          By registering, you'll be linked to your laundry account at {society}. Your vendor will verify and activate your account.
        </div>
      </div>
    </div>
  );
}

// ─── CUSTOMER HOME (read-only) ────────────────────────────────────────────────
function CustomerHomeScreen({ currentUser, transactions, onLogout }) {
  const txList = transactions[currentUser.id] || [];
  const totalGave = txList.filter(t => t.type === "gave").reduce((s, t) => s + t.amount, 0);
  const totalGot = txList.filter(t => t.type === "got").reduce((s, t) => s + t.amount, 0);
  const balance = totalGave - totalGot;
  const { formatDate } = window.HKData;

  return (
    <div style={{ flex: 1, display: "flex", flexDirection: "column", background: C.bg, overflow: "hidden" }}>
      {/* Header */}
      <div style={{ background: `linear-gradient(135deg, ${C.primaryDark}, ${C.primaryLight})`, padding: "14px 16px 16px" }}>
        <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 14 }}>
          <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
            <Avatar name={currentUser.name} size={38} bg="rgba(255,255,255,0.2)" />
            <div>
              <div style={{ color: "#fff", fontWeight: 700, fontSize: 15 }}>{currentUser.name}</div>
              <div style={{ color: "#B0C6FF", fontSize: 11 }}>{currentUser.flat} · {currentUser.society}</div>
            </div>
          </div>
          <button onClick={onLogout} style={{ background: "rgba(255,255,255,0.15)", border: "none", borderRadius: 8, padding: "7px 8px", cursor: "pointer" }}>
            <Icon name="logout" size={18} color="#fff" />
          </button>
        </div>
        {/* Balance summary */}
        <div style={{ background: "rgba(255,255,255,0.12)", borderRadius: 12, padding: "14px 16px" }}>
          <div style={{ color: "#B0C6FF", fontSize: 11, marginBottom: 4 }}>Your Outstanding Balance</div>
          <div style={{ color: balance > 0 ? "#FBBF24" : "#6EE7B7", fontSize: 26, fontWeight: 900 }}>₹{Math.abs(balance)}</div>
          <div style={{ display: "flex", gap: 16, marginTop: 8 }}>
            <div style={{ fontSize: 12 }}>
              <span style={{ color: "#FCA5A5" }}>Laundry: ₹{totalGave}</span>
            </div>
            <div style={{ fontSize: 12 }}>
              <span style={{ color: "#6EE7B7" }}>Paid: ₹{totalGot}</span>
            </div>
          </div>
        </div>
      </div>

      {/* Quick actions for customer */}
      <div style={{ background: C.card, borderBottom: `1px solid ${C.border}`, padding: "12px 16px", display: "flex", gap: 8 }}>
        {[
          { icon: "whatsapp", label: "Pay via WhatsApp", color: "#25D366" },
          { icon: "pdf", label: "Download Report", color: C.primary },
          { icon: "sms", label: "Request SMS", color: C.primary },
        ].map(a => (
          <button key={a.label} style={{ flex: 1, background: C.bg, border: `1px solid ${C.border}`, borderRadius: 10, padding: "8px 4px", cursor: "pointer", display: "flex", flexDirection: "column", alignItems: "center", gap: 4, fontFamily: "inherit" }}>
            <Icon name={a.icon} size={18} color={a.color} />
            <span style={{ fontSize: 9, color: C.textSub, fontWeight: 600, textAlign: "center", lineHeight: 1.3 }}>{a.label}</span>
          </button>
        ))}
      </div>

      {/* Transaction history */}
      <div style={{ flex: 1, overflowY: "auto", WebkitOverflowScrolling: "touch" }}>
        <div style={{ display: "grid", gridTemplateColumns: "1fr 90px 90px", padding: "8px 16px", fontSize: 11, fontWeight: 700, color: C.textSub, letterSpacing: 0.5, textTransform: "uppercase", borderBottom: `1px solid ${C.border}`, background: C.card }}>
          <span>Entries</span>
          <span style={{ textAlign: "center" }}>You Owe</span>
          <span style={{ textAlign: "center" }}>You Paid</span>
        </div>

        {txList.length === 0 ? (
          <div style={{ textAlign: "center", padding: "48px 24px", color: C.textMuted }}>
            <div style={{ fontSize: 36, marginBottom: 8 }}>📋</div>
            <div style={{ fontWeight: 600, fontSize: 15 }}>No transactions yet</div>
            <div style={{ fontSize: 13, marginTop: 4 }}>Your laundry entries will appear here</div>
          </div>
        ) : txList.map(t => (
          <div key={t.id} style={{ display: "grid", gridTemplateColumns: "1fr 90px 90px", padding: "12px 16px", background: C.card, marginBottom: 2, borderLeft: `3px solid ${t.type === "gave" ? C.red : C.green}` }}>
            <div>
              <div style={{ fontSize: 12, fontWeight: 600, color: C.text }}>{formatDate(t.date)}</div>
              <div style={{ fontSize: 11, color: C.textSub, marginTop: 2 }}>Bal. ₹{Math.abs(t.balance)}</div>
              {t.desc && <div style={{ fontSize: 11, color: C.textMuted, marginTop: 1 }}>{t.desc}</div>}
            </div>
            <div style={{ display: "flex", alignItems: "center", justifyContent: "center" }}>
              {t.type === "gave" ? <span style={{ fontWeight: 800, fontSize: 15, color: C.red }}>₹{t.amount}</span> : <span style={{ color: C.textMuted }}>—</span>}
            </div>
            <div style={{ display: "flex", alignItems: "center", justifyContent: "center" }}>
              {t.type === "got" ? <span style={{ fontWeight: 800, fontSize: 15, color: C.green }}>₹{t.amount}</span> : <span style={{ color: C.textMuted }}>—</span>}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

// ─── STAFF SETTINGS SCREEN ────────────────────────────────────────────────────
const STAFF_PERMISSIONS = [
  { id: "view_entries", label: "View Entries" },
  { id: "send_reminders", label: "Send Reminders" },
  { id: "add_customers", label: "Add New Customers" },
  { id: "edit_customers", label: "Edit Customer" },
  { id: "view_invoices", label: "View and Send Invoices" },
  { id: "call_customer", label: "Call Customer" },
  { id: "whatsapp", label: "WhatsApp" },
  { id: "sms", label: "SMS" },
];

const DEFAULT_PERMS = { view_entries: true, send_reminders: true, add_customers: false, edit_customers: false, view_invoices: false, call_customer: true, whatsapp: true, sms: false };

const MOCK_STAFF = [
  { id: "s1", name: "Ramesh Kumar", phone: "9845011223", email: "ramesh@gmail.com", permissions: { ...DEFAULT_PERMS, add_customers: true }, active: true },
  { id: "s2", name: "Suresh Babu", phone: "9731099887", email: "suresh@gmail.com", permissions: { ...DEFAULT_PERMS }, active: true },
];

function StaffSettingsScreen({ onBack }) {
  const [staffList, setStaffList] = React.useState(MOCK_STAFF);
  const [addOpen, setAddOpen] = React.useState(false);
  const [editingStaff, setEditingStaff] = React.useState(null);
  const [newName, setNewName] = React.useState("");
  const [newPhone, setNewPhone] = React.useState("");
  const [newEmail, setNewEmail] = React.useState("");
  const [newPerms, setNewPerms] = React.useState({ ...DEFAULT_PERMS });
  const [err, setErr] = React.useState("");

  function togglePerm(id) { setNewPerms(p => ({ ...p, [id]: !p[id] })); }

  function openAdd() {
    setNewName(""); setNewPhone(""); setNewEmail(""); setNewPerms({ ...DEFAULT_PERMS });
    setEditingStaff(null); setErr(""); setAddOpen(true);
  }

  function openEdit(staff) {
    setNewName(staff.name); setNewPhone(staff.phone); setNewEmail(staff.email);
    setNewPerms({ ...staff.permissions }); setEditingStaff(staff); setErr(""); setAddOpen(true);
  }

  function saveStaff() {
    if (!newName.trim() || !newPhone.trim() || !newEmail.trim()) { setErr("All fields required."); return; }
    if (editingStaff) {
      setStaffList(list => list.map(s => s.id === editingStaff.id ? { ...s, name: newName, phone: newPhone, email: newEmail, permissions: newPerms } : s));
    } else {
      setStaffList(list => [...list, { id: "s" + Date.now(), name: newName, phone: newPhone, email: newEmail, permissions: newPerms, active: true }]);
    }
    setAddOpen(false);
  }

  function removeStaff(id) { setStaffList(list => list.filter(s => s.id !== id)); }

  return (
    <div style={{ flex: 1, display: "flex", flexDirection: "column", background: C.bg, overflow: "hidden" }}>
      {/* Header */}
      <div style={{ background: `linear-gradient(135deg, ${C.primaryDark}, ${C.primaryLight})`, padding: "12px 16px 18px" }}>
        <div style={{ display: "flex", alignItems: "center", gap: 12, marginBottom: 6 }}>
          <button onClick={onBack} style={{ background: "rgba(255,255,255,0.15)", border: "none", borderRadius: 8, padding: "7px 8px", cursor: "pointer" }}><Icon name="back" size={20} color="#fff" /></button>
          <div>
            <div style={{ color: "#fff", fontWeight: 700, fontSize: 17 }}>Staff Management</div>
            <div style={{ color: "#B0C6FF", fontSize: 12 }}>Manage staff access & permissions</div>
          </div>
        </div>
      </div>

      <div style={{ flex: 1, overflowY: "auto", padding: "12px 12px 20px" }}>
        {/* Staff list */}
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "4px 4px 10px" }}>
          <div style={{ fontWeight: 700, fontSize: 14, color: C.text }}>{staffList.length} Staff Member{staffList.length !== 1 ? "s" : ""}</div>
          <button onClick={openAdd} style={{ background: C.primary, color: "#fff", border: "none", borderRadius: 10, padding: "8px 14px", fontSize: 13, fontWeight: 700, cursor: "pointer", fontFamily: "inherit", display: "flex", alignItems: "center", gap: 6 }}>
            <Icon name="plus" size={15} color="#fff" /> Add Staff
          </button>
        </div>

        {staffList.map(staff => (
          <div key={staff.id} style={{ background: C.card, borderRadius: 14, padding: "14px 16px", marginBottom: 10, boxShadow: "0 1px 4px rgba(0,0,0,0.06)" }}>
            <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
              <Avatar name={staff.name} size={44} bg="#7C3AED" />
              <div style={{ flex: 1 }}>
                <div style={{ fontWeight: 700, fontSize: 15, color: C.text }}>{staff.name}</div>
                <div style={{ fontSize: 12, color: C.textSub, marginTop: 2 }}>{staff.phone} · {staff.email}</div>
              </div>
              <div style={{ display: "flex", gap: 6 }}>
                <button onClick={() => openEdit(staff)} style={{ background: C.bg, border: `1px solid ${C.border}`, borderRadius: 8, padding: "6px 8px", cursor: "pointer" }}><Icon name="edit" size={16} color={C.primary} /></button>
                <button onClick={() => removeStaff(staff.id)} style={{ background: C.redLight, border: `1px solid ${C.red}`, borderRadius: 8, padding: "6px 8px", cursor: "pointer" }}><Icon name="trash" size={16} color={C.red} /></button>
              </div>
            </div>
            {/* Permission pills */}
            <div style={{ display: "flex", flexWrap: "wrap", gap: 5, marginTop: 10 }}>
              {STAFF_PERMISSIONS.filter(p => staff.permissions[p.id]).map(p => (
                <div key={p.id} style={{ background: "#EEF2FF", color: "#4338CA", borderRadius: 6, padding: "3px 8px", fontSize: 10, fontWeight: 600 }}>{p.label}</div>
              ))}
            </div>
          </div>
        ))}

        {staffList.length === 0 && (
          <div style={{ textAlign: "center", padding: "40px 20px", color: C.textMuted }}>
            <div style={{ fontSize: 36, marginBottom: 8 }}>👥</div>
            <div style={{ fontWeight: 600, fontSize: 15 }}>No staff added yet</div>
            <div style={{ fontSize: 13, marginTop: 4 }}>Add staff to assign them work</div>
          </div>
        )}
      </div>

      {/* Add/Edit staff bottom sheet */}
      <BottomSheet open={addOpen} onClose={() => setAddOpen(false)} title={editingStaff ? "Edit Staff" : "Add New Staff"}>
        <div style={{ padding: "16px 20px", overflowY: "auto" }}>
          <TextInput label="Full Name" value={newName} onChange={setNewName} placeholder="Staff member name" required />
          <TextInput label="Phone Number" value={newPhone} onChange={setNewPhone} placeholder="10-digit number" type="tel" required />
          <TextInput label="Email Address" value={newEmail} onChange={setNewEmail} placeholder="staff@gmail.com" type="email" required />

          <div style={{ marginBottom: 14 }}>
            <div style={{ fontSize: 12, fontWeight: 600, color: C.textSub, letterSpacing: 0.4, textTransform: "uppercase", marginBottom: 10 }}>
              Permissions
            </div>
            <div style={{ background: C.bg, borderRadius: 12, overflow: "hidden" }}>
              {STAFF_PERMISSIONS.map((p, i) => (
                <div key={p.id} onClick={() => togglePerm(p.id)} style={{ display: "flex", alignItems: "center", padding: "12px 14px", borderBottom: i < STAFF_PERMISSIONS.length - 1 ? `1px solid ${C.border}` : "none", cursor: "pointer" }}>
                  <div style={{ flex: 1, fontSize: 14, color: C.text, fontWeight: newPerms[p.id] ? 600 : 400 }}>{p.label}</div>
                  <div style={{
                    width: 22, height: 22, borderRadius: 6,
                    background: newPerms[p.id] ? C.primary : "transparent",
                    border: `2px solid ${newPerms[p.id] ? C.primary : C.border}`,
                    display: "flex", alignItems: "center", justifyContent: "center",
                    transition: "all 0.15s"
                  }}>
                    {newPerms[p.id] && <Icon name="check" size={13} color="#fff" strokeWidth={3} />}
                  </div>
                </div>
              ))}
            </div>
          </div>

          {err && <div style={{ color: C.red, fontSize: 13, marginBottom: 10, background: C.redLight, padding: "8px 12px", borderRadius: 8 }}>{err}</div>}

          <button onClick={saveStaff} style={{ width: "100%", padding: "14px", background: C.primary, color: "#fff", border: "none", borderRadius: 12, fontSize: 15, fontWeight: 700, cursor: "pointer", fontFamily: "inherit" }}>
            {editingStaff ? "Save Changes" : "Add Staff Member"}
          </button>
        </div>
      </BottomSheet>
    </div>
  );
}

// ─── EXPORTS ─────────────────────────────────────────────────────────────────
Object.assign(window, {
  RegistrationScreen, CustomerHomeScreen, StaffSettingsScreen,
});
