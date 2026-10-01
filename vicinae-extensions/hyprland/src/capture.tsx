/**
 * Capture — screenshots, screen recording, OCR, QR and color picking from Vicinae.
 *
 * A thin frontend over the dotfiles' capture-* scripts (bin/.local/bin, ported
 * from Omarchy), the same backends the Print keybindings and the DockShell
 * recording indicator use. Mirrors Omarchy's "Capture" menu (SUPER+CTRL+C).
 */
import { List, ActionPanel, Action, Icon, Color, closeMainWindow } from "@vicinae/api";
import { useEffect, useState } from "react";
import { execFile, spawn } from "node:child_process";
import { homedir } from "node:os";

const BIN = `${homedir()}/.local/bin`;

interface CaptureItem {
  id: string;
  title: string;
  subtitle: string;
  icon: Icon;
  command: string[];
}

const SCREENSHOTS: CaptureItem[] = [
  { id: "shot-smart", title: "Screenshot", subtitle: "Drag a region or click a window", icon: Icon.Camera, command: [`${BIN}/capture-screenshot`, "smart"] },
  { id: "shot-windows", title: "Screenshot Window", subtitle: "Snap to a window", icon: Icon.AppWindow, command: [`${BIN}/capture-screenshot`, "windows"] },
  { id: "shot-full", title: "Screenshot Screen", subtitle: "Focused monitor", icon: Icon.Desktop, command: [`${BIN}/capture-screenshot`, "fullscreen"] },
];

const RECORDINGS: CaptureItem[] = [
  { id: "rec", title: "Record Screen", subtitle: "No audio", icon: Icon.Video, command: [`${BIN}/capture-screenrecording`] },
  { id: "rec-desktop", title: "Record Screen with Desktop Audio", subtitle: "", icon: Icon.SpeakerOn, command: [`${BIN}/capture-screenrecording`, "--with-desktop-audio"] },
  { id: "rec-mic", title: "Record Screen with Desktop + Microphone", subtitle: "", icon: Icon.Microphone, command: [`${BIN}/capture-screenrecording`, "--with-desktop-audio", "--with-microphone-audio"] },
  { id: "rec-full", title: "Record Full Screen", subtitle: "Focused monitor, no picker", icon: Icon.Desktop, command: [`${BIN}/capture-screenrecording`, "--fullscreen"] },
];

const TOOLS: CaptureItem[] = [
  { id: "text", title: "Copy Text from Screen", subtitle: "OCR a region", icon: Icon.Text, command: [`${BIN}/capture-text`] },
  { id: "qr", title: "Scan QR Code", subtitle: "Decode a region", icon: Icon.Center, command: [`${BIN}/capture-qr`] },
  { id: "color", title: "Pick Color", subtitle: "Copies hex to clipboard", icon: Icon.EyeDropper, command: ["hyprpicker", "-a"] },
];

const STOP: CaptureItem = {
  id: "stop",
  title: "Stop Recording",
  subtitle: "Save and finalize",
  icon: Icon.Stop,
  command: [`${BIN}/capture-screenrecording`, "--stop-recording"],
};

/**
 * Close Vicinae, then run the capture detached. The short delay lets the
 * launcher surface unmap before the picker freezes the screen, or it would be
 * captured in the frozen frame.
 */
async function launch(item: CaptureItem) {
  await closeMainWindow();
  const child = spawn("sh", ["-c", 'sleep 0.25; exec "$@"', "sh", ...item.command], {
    detached: true,
    stdio: "ignore",
  });
  child.unref();
}

function isRecording(): Promise<boolean> {
  return new Promise((resolve) => {
    execFile(`${BIN}/capture-screenrecording`, ["--status"], (err) => resolve(!err));
  });
}

function Item({ item, accent }: { item: CaptureItem; accent?: Color }) {
  return (
    <List.Item
      key={item.id}
      title={item.title}
      subtitle={item.subtitle}
      icon={accent ? { source: item.icon, tintColor: accent } : item.icon}
      actions={
        <ActionPanel>
          <Action title={item.title} icon={item.icon} onAction={() => launch(item)} />
        </ActionPanel>
      }
    />
  );
}

export default function Capture() {
  const [recording, setRecording] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    isRecording().then((r) => {
      setRecording(r);
      setLoading(false);
    });
  }, []);

  return (
    <List isLoading={loading} searchBarPlaceholder="Screenshot, record, OCR, QR, color…">
      {recording && (
        <List.Section title="Recording in progress">
          <Item item={STOP} accent={Color.Red} />
        </List.Section>
      )}
      <List.Section title="Screenshot">
        {SCREENSHOTS.map((i) => (
          <Item key={i.id} item={i} />
        ))}
      </List.Section>
      {!recording && (
        <List.Section title="Screen Recording">
          {RECORDINGS.map((i) => (
            <Item key={i.id} item={i} />
          ))}
        </List.Section>
      )}
      <List.Section title="Tools">
        {TOOLS.map((i) => (
          <Item key={i.id} item={i} />
        ))}
      </List.Section>
    </List>
  );
}
