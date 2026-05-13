(function () {
  const BLUR_ID = "command-blur";
  const QUICK_INPUT_SELECTOR = ".quick-input-widget";
  const WORKBENCH_SELECTOR = ".monaco-workbench";
  const NOTIFICATION_RADIUS = "10px";
  const NOTIFICATION_SELECTORS = [
    ".notification-toast",
    ".notification-list-item",
    ".notifications-center",
    ".notifications-toasts .monaco-list-row",
    ".notifications-list-container .monaco-list-row",
  ];
  const HIDDEN_STICKY_SELECTORS = [
    ".sticky-widget",
    ".monaco-tree-sticky-container",
  ];

  let observer;
  let syncQueued = false;

  function isQuickInputVisible() {
    const widget = document.querySelector(QUICK_INPUT_SELECTOR);

    if (!widget) {
      return false;
    }

    const style = window.getComputedStyle(widget);
    const rect = widget.getBoundingClientRect();

    return (
      style.display !== "none" &&
      style.visibility !== "hidden" &&
      Number(style.opacity) !== 0 &&
      rect.width > 0 &&
      rect.height > 0
    );
  }

  function setStickyOpacity(opacity) {
    HIDDEN_STICKY_SELECTORS.forEach((selector) => {
      document.querySelectorAll(selector).forEach((widget) => {
        widget.style.opacity = opacity;
      });
    });
  }

  function setImportantStyle(element, property, value) {
    if (
      element.style.getPropertyValue(property) === value &&
      element.style.getPropertyPriority(property) === "important"
    ) {
      return;
    }

    element.style.setProperty(property, value, "important");
  }

  function setNotificationRadiusStyle(element) {
    setImportantStyle(element, "border-radius", NOTIFICATION_RADIUS);
    setImportantStyle(element, "overflow", "hidden");
  }

  function styleNotifications() {
    NOTIFICATION_SELECTORS.forEach((selector) => {
      document.querySelectorAll(selector).forEach(setNotificationRadiusStyle);
    });
  }

  function showBlur() {
    const target = document.querySelector(WORKBENCH_SELECTOR) || document.body;

    if (!target || document.getElementById(BLUR_ID)) {
      setStickyOpacity("0");
      return;
    }

    const blur = document.createElement("div");
    blur.id = BLUR_ID;
    target.appendChild(blur);
    setStickyOpacity("0");
  }

  function hideBlur() {
    document.getElementById(BLUR_ID)?.remove();
    setStickyOpacity("1");
  }

  function syncBlur() {
    syncQueued = false;
    styleNotifications();

    if (isQuickInputVisible()) {
      showBlur();
    } else {
      hideBlur();
    }
  }

  function queueSync() {
    if (syncQueued) {
      return;
    }

    syncQueued = true;
    requestAnimationFrame(syncBlur);
  }

  function start() {
    observer?.disconnect();
    observer = new MutationObserver(queueSync);
    observer.observe(document.body, {
      attributes: true,
      attributeFilter: ["class", "style", "aria-hidden"],
      childList: true,
      subtree: true,
    });

    document.addEventListener("keydown", function (event) {
      if (event.key === "Escape" || event.key === "Esc") {
        hideBlur();
        return;
      }

      if ((event.metaKey || event.ctrlKey) && event.key.toLowerCase() === "p") {
        requestAnimationFrame(queueSync);
      }
    });

    queueSync();
  }

  if (document.body) {
    start();
  } else {
    window.addEventListener("DOMContentLoaded", start, { once: true });
  }
})();
