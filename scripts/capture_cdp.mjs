import { writeFile } from 'node:fs/promises';

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

await sleep(35000);

const tabs = await fetch('http://127.0.0.1:9223/json').then((response) => response.json());
const targetUrl = process.argv[2] ?? 'http://127.0.0.1:3002';
const tab = tabs.find((item) => item.type === 'page' && item.url.includes(targetUrl)) ?? tabs.find((item) => item.type === 'page') ?? tabs[0];
const ws = new WebSocket(tab.webSocketDebuggerUrl);
let id = 0;
const pending = new Map();

ws.onmessage = (event) => {
  const message = JSON.parse(event.data);
  if (message.id && pending.has(message.id)) {
    pending.get(message.id)(message);
    pending.delete(message.id);
  }
};

await new Promise((resolve, reject) => {
  ws.onopen = resolve;
  ws.onerror = reject;
});

function send(method, params = {}) {
  const current = ++id;
  ws.send(JSON.stringify({ id: current, method, params }));
  return new Promise((resolve) => pending.set(current, resolve));
}

await send('Page.enable');
await send('Runtime.enable');
await send('Log.enable');
const events = [];
ws.onmessage = (event) => {
  const message = JSON.parse(event.data);
  if (message.id && pending.has(message.id)) {
    pending.get(message.id)(message);
    pending.delete(message.id);
  } else if (message.method === 'Runtime.consoleAPICalled' || message.method === 'Runtime.exceptionThrown' || message.method === 'Log.entryAdded') {
    events.push(message);
  }
};
await send('Emulation.setDeviceMetricsOverride', {
  width: 430,
  height: 932,
  deviceScaleFactor: 1,
  mobile: true,
});
await send('Page.navigate', { url: targetUrl });
await sleep(12000);

const snapshot = await send('Runtime.evaluate', {
  expression: 'location.href + "|" + document.title + "|" + document.body.innerText + "|" + document.querySelectorAll("flt-glass-pane, canvas").length + "|" + document.documentElement.outerHTML.slice(0, 500)',
  returnByValue: true,
});
const shot = await send('Page.captureScreenshot', {
  format: 'png',
  captureBeyondViewport: true,
});
const bytes = Buffer.from(shot.result.data, 'base64');
await writeFile('previews/tecaigo-flutter-real-mobile.png', bytes);
ws.close();

console.log(JSON.stringify({ bytes: bytes.length, snapshot: snapshot.result?.result?.value, events: events.slice(-8) }));
