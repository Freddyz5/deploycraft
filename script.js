// ─── OS DETECTION & DOWNLOAD ──────────────────────────────────
const RELEASES_BASE =
	"https://github.com/Freddyz5/deploycraft/releases/download/v3.0.0";

const osConfig = {
	win: {
		label: "Windows detectado",
		btnText: "&#x25BA; DESCARGAR PARA WINDOWS",
		file: "install.bat",
		altText:
			"¿Usas Mac? <a onclick=\"triggerDownload('mac')\">Descarga para macOS</a>",
		termTitle: "Windows — CMD",
		termBody: `<div class="term-line"><span class="term-ps">C:\\Users\\Tú&gt;</span><span class="term-cmd">install.bat</span></div>
<div class="term-output term-info">[INFO] Detectando sistema operativo...</div>
<div class="term-output term-ok">[OK] Windows 11 detectado.</div>
<div class="term-output term-info">[INFO] Verificando Java...</div>
<div class="term-output term-warn">[WARN] Java no encontrado. Instalando...</div>
<div class="term-output term-ok">[OK] Java 21 instalado y verificado.</div>
<div class="term-output term-info">[INFO] Descargando TLauncher...</div>
<div class="term-output term-ok">[OK] TLauncher OK (45823102 bytes).</div>
<div class="term-output term-info">[INFO] Configurando servidor...</div>
<div class="term-output term-ok">[OK] Servidor DeployCraft preconfigurado.</div>
<div class="term-output term-ok">[OK] INSTALACION COMPLETADA</div>
<div class="term-line"><span class="term-ps">C:\\Users\\Tú&gt;</span><span class="term-cursor"></span></div>`,
		step2title: "Doble clic en install.bat",
		step2desc:
			'Si Windows Defender pregunta, click en "Más información" → "Ejecutar de todas formas".',
		cmd: `${RELEASES_BASE}/install.bat`,
	},
	mac: {
		label: "macOS detectado",
		btnText: "&#x25BA; DESCARGAR PARA MAC",
		file: "install.command",
		altText:
			"¿Usas Windows? <a onclick=\"triggerDownload('win')\">Descarga para Windows</a>",
		termTitle: "macOS — Terminal",
		termBody: `<div class="term-line"><span class="term-ps">usuario@mac ~ %</span><span class="term-cmd">./install.command</span></div>
<div class="term-output term-info">[INFO] Detectando sistema operativo...</div>
<div class="term-output term-ok">[OK] macOS Apple Silicon (M2) detectado.</div>
<div class="term-output term-info">[INFO] Verificando Java...</div>
<div class="term-output term-warn">[WARN] Java no encontrado. Instalando (arm64)...</div>
<div class="term-output term-ok">[OK] Java 21 instalado y verificado.</div>
<div class="term-output term-info">[INFO] Descargando TLauncher...</div>
<div class="term-output term-ok">[OK] TLauncher OK (45823102 bytes).</div>
<div class="term-output term-info">[INFO] Configurando servidor...</div>
<div class="term-output term-ok">[OK] servers.dat instalado.</div>
<div class="term-output term-ok">[OK] INSTALACION COMPLETADA</div>
<div class="term-line"><span class="term-ps">usuario@mac ~ %</span><span class="term-cursor"></span></div>`,
		step2title: "Doble clic en install.command",
		step2desc:
			'Si macOS bloquea el archivo, ve a Preferencias → Privacidad y Seguridad → "Abrir de todas formas".',
		cmd: `${RELEASES_BASE}/install.command`,
	},
	unknown: {
		label: "Sistema no detectado",
		btnText: "&#x25BA; VER DESCARGAS",
		file: null,
		altText:
			'<a href="https://github.com/Freddyz5/deploycraft/releases" target="_blank">Ver todos los instaladores en GitHub</a>',
		termTitle: "Terminal",
		termBody: "",
		step2title: "Ejecuta el installer",
		step2desc: "Sigue las instrucciones para tu sistema operativo.",
		cmd: "https://github.com/Freddyz5/deploycraft/releases",
	},
};

function detectOS() {
	const ua = navigator.userAgent;
	if (/Windows/i.test(ua)) return "win";
	if (/Mac/i.test(ua)) return "mac";
	return "unknown";
}

let currentOS = detectOS();

function triggerDownload(os) {
	const cfg = osConfig[os];
	if (!cfg.file) {
		window.open("https://github.com/Freddyz5/deploycraft/releases", "_blank");
		return;
	}
	const a = document.createElement("a");
	a.href = `${RELEASES_BASE}/${cfg.file}`;
	a.download = cfg.file;
	document.body.appendChild(a);
	a.click();
	document.body.removeChild(a);
}

