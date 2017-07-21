var express = require('express');
var path = require('path');
var fs = require('fs');

var upload = require('./routes/upload');
var list = require('./routes/list');
var index = require('./routes/index');
var download = require('./routes/download');

var app = express();

app.set('port', process.env.PORT || 9000);
app.listen(app.get('port'));
console.log('NodeForLoad is listenning to prot:',app.get('port'));

app.get('/index',index.index);
app.get('/list',list.index);
app.post('/upload',upload.index);
app.get('/download',download.index);
// app.get('/test.jpg',function(req,res){
//   var root = path.resolve(process.argv[2] || '.');
//   var filePath = path.join(root,'views/test.jpg');
//   fs.readFile(filePath, function(err, file){
//     if(err){
//       console.log(err);
//     }else{
//       res.status(200).send(file);
//     }
//   })
// })
