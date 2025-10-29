module.exports = {
  testEnvironment: 'node',
  coverageDirectory: 'coverage',
  collectCoverageFrom: [
    'server.js',
    '!node_modules/**'
  ],
  testMatch: [
    '**/*.test.js'
  ],
  verbose: true
};

