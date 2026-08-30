import { describe, expect, it } from 'vitest';
import { CORE_PACKAGE_NAME } from './index';

describe('packages/core', () => {
  it('exposes the placeholder export', () => {
    expect(CORE_PACKAGE_NAME).toBe('@werkbank/core');
  });
});
