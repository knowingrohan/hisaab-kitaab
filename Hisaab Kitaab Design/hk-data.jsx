
// Global app data and state management for Hisaab Kitaab
// Shared via window.HKData

const SOCIETIES = ["Klassik Landmark", "Green Valley", "Sunrise Heights"];

const MOCK_CUSTOMERS = [
  { id: 1, name: "Rohan Mahajan", flat: "G-9H", society: "Klassik Landmark", phone: "9876543210", balance: 216 },
  { id: 2, name: "Priya Sharma", flat: "B-204", society: "Klassik Landmark", phone: "9845012345", balance: 0 },
  { id: 3, name: "Amit Kulkarni", flat: "C-301", society: "Klassik Landmark", phone: "9731122334", balance: 340 },
  { id: 4, name: "Sunita Reddy", flat: "A-102", society: "Green Valley", phone: "9900112233", balance: 80 },
  { id: 5, name: "Deepak Nair", flat: "D-405", society: "Green Valley", phone: "", balance: 160 },
  { id: 6, name: "Kavita Joshi", flat: "E-501", society: "Sunrise Heights", phone: "9123456789", balance: 0 },
  { id: 7, name: "Ravi Patel", flat: "F-602", society: "Sunrise Heights", phone: "9234567890", balance: 96 },
];

const MOCK_TRANSACTIONS = {
  1: [
    { id: 101, date: "2026-04-24T20:38:00", type: "gave", amount: 160, desc: "20 items", balance: -216 },
    { id: 102, date: "2026-04-16T11:12:00", type: "gave", amount: 56, desc: "7 items", balance: -56 },
    { id: 103, date: "2026-04-12T21:35:00", type: "gave", amount: 96, desc: "12 items", balance: 0 },
    { id: 104, date: "2026-04-12T08:56:00", type: "got", amount: 96, desc: "shivu", balance: 96 },
    { id: 105, date: "2026-04-07T21:09:00", type: "gave", amount: 128, desc: "16 items", balance: 0 },
    { id: 106, date: "2026-04-01T14:28:00", type: "got", amount: 80, desc: "cash", balance: 80 },
  ],
  2: [
    { id: 201, date: "2026-04-20T10:00:00", type: "gave", amount: 80, desc: "8 shirts, 2 pants", balance: 0 },
    { id: 202, date: "2026-04-20T18:30:00", type: "got", amount: 80, desc: "UPI", balance: 80 },
  ],
  3: [
    { id: 301, date: "2026-04-23T09:00:00", type: "gave", amount: 200, desc: "10 shirts, 10 pants", balance: -340 },
    { id: 302, date: "2026-04-18T11:00:00", type: "gave", amount: 140, desc: "7 items", balance: -140 },
    { id: 303, date: "2026-04-15T08:00:00", type: "got", amount: 100, desc: "cash", balance: 100 },
    { id: 304, date: "2026-04-10T09:00:00", type: "gave", amount: 200, desc: "20 items", balance: 0 },
  ],
  4: [
    { id: 401, date: "2026-04-22T08:00:00", type: "gave", amount: 80, desc: "4 shirts, 4 pants", balance: -80 },
    { id: 402, date: "2026-04-10T10:00:00", type: "got", amount: 200, desc: "cash", balance: 200 },
  ],
  5: [
    { id: 501, date: "2026-04-21T09:00:00", type: "gave", amount: 160, desc: "16 items", balance: -160 },
    { id: 502, date: "2026-04-05T09:00:00", type: "got", amount: 80, desc: "cash", balance: 80 },
  ],
  6: [
    { id: 601, date: "2026-04-20T09:00:00", type: "gave", amount: 60, desc: "6 items", balance: 0 },
    { id: 602, date: "2026-04-20T18:00:00", type: "got", amount: 60, desc: "UPI", balance: 60 },
  ],
  7: [
    { id: 701, date: "2026-04-23T09:00:00", type: "gave", amount: 96, desc: "12 items", balance: -96 },
    { id: 702, date: "2026-04-15T08:00:00", type: "got", amount: 200, desc: "cash", balance: 200 },
  ],
};

const ITEM_RATES = { Shirt: 10, Pant: 10, Saree: 20, "Suit/Kurta": 15, Jacket: 20, Other: 10 };

function formatDate(iso) {
  const d = new Date(iso);
  return d.toLocaleDateString("en-IN", { day: "2-digit", month: "short", year: "2-digit" }) +
    " • " + d.toLocaleTimeString("en-IN", { hour: "2-digit", minute: "2-digit" });
}

function getInitials(name) {
  return name.split(" ").map(w => w[0]).join("").toUpperCase().slice(0, 2);
}

window.HKData = {
  SOCIETIES, MOCK_CUSTOMERS, MOCK_TRANSACTIONS, ITEM_RATES, formatDate, getInitials,
};
