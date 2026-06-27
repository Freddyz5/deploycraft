// Stars
const starsEl = document.getElementById("stars");
for (let i = 0; i < 60; i++) {
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

// Scroll reveal
const observer = new IntersectionObserver(
	(entries) =>
		entries.forEach((e) => {
			if (e.isIntersecting) e.target.classList.add("visible");
		}),
	{ threshold: 0.08 },
);
document.querySelectorAll(".reveal").forEach((el) => observer.observe(el));