function renderDownloadArea() {
	const cfg = osConfig[currentOS];
	document.getElementById("osDetected").innerHTML =
		`Sistema detectado: <span>${cfg.label}</span>`;

	const btn = document.getElementById("downloadBtn");
	if (cfg.file) {
		btn.innerHTML = `<button class="btn btn-primary" onclick="triggerDownload('${currentOS}')">${cfg.btnText}</button>`;
	} else {
		btn.innerHTML = `<a class="btn btn-primary" href="https://github.com/Freddyz5/deploycraft/releases" target="_blank">${cfg.btnText}</a>`;
	}

	document.getElementById("downloadAlts").innerHTML = cfg.altText;
}

renderDownloadArea();

// ─── STEPS / TERMINAL ────────────────────────────────────────
function switchOS(os) {
	currentOS = os;
	document.querySelectorAll(".os-tab").forEach((t, i) => {
		t.classList.toggle(
			"active",
			(i === 0 && os === "win") || (i === 1 && os === "mac"),
		);
	});
	const cfg = osConfig[os];
	document.getElementById("term-title").textContent = cfg.termTitle;
	document.getElementById("term-body").innerHTML = cfg.termBody;
	document.getElementById("step2title").textContent = cfg.step2title;
	document.getElementById("step2desc").textContent = cfg.step2desc;
	document.getElementById("one-liner-cmd").textContent = cfg.cmd;
	renderDownloadArea();
	setStep(0);
}

function setStep(idx) {
	document
		.querySelectorAll(".step-item")
		.forEach((el, i) => el.classList.toggle("active", i === idx));
}

function copyCmd() {
	const cmd = document.getElementById("one-liner-cmd").textContent;
	navigator.clipboard.writeText(cmd).catch(() => {});
	const btn = document.querySelector(".copy-btn");
	btn.textContent = "✓ COPIADO";
	setTimeout(() => {
		btn.innerHTML = "⌘ COPIAR";
	}, 1500);
}

// ─── FAQ ─────────────────────────────────────────────────────
function toggleFaq(btn) {
	const item = btn.parentElement;
	const wasOpen = item.classList.contains("open");
	document
		.querySelectorAll(".faq-item")
		.forEach((i) => i.classList.remove("open"));
	if (!wasOpen) item.classList.add("open");
}

// ─── BIRTHDAY FORM ───────────────────────────────────────────
// Frontend en GitHub Pages + API en Vercel: reemplaza TU-PROYECTO
const API_URL = "https://deploycraft.vercel.app/api/birthday";

async function submitBirthday() {
	const name    = document.getElementById("bdName").value.trim();
	const date    = document.getElementById("bdDate").value;
	const contact = document.getElementById("bdContact").value.trim();

	if (!name) {
		alert("Pon tu nombre para poder avisarte 🙂");
		document.getElementById("bdName").focus();
		return;
	}
	if (!date) {
		alert("Pon tu fecha de cumpleaños");
		document.getElementById("bdDate").focus();
		return;
	}

	const btn = document.getElementById("bdSubmit");
	btn.disabled = true;
	btn.innerHTML = "&#x25BA; GUARDANDO...";

	try {
		const res = await fetch(API_URL, {
			method: "POST",
			headers: { "Content-Type": "application/json" },
			body: JSON.stringify({ name, birthdate: date, contact }),
		});

		if (!res.ok) {
			const body = await res.json().catch(() => ({}));
			throw new Error(body.error ?? `HTTP ${res.status}`);
		}

		showState("success");
	} catch (err) {
		console.error("Birthday submit error:", err);
		document.getElementById("errorDesc").textContent =
			err.message || "No se pudo guardar. Intenta de nuevo.";
		showState("error");
	} finally {
		btn.disabled = false;
		btn.innerHTML = "&#x25BA; GUARDAR MI CUMPLE";
	}
}

function showState(state) {
	document.getElementById("formFields").style.display = "none";
	if (state === "success") {
		document.getElementById("stateSuccess").classList.add("visible");
	} else {
		document.getElementById("stateError").classList.add("visible");
	}
}

function resetForm() {
	document.getElementById("formFields").style.display = "block";
	document.getElementById("stateError").classList.remove("visible");
	document.getElementById("stateSuccess").classList.remove("visible");
}

// ─── STARS ───────────────────────────────────────────────────
const starsEl = document.getElementById("stars");
for (let i = 0; i < 80; i++) {
	const s = document.createElement("div");
	s.className = "star";
	s.style.left = Math.random() * 100 + "%";
	s.style.top = Math.random() * 100 + "%";
	s.style.animationDelay = Math.random() * 3 + "s";
	s.style.animationDuration = 2 + Math.random() * 3 + "s";
	if (Math.random() > 0.7) {
		s.style.width = "4px";
		s.style.height = "4px";
	}
	starsEl.appendChild(s);
}

// ─── SCROLL REVEAL ───────────────────────────────────────────
const observer = new IntersectionObserver(
	(entries) => {
		entries.forEach((e) => {
			if (e.isIntersecting) e.target.classList.add("visible");
		});
	},
	{ threshold: 0.1 },
);
document.querySelectorAll(".reveal").forEach((el) => observer.observe(el));
