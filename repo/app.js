const copyButton = document.querySelector("[data-copy-source]");
const copyStatus = document.querySelector("#copy-status");

const revealElements = document.querySelectorAll("[data-reveal]");

if ("IntersectionObserver" in window && !window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
  const revealObserver = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        entry.target.classList.add("visible");
        revealObserver.unobserve(entry.target);
      }
    });
  }, { threshold: 0.12 });

  revealElements.forEach((element) => revealObserver.observe(element));
} else {
  revealElements.forEach((element) => element.classList.add("visible"));
}

copyButton?.addEventListener("click", async () => {
  const source = copyButton.dataset.copySource;
  try {
    await navigator.clipboard.writeText(source);
    if (copyStatus) {
      copyStatus.textContent = "Copied";
    }
    copyButton.textContent = "Copied";
  } catch {
    if (copyStatus) {
      copyStatus.textContent = "Copy unavailable — select the source URL above";
    }
    copyButton.textContent = "Select URL";
  }
});
