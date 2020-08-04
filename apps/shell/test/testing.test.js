function distance(x1, y1, x2, y2) {
  return Math.sqrt(Math.pow(x2 - x1, 2) + Math.pow(y2 - y1, 2))
}

test('can calculate distance between two (x,y) pairs', () => {
  expect(distance(-20, 50, 100, -10)).toBeCloseTo(134.16);
});
