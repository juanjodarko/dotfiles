/**
 * Switch Theme — swaps the central Catppuccin flavor from Vicinae.
 *
 * Calls the headless `theme-set <flavor>` (bin/.local/bin/theme-set), the same
 * backend every theme frontend uses:
 *     wofi popup  ─┐
 *     Vicinae      ├─► theme-set <flavor>  (single source of truth)
 *     omarchy bar ─┘
 * That decoupling (backend vs frontend) is the same principle from the launcher plan.
 */
import {
  List,
  ActionPanel,
  Action,
  Icon,
  Color,
  showToast,
  Toast,
  closeMainWindow,
} from "@vicinae/api";
import { execFile } from "node:child_process";
import { promisify } from "node:util";

const run = promisify(execFile);

interface Flavor {
  id: string;
  name: string;
  mode: "Dark" | "Light";
  tint: Color;
}

const FLAVORS: Flavor[] = [
  { id: "mocha", name: "Mocha", mode: "Dark", tint: Color.Purple },
  { id: "macchiato", name: "Macchiato", mode: "Dark", tint: Color.Blue },
  { id: "frappe", name: "Frappé", mode: "Dark", tint: Color.Orange },
  { id: "latte", name: "Latte", mode: "Light", tint: Color.Yellow },
];

export default function SwitchTheme() {
  async function apply(f: Flavor) {
    try {
      await run("theme-set", [f.id]); // headless switcher (see note above)
      await showToast({ style: Toast.Style.Success, title: `Theme → Catppuccin ${f.name}` });
      await closeMainWindow();
    } catch (e) {
      await showToast({
        style: Toast.Style.Failure,
        title: "Theme switch failed",
        message: String(e),
      });
    }
  }

  return (
    <List searchBarPlaceholder="Pick a Catppuccin flavor…">
      {FLAVORS.map((f) => (
        <List.Item
          key={f.id}
          title={f.name}
          subtitle={f.mode}
          icon={{ source: Icon.CircleFilled, tintColor: f.tint }}
          actions={
            <ActionPanel>
              <Action title={`Apply ${f.name}`} icon={Icon.Brush} onAction={() => apply(f)} />
            </ActionPanel>
          }
        />
      ))}
    </List>
  );
}
