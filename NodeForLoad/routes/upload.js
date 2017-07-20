var formidable = require('formidable');

function index(req, res){
  var form = new formidable.IncomingForm();
  form.parse(req);
  form.on('fileBegin', function(name, file){
    file.path ='./uploads/' + file.name;//路径写法
    console.log(file.path);
  });

  form.on('file', function(name, file){
    console.log('upload' + file.name);
    res.status(200).send('Upload success');
  })
}

exports.index = index;
