const helpers = require('../utils/helpers.js');

test('can derive host without directory path from URL', () => {
  expect(
    helpers.host_and_dir_from_url('https://ondemand.osc.edu/pun/sys/shell/ssh/owens.osc.edu'),
  ).toMatchObject(['owens.osc.edu', null]);
});

test('can derive host and directory path depth of 1 from URL', () => {
  expect(
    helpers.host_and_dir_from_url('https://ondemand.osc.edu/pun/sys/shell/ssh/owens.osc.edu/test1'),
  ).toMatchObject(['owens.osc.edu', '/test1']);
});

test('can derive host and directory path depth of 3 from URL', () => {
  expect(
    helpers.host_and_dir_from_url('https://ondemand.osc.edu/pun/sys/shell/ssh/pitzer.osc.edu/test1/test2/test3'),
  ).toMatchObject(['pitzer.osc.edu', '/test1/test2/test3']);
});

test('can derive default host from URL', () => {
  expect(
    helpers.host_and_dir_from_url('https://ondemand.osc.edu/pun/sys/shell/ssh/default'),
  ).toMatchObject(['owens.osc.edu', null]);
});

test('can derive default host and directory path depth of 1 from URL', () => {
  expect(
    helpers.host_and_dir_from_url('https://ondemand.osc.edu/pun/sys/shell/ssh/default/test1'),
  ).toMatchObject(['owens.osc.edu', '/test1']);
});

test('can derive default host without /ssh in URL', () => {
  expect(
    helpers.host_and_dir_from_url('https://ondemand.osc.edu/pun/sys/shell/'),
  ).toMatchObject(['owens.osc.edu', null]);
});
