const commands = {
  remote: "curl -fsSL https://raw.githubusercontent.com/nihitdev/kairo/main/install.sh | bash",
  clone: "git clone https://github.com/nihitdev/kairo.git && cd kairo && ./install.sh",
  dry: "./install.sh --dry-run",
};

const commandOutput = document.querySelector("#install-command");
const copyStatus = document.querySelector(".copy-status");

document.querySelectorAll(".command-tab").forEach((tab) => {
  tab.addEventListener("click", () => {
    document.querySelectorAll(".command-tab").forEach((item) => {
      item.classList.toggle("active", item === tab);
      item.setAttribute("aria-selected", String(item === tab));
    });
    commandOutput.textContent = commands[tab.dataset.command];
    copyStatus.textContent = "";
  });
});

document.querySelector(".copy-button").addEventListener("click", async () => {
  try {
    await navigator.clipboard.writeText(commandOutput.textContent);
    copyStatus.textContent = "Copied to clipboard.";
  } catch {
    const range = document.createRange();
    range.selectNodeContents(commandOutput);
    const selection = window.getSelection();
    selection.removeAllRanges();
    selection.addRange(range);
    copyStatus.textContent = "Command selected—press Ctrl+C to copy.";
  }
});

document.querySelectorAll(".filter").forEach((button) => {
  button.addEventListener("click", () => {
    const filter = button.dataset.filter;
    document.querySelectorAll(".filter").forEach((item) => item.classList.toggle("active", item === button));
    document.querySelectorAll("#module-grid article").forEach((card) => {
      card.classList.toggle("hidden", filter !== "all" && card.dataset.category !== filter);
    });
  });
});

const observer = new IntersectionObserver((entries) => {
  entries.forEach((entry) => {
    if (entry.isIntersecting) {
      entry.target.classList.add("visible");
      observer.unobserve(entry.target);
    }
  });
}, { threshold: 0.12 });

document.querySelectorAll(".reveal").forEach((element) => observer.observe(element));
