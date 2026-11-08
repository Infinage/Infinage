import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.registerShortcut("alt+y", {
    description: "Toggle permission-system yolo mode",
    handler: async (ctx) => {
      const api = (globalThis as any).__piPermissionSystem;
      if (!api) {
        ctx.ui.notify("permission-system runtime API not found", "error");
        return;
      }
      const result = api.toggleYoloMode({ persist: true });
      ctx.ui.notify(`yolo ${result.yoloMode ? "ON" : "OFF"}`);
    },
  });
}
