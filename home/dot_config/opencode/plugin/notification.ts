import type { Plugin } from '@opencode-ai/plugin';

export const NotificationPlugin: Plugin = async ({ client, $ }) => {
  return {
    event: async ({ event }) => {
      // Send notification on session completion
      if (event.type === 'session.idle') {
        // await $`osascript -e 'display notification "Session completed!" with title "opencode"'`;
        try {
          await $`afplay /System/Library/Sounds/Sosumi.aiff`;
        } catch (err) {
          console.error('afplay failed:', err);
          await $`echo "afplay failed: ${err}" >> /tmp/opencode-session-complete.txt`;
        }
        const timestamp = new Date().toISOString();
        await $`echo "Session completed at ${timestamp}" > /tmp/opencode-session-complete.txt`;
      }
    },
  };
};
