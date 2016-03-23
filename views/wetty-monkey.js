var _io = io;
io = function(loc, obj) {
  obj.path = '/pun' + obj.path;
  _io(loc, obj);
}
