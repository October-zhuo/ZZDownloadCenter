var express = require('express');
var path = require('path');

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
