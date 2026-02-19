#!/usr/bin/env node
"use strict";

/**
 * opencircom docs generator
 *
 * Parses circuits/ .circom files for template block comments (OpenZeppelin-style) and
 * template signatures, then writes docs/ with one file per category.
 *
 * Comment format (optional block above each template):
 *   /**
 *    * @title TemplateName
 *    * @notice One-line user-facing description.
 *    * @dev Technical details, constraints, caveats.
 *    * @param n Description of template parameter.
 *    * @custom:input name Description or type.
 *    * @custom:output name Description or type.
 *    *\/
 *
 * Single-line // comments above a template are also used as @notice if no block exists.
 */

const fs = require("fs");
const path = require("path");

const ROOT = path.join(__dirname, "..");
const CIRCUITS_DIR = path.join(ROOT, "circuits");
const DOCS_DIR = path.join(ROOT, "docs");

const CATEGORY_ORDER = ["arithmetic", "comparators", "bitify", "gates", "mux", "utils", "hashing", "merkle", "voting"];
const CATEGORY_TITLES = {
  arithmetic: "Arithmetic",
  comparators: "Comparators & range",
  bitify: "Bitify",
  gates: "Gates",
  mux: "Mux & select",
  utils: "Utils",
  hashing: "Hashing",
  merkle: "Merkle",
  voting: "Voting",
};

function readDirRecursive(dir, base = dir) {
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  const out = [];
  for (const e of entries) {
    const full = path.join(dir, e.name);
    const rel = path.relative(base, full);
    if (e.isDirectory()) {
      if (e.name !== "node_modules") {
        out.push(...readDirRecursive(full, base));
      }
    } else if (e.isFile() && e.name.endsWith(".circom")) {
      out.push(rel);
    }
  }
  return out.sort();
}

function getCategory(relPath) {
  const parts = relPath.split(path.sep);
  if (parts[0] === "hashing") return "hashing";
  if (parts[0] === "merkle") return "merkle";
  if (parts[0] === "voting") return "voting";
  const name = path.basename(relPath, ".circom");
  if (["mux1", "mux2", "muxn", "switcher"].includes(name)) return "mux";
  if (name === "arithmetic") return "arithmetic";
  if (name === "comparators") return "comparators";
  if (name === "bitify") return "bitify";
  if (name === "gates") return "gates";
  if (name === "utils") return "utils";
  return "other";
}

function parseBlockComment(block) {
  const out = { title: "", notice: "", dev: [], param: {}, customInput: {}, customOutput: {}, complexity: "", security: "" };
  const lines = block.replace(/^\s*\/\*\*?\s*/, "").replace(/\s*\*\/\s*$/, "").split(/\n/);
  for (const line of lines) {
    const t = line.replace(/^\s*\*?\s*/, "").trim();
    if (t.startsWith("@title ")) out.title = t.slice(6).trim();
    else if (t.startsWith("@notice ")) out.notice = t.slice(7).trim();
    else if (t.startsWith("@dev ")) out.dev.push(t.slice(5).trim());
    else if (t.startsWith("@param ")) {
      const rest = t.slice(6).trim();
      const space = rest.indexOf(" ");
      const name = space > 0 ? rest.slice(0, space) : rest;
      out.param[name] = space > 0 ? rest.slice(space + 1) : "";
    } else if (t.startsWith("@custom:input ")) {
      const rest = t.slice(13).trim();
      const space = rest.indexOf(" ");
      const name = space > 0 ? rest.slice(0, space) : rest;
      out.customInput[name] = space > 0 ? rest.slice(space + 1) : "";
    } else if (t.startsWith("@custom:output ")) {
      const rest = t.slice(15).trim();
      const space = rest.indexOf(" ");
      const name = space > 0 ? rest.slice(0, space) : rest;
      out.customOutput[name] = space > 0 ? rest.slice(space + 1) : "";
    } else if (t.startsWith("@custom:complexity ")) out.complexity = t.slice(18).trim();
    else if (t.startsWith("@custom:security ")) out.security = t.slice(16).trim();
  }
  return out;
}

function parseSingleLineComment(line) {
  const m = line.match(/^\s*\/\/\s*(.+)$/);
  return m ? m[1].trim() : null;
}

function extractSignals(body) {
  const inputs = [];
  const outputs = [];
  const lines = body.split(/\n/);
  for (const line of lines) {
    const inM = line.match(/signal\s+input\s+(\w+)(\s*\[\s*\w+\s*\])?/);
    const outM = line.match(/signal\s+output\s+(\w+)(\s*\[\s*\w+\s*\])?/);
    if (inM) inputs.push({ name: inM[1], arr: inM[2] ? inM[2].replace(/\s/g, "") : null });
    if (outM) outputs.push({ name: outM[1], arr: outM[2] ? outM[2].replace(/\s/g, "") : null });
  }
  return { inputs, outputs };
}

