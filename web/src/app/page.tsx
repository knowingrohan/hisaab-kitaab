import Image from "next/image";

export default function Home() {
  return (
    <div className="flex flex-col min-h-screen">
      <Nav />
      <main>
        <Hero />
        <About />
        <Products />
        <BusinessStreams />
        <LedgerCallout />
      </main>
      <Footer />
    </div>
  );
}

function Nav() {
  return (
    <header className="fixed top-0 left-0 right-0 z-50 bg-green-deep/95 backdrop-blur-md border-b border-white/10">
      <div className="max-w-6xl mx-auto px-6 h-16 flex items-center justify-between">
        <a href="#" className="flex items-center gap-2 group">
          <Image src="/logo.png" alt="Santhe Fresh" width={36} height={36} className="rounded-md group-hover:scale-110 transition-transform" />
          <span className="text-white font-extrabold text-xl tracking-tight">
            Santhe <span className="text-orange-light">Fresh</span>
          </span>
        </a>
        <nav className="hidden md:flex items-center gap-8">
          {["About", "Products", "Contact"].map((link) => (
            <a
              key={link}
              href={`#${link.toLowerCase()}`}
              className="text-white/80 hover:text-white text-sm font-semibold transition-colors"
            >
              {link}
            </a>
          ))}
        </nav>
        <a
          href="#contact"
          className="bg-orange-warm hover:bg-orange-mid text-white text-sm font-bold px-5 py-2 rounded-full transition-colors"
        >
          Order Now
        </a>
      </div>
    </header>
  );
}

function Hero() {
  return (
    <section
      id="hero"
      className="relative min-h-screen flex items-center justify-center overflow-hidden"
      style={{
        background:
          "linear-gradient(135deg, #1b5e20 0%, #2e7d32 40%, #e65100 100%)",
      }}
    >
      {/* Decorative blobs */}
      <div className="absolute inset-0 pointer-events-none">
        <div
          className="absolute top-20 right-16 opacity-20"
          style={{ transform: "rotate(15deg)" }}
        >
          <TomatoSvg size={180} />
        </div>
        <div
          className="absolute bottom-24 left-12 opacity-15"
          style={{ transform: "rotate(-20deg)" }}
        >
          <LemonSvg size={140} />
        </div>
        <div className="absolute top-1/3 left-1/4 opacity-10">
          <LeafDecorSvg size={200} />
        </div>
        <div className="absolute bottom-32 right-1/4 opacity-10">
          <LeafDecorSvg size={120} />
        </div>
        {/* Subtle radial highlight */}
        <div
          className="absolute inset-0"
          style={{
            background:
              "radial-gradient(ellipse 60% 50% at 50% 50%, rgba(255,255,255,0.05) 0%, transparent 70%)",
          }}
        />
      </div>

      <div className="relative z-10 text-center px-6 max-w-4xl mx-auto pt-20">
        <div className="inline-flex items-center gap-2 bg-white/10 backdrop-blur-sm border border-white/20 rounded-full px-4 py-1.5 mb-8">
          <span className="text-orange-light text-sm">🌿</span>
          <span className="text-white/90 text-sm font-semibold">
            Straight from the farm to your doorstep
          </span>
        </div>

        <h1 className="text-5xl sm:text-7xl lg:text-8xl font-black text-white leading-[1.05] tracking-tight mb-6">
          Farm-Fresh.
          <br />
          <span className="text-orange-light">Always.</span>
        </h1>

        <p
          className="text-2xl sm:text-3xl text-white/80 mb-10 leading-relaxed"
          style={{ fontFamily: "var(--font-caveat), cursive" }}
        >
          The freshest fruits & vegetables,{" "}
          <span className="text-orange-light italic">
            delivered with love ❤
          </span>
        </p>

        <div className="flex flex-col sm:flex-row gap-4 justify-center">
          <a
            href="#products"
            className="bg-white text-green-deep font-extrabold px-8 py-4 rounded-full text-lg hover:bg-cream transition-colors shadow-lg hover:shadow-xl"
          >
            Browse Products
          </a>
          <a
            href="#contact"
            className="border-2 border-white text-white font-bold px-8 py-4 rounded-full text-lg hover:bg-white/10 transition-colors"
          >
            Contact Us
          </a>
        </div>
      </div>

      {/* Bottom fade */}
      <div
        className="absolute bottom-0 left-0 right-0 h-32 pointer-events-none"
        style={{
          background:
            "linear-gradient(to bottom, transparent, #fff8f0)",
        }}
      />
    </section>
  );
}

