module.exports = {
  register() {},

  async bootstrap({ strapi }) {
    const role = await strapi
      .query('plugin::users-permissions.role')
      .findOne({ where: { type: 'public' } });

    if (!role) {
      console.error('❌ Public role not found');
      return;
    }

    const actions = ['find', 'findOne'];

    for (const action of actions) {
      await strapi
        .query('plugin::users-permissions.permission')
        .updateMany({
          where: {
            action: `api::blog.blog.${action}`,
            role: role.id,
          },
          data: {
            enabled: true,
          },
        });
    }

    console.log('✅ Permissions updated for Blog');
  },
};

