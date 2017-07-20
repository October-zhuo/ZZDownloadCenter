var fs = require('fs');
var url = require('url');
var path = require('path');

//queryString 使用

var root = path.resolve(process.argv[2] || '.');
console.log('root filePath is: ',root);

function index(req, res){
  var query = url.parse(req.url,true).query;
  var name = query.name;
  var filePath = path.join(root,'/uploads/', name);
  console.log(filePath);

  fs.stat(filePath, function(err, stats){
    if(!err && stats.isFile()){
      res.setHeader('Content-Type','application/octet-stream');
      res.status(200);
      fs.createReadStream(filePath).pipe(res);
    }else{
      res.status(404).send('404 Not Found');
    }
  });
}

exports.index = index;