function About() {
  return (
    <section
      id="about"
      className="py-24 px-6 bg-cream"
    >
      <div className="max-w-6xl mx-auto grid md:grid-cols-2 gap-16 items-center">
        <div>
          <span className="inline-block text-orange-warm text-sm font-extrabold uppercase tracking-widest mb-4">
            Our Story
          </span>
          <h2 className="text-4xl lg:text-5xl font-black text-green-deep leading-tight mb-6">
            We bring the freshest produce{" "}
            <span className="text-orange-warm">straight to you.</span>
          </h2>
          <p className="text-lg text-gray-600 leading-relaxed mb-6">
            Santhe Fresh started with a simple belief: everyone deserves access
            to farm-fresh fruits and vegetables without the hassle. We work
            directly with local farmers to source the ripest, most nutritious
            produce — harvested and delivered the same day.
          </p>
          <p className="text-lg text-gray-600 leading-relaxed mb-8">
            No middlemen. No cold-storage compromises. Just nature&apos;s best,
            delivered fresh to your door every morning.
          </p>
          <div className="flex gap-10">
            <Stat number="500+" label="Happy Customers" />
            <Stat number="50+" label="Local Farmers" />
            <Stat number="Daily" label="Fresh Delivery" />
          </div>
        </div>

        <div className="relative">
          <div
            className="rounded-3xl p-8 shadow-2xl"
            style={{
              background:
                "linear-gradient(135deg, #e8f5e9 0%, #fff8f0 50%, #fff3e0 100%)",
              border: "1px solid #c8e6c9",
            }}
          >
            <div className="grid grid-cols-2 gap-4">
              <ProduceCard emoji="🍎" name="Apples" origin="Himachal Pradesh" color="#fdecea" />
              <ProduceCard emoji="🥕" name="Carrots" origin="Nasik, Maharashtra" color="#fff3e0" />
              <ProduceCard emoji="🍇" name="Grapes" origin="Pune, Maharashtra" color="#f3e5f5" />
              <ProduceCard emoji="🥦" name="Broccoli" origin="Local Farms" color="#e8f5e9" />
            </div>
            <div
              className="mt-4 rounded-2xl p-4 text-center"
              style={{ background: "rgba(27,94,32,0.08)" }}
            >
              <p
                className="text-green-deep text-lg font-bold"
                style={{ fontFamily: "var(--font-caveat), cursive" }}
              >
                &quot;Freshness you can taste!&quot; 🌿
              </p>
            </div>
          </div>
          {/* Decorative dot grid */}
          <div
            className="absolute -top-4 -right-4 w-24 h-24 rounded-full opacity-30"
            style={{ background: "#e65100" }}
          />
          <div
            className="absolute -bottom-4 -left-4 w-16 h-16 rounded-full opacity-20"
            style={{ background: "#1b5e20" }}
          />
        </div>
      </div>
    </section>
  );
}

function Stat({
  number,
  label,
}: {
  number: string;
  label: string;
}) {
  return (
    <div>
      <p className="text-3xl font-black text-green-deep">{number}</p>
      <p className="text-sm text-gray-500 font-semibold">{label}</p>
    </div>
  );
}

function ProduceCard({
  emoji,
  name,
  origin,
  color,
}: {
  emoji: string;
  name: string;
  origin: string;
  color: string;
}) {
  return (
    <div
      className="rounded-2xl p-4 flex flex-col gap-1"
      style={{ background: color }}
    >
      <span className="text-3xl">{emoji}</span>
      <p className="font-bold text-gray-800 text-sm">{name}</p>
      <p className="text-xs text-gray-500">{origin}</p>
    </div>
  );
}

