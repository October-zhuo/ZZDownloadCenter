var fs = require('fs');

function index(req, res){
  res.setHeader('Content-Type','text/html');
  res.status(200).sendFile('/Users/zhuo/Desktop/NodeForLoad/views/index.html');
}

exports.index = index;
