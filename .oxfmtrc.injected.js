// printWidth is injected per-run by plugin/conform.lua so a wrapped line in an
// inline-JS string still fits 100 cols after conform re-indents the block.
export default {
  tabWidth: 2,
  printWidth: Number(process.env.OXFMT_INJECTED_WIDTH) || 92,
  singleQuote: true,
  arrowParens: "avoid",
  bracketSpacing: false,
};
