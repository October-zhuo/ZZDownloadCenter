var fs = require('fs');
var path = require('path');

var root = path.resolve(process.argv[2] || '.');
var pathString = path.join(root,'/views/index.html');

function index(req, res){
  res.setHeader('Content-Type','text/html');
  fs.readFile(pathString, function(err, file){
    if(err){
      console.log(err);
      res.status(404).send('404 Not Found');
    }else{
      res.status(200).send(file);
    }
  });
}

exports.index = index;
