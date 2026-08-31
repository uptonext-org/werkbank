import { render } from '@testing-library/react-native';
import Index from '../app/index';

test('renders without crashing', async () => {
  const { getByText } = await render(<Index />);
  expect(getByText(/Open up app\/index.tsx/)).toBeTruthy();
});
