/**
 * Switch Window — a NATIVE Vicinae command for Hyprland.
 *
 * This is the "Raycast can't do this on Linux" showcase: it shells out to
 * `hyprctl` (Hyprland's IPC), which only exists here. The component model
 * (List / ActionPanel / Action / hooks) is identical to Raycast's, so the
 * knowledge is 100% transferable — only the imports change (@vicinae/api).
 */
import {
  List,
  ActionPanel,
  Action,
  Icon,
  showToast,
  Toast,
  closeMainWindow,
} from "@vicinae/api";
import { useEffect, useState } from "react";
import { execFile } from "node:child_process";
import { promisify } from "node:util";

const run = promisify(execFile);

interface HyprClient {
  address: string;
  title: string;
  class: string;
  workspace: { id: number; name: string };
  focusHistoryID: number; // 0 = currently focused, higher = older
}

async function hyprctl(args: string[]): Promise<string> {
  const { stdout } = await run("hyprctl", args);
  return stdout;
}

/**
 * Dispatch a window action. Hyprland's Lua config (hyprland.lua) makes
 * `hyprctl dispatch` evaluate Lua, so the legacy `focuswindow address:…` form
 * fails there; try the Lua dispatcher first and fall back to the legacy one
 * (hyprland.conf sessions). Same pattern Omarchy uses.
 */
async function dispatchWindow(lua: "focus" | "window.close", legacy: string, address: string) {
  try {
    const out = await hyprctl(["dispatch", `hl.dsp.${lua}({ window = "address:${address}" })`]);
    if (out.trim() === "ok") return;
  } catch {
    // not a Lua session — fall through
  }
  await hyprctl(["dispatch", legacy, `address:${address}`]);
}

export default function SwitchWindow() {
  const [clients, setClients] = useState<HyprClient[]>([]);
  const [loading, setLoading] = useState(true);

  async function load() {
    try {
      const raw = await hyprctl(["clients", "-j"]);
      const parsed = (JSON.parse(raw) as HyprClient[])
        .filter((c) => c.title?.trim()) // drop titleless surfaces (layers, etc.)
        .sort((a, b) => a.focusHistoryID - b.focusHistoryID); // MRU order
      setClients(parsed);
    } catch (e) {
      await showToast({
        style: Toast.Style.Failure,
        title: "Couldn't reach hyprctl",
        message: String(e),
      });
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    void load();
  }, []);

  async function focus(address: string) {
    try {
      await dispatchWindow("focus", "focuswindow", address);
      await closeMainWindow();
    } catch (e) {
      await showToast({ style: Toast.Style.Failure, title: "Couldn't focus window", message: String(e) });
    }
  }

  async function close(address: string) {
    try {
      await dispatchWindow("window.close", "closewindow", address);
    } catch (e) {
      await showToast({ style: Toast.Style.Failure, title: "Couldn't close window", message: String(e) });
    }
    await load(); // refresh the list in place
  }

  return (
    <List isLoading={loading} searchBarPlaceholder="Filter windows by title or app…">
      {clients.map((c) => (
        <List.Item
          key={c.address}
          title={c.title}
          subtitle={c.class}
          icon={Icon.AppWindow}
          accessories={[{ tag: c.workspace.name }]}
          actions={
            <ActionPanel>
              <Action title="Focus Window" icon={Icon.Eye} onAction={() => focus(c.address)} />
              <Action
                title="Close Window"
                icon={Icon.XMarkCircle}
                style={Action.Style.Destructive}
                shortcut={{ modifiers: ["ctrl"], key: "x" }}
                onAction={() => close(c.address)}
              />
            </ActionPanel>
          }
        />
      ))}
    </List>
  );
}
