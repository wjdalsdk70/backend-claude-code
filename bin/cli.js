#!/usr/bin/env node
// npx backend-claude-code [target-dir] 진입점
'use strict';

const fs = require('fs');
const path = require('path');

const PKG_DIR = path.join(__dirname, '..');
const TARGET = process.argv[2] ? path.resolve(process.argv[2]) : process.cwd();

if (!fs.existsSync(TARGET)) {
  console.error(`Error: 대상 디렉토리가 존재하지 않습니다: ${TARGET}`);
  process.exit(1);
}

console.log(`backend-claude-code → ${TARGET}`);

const CLAUDE_DIR   = path.join(TARGET, '.claude');
const TRACKING     = path.join(CLAUDE_DIR, '.installed-files');
const IGNORE_FILE  = path.join(CLAUDE_DIR, '.claude-ignore');

// 디렉토리 초기화
for (const d of ['rules', 'agents', 'commands', 'skills']) {
  fs.mkdirSync(path.join(CLAUDE_DIR, d), { recursive: true });
}
if (!fs.existsSync(TRACKING)) fs.writeFileSync(TRACKING, '');

// .claude-ignore 파싱
const ignored = new Set(
  fs.existsSync(IGNORE_FILE)
    ? fs.readFileSync(IGNORE_FILE, 'utf8')
        .split('\n')
        .map(l => l.trim())
        .filter(l => l && !l.startsWith('#'))
    : []
);
const isIgnored = rel => ignored.has(rel);

// 트래킹 파일 읽기/쓰기
const readTracked  = () => new Set(fs.readFileSync(TRACKING, 'utf8').split('\n').filter(Boolean));
const writeTracked = set => fs.writeFileSync(TRACKING, [...set].join('\n') + (set.size ? '\n' : ''));

const track   = dest => { const s = readTracked(); s.add(dest);    writeTracked(s); };
const untrack = dest => { const s = readTracked(); s.delete(dest); writeTracked(s); };

// 파일 동기화
const syncFile = (src, dest, rel) => {
  if (isIgnored(rel)) { console.log(`  skip (ignored): ${rel}`); return; }
  fs.copyFileSync(src, dest);
  track(dest);
  console.log(`  sync: ${rel}`);
};

// dest → { rel, src } 매핑
const resolve = dest => {
  const settingsDest = path.join(CLAUDE_DIR, 'settings.json');
  if (dest === settingsDest)
    return { rel: 'settings.json', src: path.join(PKG_DIR, '.claude', 'settings.json') };
  if (dest.startsWith(CLAUDE_DIR + path.sep)) {
    const rel = dest.slice(CLAUDE_DIR.length + 1);
    return { rel, src: path.join(PKG_DIR, rel) };
  }
  if (dest === path.join(TARGET, 'CLAUDE.md'))
    return { rel: 'CLAUDE.md', src: path.join(PKG_DIR, 'CLAUDE.md') };
  if (dest === path.join(TARGET, '.mcp.json'))
    return { rel: '.mcp.json', src: path.join(PKG_DIR, '.mcp.json') };
  return null;
};

// --- 소스에서 삭제된 파일 정리 ---
console.log('\n정리 중...');
for (const dest of readTracked()) {
  const r = resolve(dest);
  if (!r) continue;
  if (fs.existsSync(r.src)) continue;

  if (isIgnored(r.rel)) {
    console.log(`  keep (ignored, source removed): ${r.rel}`);
  } else {
    fs.rmSync(dest, { force: true });
    untrack(dest);
    console.log(`  remove: ${r.rel}`);
  }
}

// --- 동기화 ---
console.log('\n동기화 중...');

for (const dir of ['rules', 'agents', 'commands']) {
  const srcDir = path.join(PKG_DIR, dir);
  if (!fs.existsSync(srcDir)) continue;
  for (const fname of fs.readdirSync(srcDir).filter(f => f.endsWith('.md'))) {
    syncFile(path.join(srcDir, fname), path.join(CLAUDE_DIR, dir, fname), `${dir}/${fname}`);
  }
}

const skillsDir = path.join(PKG_DIR, 'skills');
if (fs.existsSync(skillsDir)) {
  for (const name of fs.readdirSync(skillsDir)) {
    const src = path.join(skillsDir, name, 'SKILL.md');
    if (!fs.existsSync(src)) continue;
    const destDir = path.join(CLAUDE_DIR, 'skills', name);
    fs.mkdirSync(destDir, { recursive: true });
    syncFile(src, path.join(destDir, 'SKILL.md'), `skills/${name}/SKILL.md`);
  }
}

const settingsSrc = path.join(PKG_DIR, '.claude', 'settings.json');
if (fs.existsSync(settingsSrc)) {
  syncFile(settingsSrc, path.join(CLAUDE_DIR, 'settings.json'), 'settings.json');
}

const mcpSrc = path.join(PKG_DIR, '.mcp.json');
if (fs.existsSync(mcpSrc)) {
  syncFile(mcpSrc, path.join(TARGET, '.mcp.json'), '.mcp.json');
}

const claudeMdSrc = path.join(PKG_DIR, 'CLAUDE.md');
if (fs.existsSync(claudeMdSrc)) {
  syncFile(claudeMdSrc, path.join(TARGET, 'CLAUDE.md'), 'CLAUDE.md');
}

// GitHub 템플릿 (항상 덮어쓰기)
const githubSrc = path.join(PKG_DIR, '.github');
if (fs.existsSync(githubSrc)) {
  const prSrc = path.join(githubSrc, 'PULL_REQUEST_TEMPLATE.md');
  if (fs.existsSync(prSrc)) {
    fs.mkdirSync(path.join(TARGET, '.github'), { recursive: true });
    fs.copyFileSync(prSrc, path.join(TARGET, '.github', 'PULL_REQUEST_TEMPLATE.md'));
  }
  const issueSrc = path.join(githubSrc, 'ISSUE_TEMPLATE');
  if (fs.existsSync(issueSrc)) {
    const issueDest = path.join(TARGET, '.github', 'ISSUE_TEMPLATE');
    fs.mkdirSync(issueDest, { recursive: true });
    for (const fname of fs.readdirSync(issueSrc).filter(f => f.endsWith('.md'))) {
      fs.copyFileSync(path.join(issueSrc, fname), path.join(issueDest, fname));
    }
  }
}

console.log('\n완료!');
console.log('\n특정 파일을 업데이트에서 제외하려면:');
console.log(`  ${IGNORE_FILE}`);
console.log('  예시: rules/repository-patterns.md');
