// ─── OS DETECTION & DOWNLOAD ──────────────────────────────────
// Descargas oficiales de TLauncher (las mismas que usa el botón de tlauncher.org)
const TLAUNCHER_SITE = "https://tlauncher.org/en/";
const JAVA_URL = "https://www.java.com/es/download/";

const osConfig = {
	win: {
		label: "Windows detectado",
		btnText: "&#x25BA; DESCARGAR TLAUNCHER PARA WINDOWS",
		shortBtn: "&#x25BA; DESCARGAR .EXE",
		url: "https://tlauncher.org/installer",
		file: "TLauncher-Installer.exe",
		java: "Incluido en el instalador",
		altText:
			'¿Usas Mac? <a href="https://tlauncher.org/jar" target="_blank" rel="noopener">Descarga para macOS</a>',
		title: "Windows — Descarga oficial",
		steps: [
			{
				title: "Descarga el instalador",
				desc: "Click en el botón de descarga. Se baja <strong>TLauncher-Installer.exe</strong> desde tlauncher.org, la página oficial.",
			},
			{
				title: "Abre el .exe",
				desc: 'Búscalo en tu carpeta Descargas y dale doble clic. Si aparece "Windows protegió tu PC", click en <strong>Más información</strong> → <strong>Ejecutar de todas formas</strong>.',
			},
			{
				title: "Sigue el instalador",
				desc: "Click en <strong>Siguiente</strong> e <strong>Instalar</strong>. Si te ofrece instalar programas extra (navegadores, antivirus), <strong>desmarca esas casillas</strong>. Si pide instalar Java, acepta.",
			},
			{
				title: "Abre TLauncher y juega",
				desc: 'Queda un acceso directo en el Escritorio. Pon tu nick, elige <strong>"Oficial 26.2"</strong>, click en <strong>Entrar al juego</strong> y agrega el servidor (datos abajo).',
			},
		],
	},
	mac: {
		label: "macOS detectado",
		btnText: "&#x25BA; DESCARGAR TLAUNCHER PARA MAC",
		shortBtn: "&#x25BA; DESCARGAR .ZIP",
		url: "https://tlauncher.org/jar",
		file: "TLauncher.zip → TLauncher.jar",
		java: `Necesario — <a href="${JAVA_URL}" target="_blank" rel="noopener">java.com</a>`,
		altText:
			'¿Usas Windows? <a href="https://tlauncher.org/installer" target="_blank" rel="noopener">Descarga para Windows</a>',
		title: "macOS — Descarga oficial",
		steps: [
			{
				title: "Instala Java (si no lo tienes)",
				desc: `TLauncher necesita Java en Mac. Descárgalo gratis en <a href="${JAVA_URL}" target="_blank" rel="noopener">java.com</a> e instálalo: <strong>ARM64</strong> si tu Mac es M1/M2/M3/M4, <strong>x64</strong> si es Intel.`,
			},
			{
				title: "Descarga TLauncher",
				desc: "Click en el botón de descarga. Se baja un <strong>.zip</strong> desde tlauncher.org. Dale doble clic para descomprimirlo y obtendrás <strong>TLauncher.jar</strong>. Muévelo al Escritorio o a Aplicaciones.",
			},
			{
				title: "Ábrelo la primera vez",
				desc: 'Clic derecho (o Control + clic) sobre <strong>TLauncher.jar</strong> → <strong>Abrir</strong> → <strong>Abrir</strong>. Si macOS lo bloquea: Ajustes del Sistema → Privacidad y seguridad → "Abrir de todas formas".',
			},
			{
				title: "Entra al juego",
				desc: 'Pon tu nick, elige <strong>"Oficial 26.2"</strong>, click en <strong>Entrar al juego</strong> y agrega el servidor (datos abajo). La próxima vez basta con doble clic.',
			},
		],
	},
	unknown: {
		label: "Sistema no detectado",
		btnText: "&#x25BA; IR A TLAUNCHER.ORG",
		url: TLAUNCHER_SITE,
		altText:
			'Elige tu sistema en la página oficial, o mira los <a href="#instalar">pasos de instalación</a>.',
	},
};

function detectOS() {
	const ua = navigator.userAgent;
	if (/Windows/i.test(ua)) return "win";
	if (/Mac/i.test(ua) && !/iPhone|iPad/i.test(ua)) return "mac";
	return "unknown";
}

const detectedOS = detectOS();

function renderDownloadArea(os) {
	const cfg = osConfig[os];
	document.getElementById("osDetected").innerHTML =
		`Sistema detectado: <span>${cfg.label}</span>`;
	document.getElementById("downloadBtn").innerHTML =
		`<a class="btn btn-primary" href="${cfg.url}" target="_blank" rel="noopener">${cfg.btnText}</a>`;
	document.getElementById("downloadAlts").innerHTML =
		`${cfg.altText}<br />¿Ya lo descargaste? <a href="#instalar">Mira cómo instalarlo</a>`;
}

function renderInstall(os) {
	const cfg = osConfig[os];
	document.getElementById("stepList").innerHTML = cfg.steps
		.map(
			(step, i) => `<div class="step-item" onclick="setStep(${i})">
	<div class="step-num">0${i + 1}</div>
	<div>
		<div class="step-title">${step.title}</div>
		<div class="step-desc">${step.desc}</div>
	</div>
</div>`,
		)
		.join("");
	document.getElementById("dl-title").textContent = cfg.title;
	document.getElementById("dl-file").textContent = cfg.file;
	document.getElementById("dl-java").innerHTML = cfg.java;
	const btn = document.getElementById("dl-btn");
	btn.href = cfg.url;
	btn.innerHTML = cfg.shortBtn;
	document.getElementById("one-liner-cmd").textContent = cfg.url;
	setStep(0);
}

// ─── STEPS ───────────────────────────────────────────────────
function switchOS(os) {
	document.querySelectorAll(".os-tab").forEach((t, i) => {
		t.classList.toggle(
			"active",
			(i === 0 && os === "win") || (i === 1 && os === "mac"),
		);
	});
	renderInstall(os);
}

function setStep(idx) {
	document
		.querySelectorAll(".step-item")
		.forEach((el, i) => el.classList.toggle("active", i === idx));
}

renderDownloadArea(detectedOS);
// Las pestañas de instalación solo tienen Windows y Mac
switchOS(detectedOS === "unknown" ? "win" : detectedOS);

function promptManualCopy(text) {
	window.prompt("Copia este enlace manualmente:", text);
	return false;
}

async function copyCmd() {
	const cmd = document.getElementById("one-liner-cmd").textContent;
	const btn = document.querySelector(".copy-btn");
	let copied = false;

	try {
		if (navigator.clipboard && window.isSecureContext) {
			await navigator.clipboard.writeText(cmd);
			copied = true;
		} else {
			copied = promptManualCopy(cmd);
		}
	} catch {
		copied = promptManualCopy(cmd);
	}

	btn.textContent = copied ? "✓ COPIADO" : "COPIA MANUAL";
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
