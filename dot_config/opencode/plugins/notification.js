export const NotificationPlugin = async ({ $ }) => {
  return {
    event: async ({ event }) => {
      if (event.type === "permission.asked" || event.type === "session.idle") {
        await $`sh -c 'notify OpenCode ${event.type}'`;
      }
    },
  };
};
