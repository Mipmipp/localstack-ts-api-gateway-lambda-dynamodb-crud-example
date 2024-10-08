module.exports = {
  moduleFileExtensions: ["js", "json", "ts"],
  rootDir: ".",
  testRegex: ".*\\.spec\\.ts$",
  transform: {
    "^.+\\.(t|j)s$": "ts-jest",
  },
  collectCoverageFrom: [
    "src/**/*.{ts,js}",
    "!src/**/__test__/**",
    "!src/**/node_modules/**",
    "!src/models/**",
    "!src/schemas/**",
  ],
  coverageDirectory: "coverage",
  testEnvironment: "node",
};