function Products() {
  const products = [
    {
      emoji: "🍊",
      title: "Fresh Fruits",
      desc:
        "Mangoes, oranges, bananas, pomegranates, and seasonal picks — sourced at peak ripeness for maximum sweetness.",
      accent: "#e65100",
      bg: "#fff3e0",
    },
    {
      emoji: "🥬",
      title: "Vegetables",
      desc:
        "Leafy greens, root vegetables, and everyday staples. Harvested daily, delivered crisp and clean.",
      accent: "#1b5e20",
      bg: "#e8f5e9",
    },
    {
      emoji: "🌽",
      title: "Seasonal Specials",
      desc:
        "Celebrate every season with exclusive local produce — corn in summer, strawberries in winter, and more.",
      accent: "#ef6c00",
      bg: "#fff8f0",
    },
  ];

  return (
    <section id="products" className="py-24 px-6" style={{ background: "#f1f8e9" }}>
      <div className="max-w-6xl mx-auto">
        <div className="text-center mb-16">
          <span className="inline-block text-orange-warm text-sm font-extrabold uppercase tracking-widest mb-4">
            What We Offer
          </span>
          <h2 className="text-4xl lg:text-5xl font-black text-green-deep leading-tight">
            Nature&apos;s best, every day
          </h2>
        </div>

        <div className="grid md:grid-cols-3 gap-8">
          {products.map((p) => (
            <div
              key={p.title}
              className="rounded-3xl p-8 shadow-sm hover:shadow-xl transition-shadow duration-300 group"
              style={{ background: p.bg, border: `1px solid ${p.accent}20` }}
            >
              <div
                className="w-16 h-16 rounded-2xl flex items-center justify-center text-4xl mb-6 group-hover:scale-110 transition-transform"
                style={{ background: `${p.accent}15` }}
              >
                {p.emoji}
              </div>
              <h3
                className="text-2xl font-extrabold mb-3"
                style={{ color: p.accent }}
              >
                {p.title}
              </h3>
              <p className="text-gray-600 leading-relaxed">{p.desc}</p>
              <div
                className="mt-6 h-1 rounded-full w-12 group-hover:w-24 transition-all duration-300"
                style={{ background: p.accent }}
              />
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

function BusinessStreams() {
  const streams = [
    {
      icon: "🥭",
      title: "Fruits & Vegetables",
      desc:
        "Our core business — daily fresh produce delivery to homes and businesses.",
    },
    {
      icon: "👕",
      title: "Santhe Laundry",
      desc:
        "Trusted doorstep laundry service for busy households. Pickup, wash, deliver.",
    },
    {
      icon: "📊",
      title: "Transaction Tracking",
      desc:
        "Smart digital ledger for vendors — manage customer accounts and payments with ease.",
    },
  ];

  return (
    <section className="py-24 px-6 bg-cream">
      <div className="max-w-6xl mx-auto">
        <div className="text-center mb-16">
          <span className="inline-block text-orange-warm text-sm font-extrabold uppercase tracking-widest mb-4">
            The Santhe Ecosystem
          </span>
          <h2 className="text-4xl lg:text-5xl font-black text-green-deep leading-tight">
            One brand, three services
          </h2>
          <p className="text-lg text-gray-500 mt-4 max-w-xl mx-auto">
            Santhe is more than just fresh produce — it&apos;s a network of
            services built around your everyday needs.
          </p>
        </div>

        <div className="grid md:grid-cols-3 gap-8">
          {streams.map((s, i) => (
            <div
              key={s.title}
              className="relative rounded-3xl p-8 bg-white border border-gray-100 shadow-sm hover:shadow-lg transition-shadow"
            >
              <div
                className="absolute top-0 left-8 w-12 h-1 rounded-b-full"
                style={{
                  background: i === 0 ? "#e65100" : i === 1 ? "#1b5e20" : "#ef6c00",
                }}
              />
              <div className="text-5xl mb-6">{s.icon}</div>
              <h3 className="text-xl font-extrabold text-gray-900 mb-3">
                {s.title}
              </h3>
              <p className="text-gray-500 leading-relaxed text-sm">{s.desc}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

function LedgerCallout() {
  return (
    <section
      className="py-10 px-6"
      style={{ background: "#0d2e10" }}
    >
      <div className="max-w-3xl mx-auto text-center">
        <p className="text-sm text-white/50 uppercase tracking-widest font-semibold mb-2">
          Technology Partner
        </p>
        <p className="text-white text-lg font-semibold leading-relaxed">
          ⚡ Powered by{" "}
          <span className="text-orange-light font-extrabold">
            Santhe Ledger
          </span>{" "}
          — smart transaction tracking for every customer
        </p>
      </div>
    </section>
  );
}

function Footer() {
  return (
    <footer
      id="contact"
      className="py-16 px-6"
      style={{ background: "#1b5e20" }}
    >
      <div className="max-w-6xl mx-auto">
        <div className="grid md:grid-cols-3 gap-12 mb-12">
          <div>
            <div className="flex items-center gap-2 mb-4">
              <Image src="/logo.png" alt="Santhe Fresh" width={28} height={28} className="rounded-md" />
              <span className="text-white font-extrabold text-xl">
                Santhe <span className="text-orange-light">Fresh</span>
              </span>
            </div>
            <p className="text-white/60 text-sm leading-relaxed">
              Farm-fresh fruits & vegetables, delivered daily with care and
              commitment to quality.
            </p>
          </div>

          <div>
            <h4 className="text-white font-bold mb-4">Find Us</h4>
            <p className="text-white/60 text-sm leading-relaxed">
              📍 2nd Floor, Sri Laxmi Venkateswara Nilaya, 06,
              <br />
              Sarjapur Main Rd, next to TNT Emerald,
              <br />
              Kaikondrahalli, Bengaluru, Karnataka 560035
            </p>
          </div>

          <div>
            <h4 className="text-white font-bold mb-4">Get in Touch</h4>
            <a
              href="https://wa.me/919066093081"
              className="inline-flex items-center gap-3 bg-[#25D366] hover:bg-[#20bf5b] text-white font-bold px-6 py-3 rounded-full transition-colors text-sm shadow-lg"
            >
              <WhatsAppIcon className="w-5 h-5" />
              Chat on WhatsApp
            </a>
          </div>
        </div>

        <div className="border-t border-white/10 pt-8 flex flex-col sm:flex-row items-center justify-between gap-4">
          <p className="text-white/40 text-xs">
            © {new Date().getFullYear()} Santhe Fresh. All rights reserved.
          </p>
          <p className="text-white/30 text-xs">
            Part of the Santhe ecosystem · Built with Santhe Ledger
          </p>
        </div>
      </div>
    </footer>
  );
}

// ── SVG Icons ────────────────────────────────────────────────────────────────


function TomatoSvg({ size }: { size: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 100 100" fill="none">
      <circle cx="50" cy="55" r="35" fill="#e53935" opacity="0.8" />
      <ellipse cx="50" cy="28" rx="8" ry="12" fill="#2e7d32" />
      <path d="M50 28 C40 20 30 22 28 30" stroke="#2e7d32" strokeWidth="3" strokeLinecap="round" />
      <path d="M50 28 C60 20 70 22 72 30" stroke="#2e7d32" strokeWidth="3" strokeLinecap="round" />
      <ellipse cx="40" cy="50" rx="5" ry="8" fill="white" opacity="0.15" transform="rotate(-20 40 50)" />
    </svg>
  );
}

function LemonSvg({ size }: { size: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 100 100" fill="none">
      <ellipse cx="50" cy="50" rx="38" ry="30" fill="#fdd835" opacity="0.9" />
      <ellipse cx="25" cy="50" rx="10" ry="8" fill="#f9a825" opacity="0.7" />
      <ellipse cx="75" cy="50" rx="10" ry="8" fill="#f9a825" opacity="0.7" />
      <ellipse cx="38" cy="44" rx="6" ry="9" fill="white" opacity="0.15" transform="rotate(-15 38 44)" />
    </svg>
  );
}

function LeafDecorSvg({ size }: { size: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 100 100" fill="none">
      <path
        d="M50 10 C20 10 10 40 10 60 C10 80 30 95 50 95 C70 95 90 80 90 60 C90 40 80 10 50 10Z"
        fill="white"
        opacity="0.6"
      />
      <path
        d="M50 10 L50 95"
        stroke="white"
        strokeWidth="2"
        strokeLinecap="round"
        opacity="0.4"
      />
      <path d="M50 30 C60 40 70 45 80 50" stroke="white" strokeWidth="1.5" strokeLinecap="round" opacity="0.3" />
      <path d="M50 50 C60 55 68 60 75 65" stroke="white" strokeWidth="1.5" strokeLinecap="round" opacity="0.3" />
      <path d="M50 30 C40 40 30 45 20 50" stroke="white" strokeWidth="1.5" strokeLinecap="round" opacity="0.3" />
    </svg>
  );
}

function WhatsAppIcon({ className }: { className?: string }) {
  return (
    <svg
      className={className}
      viewBox="0 0 24 24"
      fill="currentColor"
      xmlns="http://www.w3.org/2000/svg"
    >
      <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z" />
    </svg>
  );
}