function parseFile(content, relPath) {
  const templates = [];
  const fullContent = content;
  const templateRegex = /template\s+(\w+)\s*\(([^)]*)\)\s*\{/g;
  let match;
  const positions = [];
  while ((match = templateRegex.exec(content)) !== null) {
    positions.push({
      name: match[1],
      params: match[2].trim(),
      start: match.index,
      end: match.index + match[0].length,
    });
  }
  for (let i = 0; i < positions.length; i++) {
    const p = positions[i];
    const bodyStart = p.end;
    let bodyEnd = content.length;
    let braceDepth = 1;
    for (let j = bodyStart; j < content.length; j++) {
      if (content[j] === "{") braceDepth++;
      else if (content[j] === "}") {
        braceDepth--;
        if (braceDepth === 0) {
          bodyEnd = j;
          break;
        }
      }
    }
    const body = content.slice(bodyStart, bodyEnd);
    const before = content.slice(0, positions[i].start);
    const blockMatch = before.match(/\/\*\*[\s\S]*?\*\//g);
    const commentBlock = blockMatch ? blockMatch[blockMatch.length - 1] : "";
    const doc = commentBlock
      ? parseBlockComment(commentBlock)
      : { title: "", notice: "", dev: [], param: {}, customInput: {}, customOutput: {}, complexity: "", security: "" };
    if (!doc.title) doc.title = p.name;
    const sig = extractSignals(body);
    templates.push({
      name: p.name,
      params: p.params,
      ...doc,
      inputs: sig.inputs,
      outputs: sig.outputs,
      file: relPath,
    });
  }
  return templates;
}

function collectByCategory(files) {
  const byCat = {};
  for (const rel of files) {
    const full = path.join(CIRCUITS_DIR, rel);
    const content = fs.readFileSync(full, "utf8");
    const templates = parseFile(content, rel);
    const cat = getCategory(rel);
    if (!byCat[cat]) byCat[cat] = { files: [], templates: [] };
    if (!byCat[cat].files.includes(rel)) byCat[cat].files.push(rel);
    for (const t of templates) {
      t.file = rel;
      byCat[cat].templates.push(t);
    }
  }
  return byCat;
}

function mdEscape(s) {
  return String(s).replace(/\|/g, "\\|");
}

function renderTemplateMd(t) {
  const params = t.params ? `(${t.params})` : "()";
  let s = `### \`${t.name}${params}\`\n\n`;
  if (t.notice) s += `**Notice:** ${mdEscape(t.notice)}\n\n`;
  if (t.dev && t.dev.length) s += `**Dev:** ${t.dev.map(mdEscape).join(" ")}\n\n`;
  if (t.complexity) s += `**Complexity / constraints:** ${mdEscape(t.complexity)}\n\n`;
  if (t.security) s += `**Security:** ${mdEscape(t.security)}\n\n`;
  if (Object.keys(t.param).length) {
    s += "**Parameters:**\n";
    for (const [k, v] of Object.entries(t.param)) s += `- \`${k}\`: ${mdEscape(v || "—")}\n`;
    s += "\n";
  }
  s += "**Inputs:**\n";
  if (t.inputs.length) for (const i of t.inputs) s += `- \`${i.name}${i.arr || ""}\`${t.customInput[i.name] ? " — " + mdEscape(t.customInput[i.name]) : ""}\n`;
  else s += "- *(from template body)*\n";
  s += "\n**Outputs:**\n";
  if (t.outputs.length) for (const o of t.outputs) s += `- \`${o.name}${o.arr || ""}\`${t.customOutput[o.name] ? " — " + mdEscape(t.customOutput[o.name]) : ""}\n`;
  else s += "- *(from template body)*\n";
  s += `\n*Defined in \`${t.file}\`*\n\n`;
  return s;
}

function renderCategoryMd(cat, data) {
  const title = CATEGORY_TITLES[cat] || cat;
  let s = `# ${title}\n\n`;
  s += `Circuits in this category:\n\n`;
  for (const t of data.templates) {
    s += renderTemplateMd(t);
  }
  return s;
}

function main() {
  if (!fs.existsSync(CIRCUITS_DIR)) {
    console.error("circuits/ not found");
    process.exit(1);
  }
  const files = readDirRecursive(CIRCUITS_DIR);
  const byCat = collectByCategory(files);
  if (!fs.existsSync(DOCS_DIR)) fs.mkdirSync(DOCS_DIR, { recursive: true });

  let index = `# opencircom — Circuit documentation\n\n`;
  index += `Generated from \`circuits/**/*.circom\` using OpenZeppelin-style block comments.\n\n`;
  index += `## Categories\n\n`;
  for (const cat of CATEGORY_ORDER) {
    if (!byCat[cat]) continue;
    const title = CATEGORY_TITLES[cat] || cat;
    const slug = cat === "other" ? "other" : cat;
    index += `- [${title}](./${slug}.md)\n`;
  }
  index += `\n## Comment format\n\n`;
  index += `Use block comments above each template:\n\n`;
  index += "```\n/**\n * @title TemplateName\n * @notice One-line user-facing description.\n";
  index += " * @dev Technical details, constraints, caveats.\n";
  index += " * @param n Description of template parameter.\n";
  index += " * @custom:input name Description or type.\n";
  index += " * @custom:output name Description or type.\n";
  index += " * @custom:complexity Constraint count, big-O, or performance note.\n";
  index += " * @custom:security Security considerations or caveats.\n";
  index += " */\n```\n\n";
  fs.writeFileSync(path.join(DOCS_DIR, "README.md"), index, "utf8");

  for (const cat of CATEGORY_ORDER) {
    if (!byCat[cat]) continue;
    const md = renderCategoryMd(cat, byCat[cat]);
    fs.writeFileSync(path.join(DOCS_DIR, `${cat}.md`), md, "utf8");
  }
  if (byCat.other) {
    const md = renderCategoryMd("other", byCat.other);
    fs.writeFileSync(path.join(DOCS_DIR, "other.md"), md, "utf8");
  }
  console.log("Docs written to docs/");
}

main();
