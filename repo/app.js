const copyButton = document.querySelector("[data-copy-source]");
const copyStatus = document.querySelector("#copy-status");

copyButton?.addEventListener("click", async () => {
  const source = copyButton.dataset.copySource;
  try {
    await navigator.clipboard.writeText(source);
    copyStatus.textContent = "Copied";
    copyButton.textContent = "Copied";
  } catch {
    copyStatus.textContent = "Copy unavailable — select the source URL above";
    copyButton.textContent = "Select URL";
  }
});
