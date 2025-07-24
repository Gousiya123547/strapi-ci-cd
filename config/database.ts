export default ({ env }) => ({
  connection: {
    client: 'sqlite',
    connection: {
      filename: env('DATABASE_FILENAME', '/app/data.db'),
    },
    useNullAsDefault: true,
  },
});

