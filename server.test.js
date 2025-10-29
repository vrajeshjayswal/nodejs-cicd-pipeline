const request = require('supertest');
const app = require('./server');

describe('API Endpoints', () => {
  test('GET / should return welcome message', async () => {
    const response = await request(app).get('/');
    expect(response.statusCode).toBe(200);
    expect(response.body).toHaveProperty('message');
    expect(response.body.status).toBe('running');
  });

  test('GET /api/health should return health status', async () => {
    const response = await request(app).get('/api/health');
    expect(response.statusCode).toBe(200);
    expect(response.body).toHaveProperty('status', 'healthy');
  });

  test('GET /api/users should return users list', async () => {
    const response = await request(app).get('/api/users');
    expect(response.statusCode).toBe(200);
    expect(response.body.success).toBe(true);
    expect(Array.isArray(response.body.data)).toBe(true);
  });

  test('POST /api/users should create a new user', async () => {
    const newUser = {
      name: 'Test User',
      email: 'test@example.com'
    };
    const response = await request(app)
      .post('/api/users')
      .send(newUser);
    expect(response.statusCode).toBe(201);
    expect(response.body.success).toBe(true);
  });

  test('404 for unknown routes', async () => {
    const response = await request(app).get('/unknown');
    expect(response.statusCode).toBe(404);
  });
});

