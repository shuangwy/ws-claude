try {
  const v = String(process.env.ANTHROPIC_CUSTOM_HEADERS || '');
  if (v) {
    console.log('Debug Env ANTHROPIC_CUSTOM_HEADERS:\n' + v);
  } else {
    console.log('Debug Env ANTHROPIC_CUSTOM_HEADERS: <empty>');
  }
} catch (_) {}
