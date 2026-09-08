import js from '@eslint/js';
import reactHooks from 'eslint-plugin-react-hooks';
import reactRefresh from 'eslint-plugin-react-refresh';
import globals from 'globals';
import tseslint from 'typescript-eslint';

export default tseslint.config([
  // Generated Vite build output is excluded from linting.
  { ignores: ['dist'] },

  {
    // Only TypeScript and TSX source files are linted.
    files: ['**/*.{ts,tsx}'],

    // Recommended rules from the selected ESLint, TypeScript,
    // React Hooks and React Refresh configurations.
    extends: [
      js.configs.recommended,
      tseslint.configs.recommended,
      reactRefresh.configs.vite,
    ],

    plugins: {
      'react-hooks': reactHooks,
    },

    rules: {
      ...reactHooks.configs['recommended-latest'].rules,
    },

    languageOptions: {
      ecmaVersion: 2020,
      globals: globals.browser,
    },
  },
]);